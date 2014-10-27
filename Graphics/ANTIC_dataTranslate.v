// module to translate display list instructions into 3-bit data to GTIA
// last updated: 10/21/2014 2330H

/* Known unfixed bugs
    - When switching from blank lines to other instructions, 
      extra AN bits are sent out due to slow instruction load
 */

`include "GTIA_modeDef.v"

`define jumpStart       3'b000
`define jumpLoadByte1   3'b001
`define jumpLoadByte2   3'b010
`define jumpExecute     3'b011
`define jumpEnd         3'b100
`define loadMSR1        2'b00
`define loadMSR2        2'b01
`define loadMSR3        2'b10
`define loadMSR4        2'b11

`define noPlayfield       2'b00
`define narrowPlayfield   2'b01
`define standardPlayfield 2'b10
`define widePlayfield     2'b11

// To translate display list commands into AN[2:0] bits to GTIA
module dataTranslate(IR, IR_rdy, Fphi0, rst, vblank, DMACTL, MSRdata_rdy, charData, colorSel, 
                     charLoaded, MSRdata_reverse, AN, loadIR, loadDLISTL, loadDLISTH, 
                     loadPtr, loadMSRL, loadMSRH, incrMSR, loadMSRdata,
                     mode, numBytes, charMode, loadChar, blankCount, loadDLIST, 
                     ANTIC_writeDLIST,
                     idle, loadMSRstate, DLISTend);
  
  input [7:0] IR;
  input IR_rdy;
  input Fphi0;
  input rst;
  input vblank;
  input [7:0] DMACTL;
  input MSRdata_rdy;
  input [63:0] charData;
  input [1:0] colorSel;
  input charLoaded;
  input [7:0] MSRdata_reverse;
  output reg [3:0] AN = `noTransmission;
  output reg loadIR = 1'b0;
  output reg loadDLISTL = 1'b0;
  output reg loadDLISTH = 1'b0;
  output reg loadPtr = 1'b0;
  output reg loadMSRL = 1'b0;
  output reg loadMSRH = 1'b0;
  output reg incrMSR = 1'b0;
  output reg loadMSRdata = 1'b0;
  
  output [3:0] mode; //
  output [6:0] numBytes; //
  output reg charMode = 1'b0;
  output reg loadChar = 1'b0;
  output [14:0] blankCount; //
  output reg loadDLIST = 1'b0;
  output reg ANTIC_writeDLIST = 1'b0;
  output idle; //
  output [1:0] loadMSRstate; //
  output reg DLISTend = 1'b0;
  
  reg idle = 1'b1;
  reg [3:0] mode = 4'd0;
  reg holdMode = 1'b0;
  reg newBlank = 1'b1;
  reg [14:0] blankCount = 15'd0;
  reg jumpType = 1'b0;
  reg [2:0] jumpState = `jumpStart;
  reg [1:0] loadMSRstate = `loadMSR1;
  reg loadMSRbit = 1'b0;
  reg [6:0] numBytes = 7'd0;
  reg loadMSRdone = 1'b0;
  reg loadedNumBytes = 1'b0;
  reg [6:0] charBit = 7'd0;
  reg charLoadHold = 1'b0;
  reg MSRdata_rdy_hold = 1'b0;
  reg waitvblank = 1'b0;
  reg [2:0] numPixel = 3'd0;
  
  wire [1:0] playfieldWidth = DMACTL[1:0];
  wire [1:0] colorSel4 = {MSRdata_reverse[(2*numPixel)+1], MSRdata_reverse[2*numPixel]};
  
  // 1. Retrieve data from RAM via DMA
  // 2. Evaluate retrieved data
  // 3. Output bits to AN
  always @ (posedge Fphi0 or posedge rst) begin
  
    if (rst) begin
      AN <= `noTransmission;
      holdMode <= 1'b0;
      newBlank <= 1'b1;
      blankCount <= 15'd0;
      loadIR <= 1'b0;
      loadDLISTL <= 1'b0;
      loadDLISTH <= 1'b0;
      jumpState <= `jumpStart;
      loadPtr <= 1'b0;
      loadMSRL <= 1'b0;
      loadMSRH <= 1'b0;
      loadMSRstate <= `loadMSR1;
      loadMSRbit <= 1'b0;
      loadMSRdone <= 1'b0;
      idle <= 1'b1;
      loadedNumBytes <= 1'b0;
      loadMSRdata <= 1'b0;
      charMode <= 1'b0;
      charBit <= 7'd0;
      incrMSR <= 1'b0;
      charLoadHold <= 1'b0;
      MSRdata_rdy_hold <= 1'b0;
      waitvblank <= 1'b0;
      loadDLIST <= 1'b0;
      ANTIC_writeDLIST <= 1'b0;
      loadChar <= 1'b0;
      numBytes <= 7'd0;
      numPixel <= 3'd0;
      DLISTend <= 1'b0;
    end
    
    else begin
    
      // Will be overwritten if bits are sent on this clock cycle
      AN <= `noTransmission;

      if (idle) begin
        // Clear control signals from terminated instructions
        loadIR <= 1'b0;
      
        // Load new mode if currently idle (no instructions running)
        if (IR_rdy) begin //((waitvblank & vblank) | ((~waitvblank) & IR_rdy)) begin
          waitvblank <= 1'b0;
          idle <= 1'b0;
          mode <= IR[3:0];
        end
      end
      
      // * TODO: Add Interrupt Routine: DLI modifier bit = IR[7]
      
      else begin

        // Mode 0: Blank Lines
        //  - Used to create 1-8 blank lines on the display in background color
        if (mode == 4'h0) begin
              
          // Start of blank lines instruction:
          // Place number of blank lines in 'blankCount'
          // (Number of blank mode lines * 8 TV scan lines per mode line * 320 pixels per TV scan line)
          if (newBlank == 1'b1) begin
            blankCount <= ((((IR[6:4]+1)*8)-1)*320);
            AN <= `modeNorm_bgColor;  // Send first blank line
            newBlank <= 1'b0;
            loadIR <= 1'b0;
          end
          
          else if (newBlank == 1'b0) begin
            
            // Normal operation, send blank pixel to GTIA and decrement blankCount
            AN <= `modeNorm_bgColor;
            blankCount <= blankCount - 3'd1;
            
            // One last blank line to display, trigger next IR load
            if (blankCount == 15'd2) begin
              newBlank <= 1'b1;
              loadIR <= 1'b1;
              idle <= 1'b1;
            end
          end
          
        end
        
        // Mode 1: Jump
        //  - Used to reload the display counter
        //  - Next 2 bytes specify the address to be loaded
        else if (mode == 4'h1) begin
              
          case (jumpState)
            
            `jumpStart:
              begin
                jumpState <= `jumpLoadByte1;
                loadIR <= 1'b1;
                jumpType <= IR[6];
              end
            
            `jumpLoadByte1:
              begin
                loadIR <= 1'b0;
                if (IR_rdy) begin
                  jumpState <= `jumpLoadByte2;
                  loadDLISTL <= 1'b1;
                  loadIR <= 1'b1;
                  loadPtr <= 1'b1;  // Block ANTIC FSM from incr dlistptr
                end
              end
            
            `jumpLoadByte2:
              begin
                loadIR <= 1'b0;
                loadDLISTL <= 1'b0;
                if (IR_rdy) begin
                  jumpState <= `jumpExecute;
                  loadDLISTH <= 1'b1;
                  ANTIC_writeDLIST <= 1'b1;
                end
              end
             
            `jumpExecute:
              begin
                jumpState <= `jumpEnd;
                loadPtr <= 1'b0;
                loadDLISTH <= 1'b0;
                loadDLIST <= 1'b1;
                ANTIC_writeDLIST <= 1'b0;
                
                // Jump to address & wait for vertical blank (used to end the Display List)
                if (jumpType == 1'b1) begin
                  waitvblank <= 1'b1;
                  DLISTend <= 1'b1;
                end
              end
              
            `jumpEnd:
              begin
                jumpState <= `jumpStart;
                loadDLIST <= 1'b0;
                DLISTend <= 1'b0;
                loadIR <= 1'b1; // Trigger jump to new pointer location
                idle <= 1'b1; // Idle until next vertical blank
              end
          endcase
          // * TODO: Add Interrupt Routine: DLI modifier bit = IR[7]
          
        end
          
        else begin
          
          if ((((~holdMode)&IR[6])|(loadMSRbit))&(~loadMSRdone)) begin
          
            case (loadMSRstate)
              
              `loadMSR1:
                begin
                  loadMSRstate <= `loadMSR2;
                  loadMSRbit <= IR[6];
                  holdMode <= 1'b1;
                  loadMSRdone <= 1'b0;
                  loadIR <= 1'b1;
                end
              
              `loadMSR2:
                begin
                  loadIR <= 1'b0;
                  if (IR_rdy) begin
                    loadMSRstate <= `loadMSR3;
                    loadMSRL <= 1'b1;
                    loadIR <= 1'b1;
                  end
                end
                
              `loadMSR3:
                begin
                  loadMSRL <= 1'b0;
                  loadIR <= 1'b0;
                  if (IR_rdy) begin
                    loadMSRstate <= `loadMSR4;  
                    loadMSRH <= 1'b1;
                  end
                end
                
              `loadMSR4:
                begin
                  loadMSRstate <= `loadMSR1;
                  loadMSRH <= 1'b0;
                  loadMSRdone <= 1'b1;
                  loadMSRbit <= 1'b0;
                end
                
            endcase
          end
          
          // * TODO: Add routine for HS modifier bit = IR[4]
          // * TODO: Add routine for VS modifier bit = IR[5]
          
          else begin
            
            case (mode)
            
              /* Mode 2: Character, 32/40/48 bytes per mode line, 8 TV scan lines per mode line, 1.5 color
               *
               *  - Default, normal-sized text mode
               *  - ANTIC displays 40 of these 8x8 sized characters on each mode line (in normal mode)
               *  - 24 of such mode lines in total (8 TV scan lines per mode line, 8*24 = 192 total lines)
               *  - Memory Scan Register (MSR) points to the current byte of character data
               *  - For a 128-char set, charByte[6:0] indexes to a character at [CHBASE], charByte[7] is for color / special info
               *  - Each character code is fetch from memory and placed in a rotating shift register for display
               *  - Each character from the set (located at [CHBASE]) is a 8-byte bitmap (* is a 1, - is a 0)
               *      A: 0 -------- 0x00
               *         1 ---**--- 0x18
               *         2 --****-- 0x3C
               *         3 -**--**- 0x66
               *         4 -**--**- 0x66
               *         5 -******- 0x7E
               *         6 -**--**- 0x66
               *         7 -------- 0x00
               */
              4'h2:
                begin
                
                  // Set the byte-width of the mode line
                  if (~loadedNumBytes) begin
                    loadedNumBytes <= 1'b1;
                    if (playfieldWidth == `narrowPlayfield)
                      numBytes <= 7'd32;
                    else if (playfieldWidth == `standardPlayfield)
                      numBytes <= 7'd40;
                    else if (playfieldWidth == `widePlayfield)
                      numBytes <= 7'd48;
                    else
                      numBytes <= 7'd0;
                    loadMSRdata <= 1'b1;
                    incrMSR <= 1'b1;
                  end
                  
                  else begin
                    loadMSRdata <= 1'b0;
                    incrMSR <= 1'b0;
                    if (MSRdata_rdy) begin
                      // Informs GTIA that display is sent in 8x8 char blocks
                      charMode <= 1'b1;
                      loadChar <= 1'b1;
                    end
                    
                    else if (charLoaded|charLoadHold) begin
                    
                      if (charLoaded) begin
                        loadChar <= 1'b0;
                        charLoadHold <= 1'b1;
                      end
                    
                      // Repeat for the number of bytes in the mode line
                      if (numBytes != 7'd0) begin
                        if (charBit == 7'd64) begin
                          numBytes <= numBytes - 7'd1;
                          charBit <= 7'd0;
                          if (numBytes != 7'd1) begin
                            loadIR <= 1'b0;
                            loadChar <= 1'b1;
                            charLoadHold <= 1'b0;
                            loadMSRdata <= 1'b1;
                            incrMSR <= 1'b1;
                          end
                        end
                        
                        else begin
                          if (charData[charBit] == 1'b1)
                            AN <= `modeNorm_playfield1; // Text foreground color
                          else
                            AN <= `modeNorm_playfield2; // Text background color
                          charBit <= charBit + 7'd1;
                        end
                      end
                      
                      // Mode line complete
                      else begin
                        loadIR <= 1'b1;
                        charLoadHold <= 1'b0;
                        loadMSRdone <= 1'b0;
                        holdMode <= 1'b0;
                        loadedNumBytes <= 1'b0;
                        idle <= 1'b1;
                      end
                    end
                    
                  end

                end
              
              // Mode 3: Character, 32/40/48 bytes per mode line, 10 TV scan lines per mode line, 1.5 color
              4'h3:
                begin
                
                end
                
              // Mode 4: Character, 32/40/48 bytes per mode line, 8 TV scan lines per mode line, 5 color      
              4'h4:
                begin
                
                end
              
              // Mode 5: Character, 32/40/48 bytes per mode line, 16 TV scan lines per mode line, 5 color
              4'h5:
                begin
                
                end
              
              // Mode 6: Character, 16/20/24 bytes per mode line, 8 TV scan lines per mode line, 5 color      
              4'h6:
                begin
                
                end
                
              // Mode 7: Character, 16/20/24 bytes per mode line, 16 TV scan lines per mode line, 5 color  
              4'h7:
                begin
                
                end
              
              
              
              
              
              
              // Mode 8: Map, 8/10/12 bytes per mode line, 8 TV scan lines per mode line, 4 color
              4'h8:
                begin
                
                end
              
              // Mode 9: Map, 8/10/12 bytes per mode line, 4 TV scan lines per mode line, 2 color
              4'h9:
                begin
                
                end
              
              // Mode 10: Map, 16/20/24 bytes per mode line, 4 TV scan lines per mode line, 4 color
              4'hA:
                begin
                
                end
              
              // Mode 11: Map, 16/20/24 bytes per mode line, 2 TV scan lines per mode line, 2 color
              4'hB:
                begin
                
                end
              
              // Mode 12: Map, 16/20/24 bytes per mode line, 1 TV scan lines per mode line, 2 color
              4'hC:
                begin
                
                end
            
              // Mode 13: Map, 32/40/48 bytes per mode line, 2 TV scan lines per mode line, 4 color
              4'hD:
                begin
                
                end
              
              // Mode 14: Map, 32/40/48 bytes per mode line, 1 TV scan lines per mode line, 4 color
              4'hE:
                begin
                  loadIR <= 1'b0;
                
                  // Set the byte-width of the mode line
                  if (~loadedNumBytes) begin
                    loadedNumBytes <= 1'b1;
                    if (playfieldWidth == `narrowPlayfield)
                      numBytes <= 7'd32;
                    else if (playfieldWidth == `standardPlayfield)
                      numBytes <= 7'd40;
                    else if (playfieldWidth == `widePlayfield)
                      numBytes <= 7'd48;
                    else
                      numBytes <= 7'd0;
                    loadMSRdata <= 1'b1;
                    incrMSR <= 1'b1;
                  end
                  
                  else begin
                    charMode <= 1'b0;
                    loadChar <= 1'b0;
                    loadMSRdata <= 1'b0;
                    incrMSR <= 1'b0;

                    // Repeat for the number of bytes in the mode line
                    if (numBytes != 7'd0) begin
                      
                      // Display next 4 pixels from 1 MSR data byte
                      if (MSRdata_rdy|MSRdata_rdy_hold) begin
                        if (MSRdata_rdy)
                          MSRdata_rdy_hold <= 1'b1;
                        
                        if (numPixel != 3'd4) begin
                    
                          case (colorSel4)
                            2'd0: AN <= `modeNorm_bgColor;
                            2'd1: AN <= `modeNorm_playfield0;
                            2'd2: AN <= `modeNorm_playfield1;
                            2'd3: AN <= `modeNorm_playfield2;
                          endcase
                          numPixel <= numPixel + 3'd1;
                        end
                        
                                              
                        // Load next MSR data byte
                        else begin
                          MSRdata_rdy_hold <= 1'b0;
                          numBytes <= numBytes - 7'd1;
                          numPixel <= 3'd0;
                          if (numBytes != 7'd1) begin
                            loadMSRdata <= 1'b1;
                            incrMSR <= 1'b1;
                          end
                        end
                        
                      end
                    end
                      
                    // Mode line complete
                    else begin
                      loadIR <= 1'b1;
                      loadMSRdone <= 1'b0;
                      holdMode <= 1'b0;
                      loadedNumBytes <= 1'b0;
                      idle <= 1'b1;
                    end
                  end
                end
              
              // Mode 15: Map, 32/40/48 bytes per mode line, 1 TV scan lines per mode line, 1.5 color
              4'hF:
                begin
                
                end
              
            endcase
          end
        end
        
      end
      
    end
    
  end

endmodule
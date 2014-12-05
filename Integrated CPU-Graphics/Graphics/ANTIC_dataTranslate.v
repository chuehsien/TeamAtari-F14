// module to translate display list instructions into 3-bit data to GTIA
// last updated: 10/21/2014 2330H

/* Known unfixed bugs
    - When switching from blank lines to other instructions, 
      extra AN bits are sent out due to slow instruction load
 */

`include "Graphics/GTIA_modeDef.v"

`define jumpStart       3'b000
`define jumpLoadByte1   3'b001
`define jumpLoadByte2   3'b010
`define jumpExecute     3'b011
`define jumpEnd         3'b100
`define loadMSR1        2'b00
`define loadMSR2        2'b01
`define loadMSR3        2'b10
`define loadMSR4        2'b11
`define sprite1         3'd0
`define sprite2         3'd1
`define sprite3         3'd2
`define sprite4         3'd3
`define sprite5         3'd4
`define sprite6         3'd5

`define noPlayfield       2'b00
`define narrowPlayfield   2'b01
`define standardPlayfield 2'b10
`define widePlayfield     2'b11

`define width  9'd320
`define height 8'd216

// To translate display list commands into AN[2:0] bits to GTIA
module dataTranslate(IR, IR_rdy, Fphi0, rst, vblank, DMACTL, MSRdata_rdy, charData, colorSel, 
                     charLoaded, MSRdata_reverse, DMA, RDY, reqBlank, AN, loadIR, loadDLISTL, loadDLISTH, 
                     loadPtr, loadMSRL, loadMSRH, incrMSR, loadMSRdata,
                     mode, numBytes, charMode, loadChar, loadDLIST, 
                     ANTIC_writeDLIST, numLines, width, height, ANTIC_writeDLI, ANTIC_writeVBI,
                     ANTIC_writeNMI,
                     idle, loadMSRstate, DLISTend, charSingleColor, colorSel4, update_WSYNC, VCOUNT,
                     blankScreen, saveMSR, resetMSR, incrY, saveY, loadM, loadP0, loadP1, loadP2, loadP3,
                     clearGRAF, spriteNum, charSprites);
  
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
  input DMA;
  input RDY;
  input reqBlank;
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
  output reg [2:0] charMode = 3'd0;
  output reg loadChar = 1'b0;
  output reg loadDLIST = 1'b0;
  output reg ANTIC_writeDLIST = 1'b0;
  output reg [1:0] numLines = `one;
  output reg [8:0] width = `width;
  output reg [7:0] height = `height;
  output reg ANTIC_writeDLI = 1'b0;
  output reg ANTIC_writeVBI = 1'b0;
  output reg ANTIC_writeNMI = 1'b0;
  output idle; //
  output [1:0] loadMSRstate; //
  output reg DLISTend = 1'b0;
  output reg charSingleColor = 1'b0;
  output [1:0] colorSel4;
  output reg update_WSYNC = 1'b0;
  output reg [7:0] VCOUNT = 8'd0;
  output reg blankScreen = 1'b0;
  output reg saveMSR = 1'b0;
  output reg resetMSR = 1'b0;
  output reg incrY = 1'b0;
  output reg saveY = 1'b0;
  output reg loadM = 1'b0;
  output reg loadP0 = 1'b0;
  output reg loadP1 = 1'b0;
  output reg loadP2 = 1'b0;
  output reg loadP3 = 1'b0;
  output reg clearGRAF = 1'b0;
  output [3:0] spriteNum;
  output reg charSprites = 1'b0;
  
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
  reg [3:0] numPixel = 4'd0;
  reg DLI = 1'b0;
  reg VBI = 1'b0;
  reg clearDLI = 1'b0;
  reg DLI_hold = 1'b0;
  reg VBI_hold = 1'b0;
  reg [2:0] numRepeat = 3'd0;
  reg [12:0] vblankcount = 13'd0;
  reg [16:0] pixNum = 17'd0;
  reg sentTwice = 1'b0;
  reg loadSpritesDone = 1'b0;
  reg [2:0] loadSpriteState = 3'd0;
  reg [3:0] spriteRepeat = 4'd0;
  //reg [5:0] hblankcount = 6'd0;
  //reg waithblank = 1'b0;
  //reg [15:0] idle_DLI = 16'd0;
  
  wire DLIST_DMA_en = DMACTL[5];
  wire [1:0] playfieldWidth = DMACTL[1:0];
  wire [1:0] colorSel4 = {MSRdata_reverse[2*numPixel], MSRdata_reverse[(2*numPixel)+1]};
  wire colorSel8 = MSRdata_reverse[numPixel];
  wire fifthColor = MSRdata_reverse[0];
  
  assign spriteNum = 4'd7 - spriteRepeat;
  
  // 1. Retrieve data from RAM via DMA
  // 2. Evaluate retrieved data
  // 3. Output bits to AN
  always @ (posedge Fphi0 or posedge rst) begin
  
    if (rst) begin
      mode <= 4'd0;
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
      charMode <= 3'd0;
      charBit <= 7'd0;
      incrMSR <= 1'b0;
      charLoadHold <= 1'b0;
      MSRdata_rdy_hold <= 1'b0;
      waitvblank <= 1'b0;
      loadDLIST <= 1'b0;
      ANTIC_writeDLIST <= 1'b0;
      loadChar <= 1'b0;
      numBytes <= 7'd0;
      numPixel <= 4'd0;
      DLISTend <= 1'b0;
      numLines <= `one;
      width <= `width;
      height <= `height;
      ANTIC_writeDLI <= 1'b0;
      ANTIC_writeVBI <= 1'b0;
      ANTIC_writeNMI <= 1'b0;
      DLI <= 1'b0;
      VBI <= 1'b0;
      clearDLI <= 1'b0;
      DLI_hold <= 1'b0;
      VBI_hold <= 1'b0;
      charSingleColor <= 1'b0;
      numRepeat <= 3'd0;
      vblankcount <= 13'd0;
      update_WSYNC <= 1'b0;
      VCOUNT <= 8'd0;
      pixNum <= 17'd0;
      blankScreen <= 1'b0;
      saveMSR <= 1'b0;
      resetMSR <= 1'b0;
      incrY <= 1'b0;
      sentTwice <= 1'b0;
      saveY <= 1'b0;
      loadSpritesDone <= 1'b0;
      loadSpriteState <= 3'd0;
      loadM <= 1'b0;
      loadP0 <= 1'b0;
      loadP1 <= 1'b0;
      loadP2 <= 1'b0;
      loadP3 <= 1'b0;
      clearGRAF <= 1'b0;
      spriteRepeat <= 4'd0;
      charSprites <= 1'b0;
      //hblankcount <= 6'd0;
      //waithblank <= 1'b0;
      //idle_DLI <= 16'd0;
    end
    
    else begin

      if (reqBlank&(~blankScreen)) begin
        charMode <= 3'd0;
        width <= `width;
        height <= `height;
        numLines <= `one;
        
        if (pixNum != 17'd69120) begin
          AN <= `modeNorm_bgColor;
          pixNum <= pixNum + 17'd1;
        end
        else begin
          AN <= `noTransmission;
          blankScreen <= 1'b1;
        end
      end
    
      else begin
      
        if (~(DMA&(~RDY))) begin
      
          // Will be overwritten if bits are sent on this clock cycle
          AN <= `noTransmission;
          ANTIC_writeDLI <= 1'b0;
          
          if (DLI_hold) begin
            DLI_hold <= 1'b0;
            ANTIC_writeDLI <= 1'b1;
            ANTIC_writeNMI <= 1'b0;
          end
          else if (VBI_hold) begin
            VBI_hold <= 1'b0;
            ANTIC_writeVBI <= 1'b1;
            ANTIC_writeNMI <= 1'b0;
          end
          else begin
            ANTIC_writeDLI <= 1'b0;
            ANTIC_writeVBI <= 1'b0;
          end

          if (idle&(~waitvblank)) begin
            // Clear control signals from terminated instructions
            loadIR <= 1'b0;
            update_WSYNC <= 1'b0;
            loadSpritesDone <= 1'b0;
            charSprites <= 1'b0;
            
            if (DLI) begin
              DLI <= 1'b0;
              DLI_hold <= 1'b1;
              ANTIC_writeNMI <= 1'b1;
            end
            
            // Load new mode if currently idle (no instructions running)
            if (IR_rdy) begin
              idle <= 1'b0;
              mode <= IR[3:0];
              DLI <= IR[7];
              if (IR[3:0] == 4'd4) begin
                spriteRepeat <= 4'd7;
                charSprites <= 1'b1;
              end
            end
              
          end
          
          /*
          else if (DLI) begin
            DLI <= 1'b0;
            DLI_hold <= 1'b1;
            ANTIC_writeNMI <= 1'b1;
          end
          else if (DLI_hold) begin
            DLI_hold <= 1'b0;
            ANTIC_writeDLI <= 1'b1;
            ANTIC_writeNMI <= 1'b0;
          end
          */
          /*
          else if (idle&DLI) begin
            
            update_WSYNC <= 1'b0;
            
            if (idle_DLI == 16'd0) begin
              DLI_hold <= 1'b1;
              ANTIC_writeNMI <= 1'b1;
              idle_DLI <= idle_DLI + 16'd1;
            end
            if (idle_DLI == 16'd8000) begin
              DLI <= 1'b0;
              idle_DLI <= 16'd0;
              //if (~waithblank)
              loadIR <= 1'b1;
            end
            else
              idle_DLI <= idle_DLI + 12'd1;
            
          end
          */
          /*
          else if (idle&waithblank&(~DLI)) begin
            
            update_WSYNC <= 1'b0;
            
            if (hblankcount == 6'd50) begin
              waithblank <= 1'b0;
              hblankcount <= 6'd0;
              loadIR <= 1'b1;
            end
            else
              hblankcount <= hblankcount + 6'd1;
          
          end
          */
          
          else if (idle&waitvblank) begin
            
            update_WSYNC <= 1'b1;
            
            /*     
            DLISTend <= 1'b0;
            if (VCOUNT != 8'd192) begin
              if (pixNum != 8'd160) begin // Change to account for varying widths
                pixNum <= pixNum + 8'd1;
                AN <= `modeNorm_bgColor;
              end
              else begin
                pixNum <= 8'd0;
                VCOUNT <= VCOUNT + 8'd1;
              end
            end
            else begin
              VCOUNT <= 8'd0;
              DLISTend <= 1'b1;
            end
            */
            
            if (VBI&&(vblankcount == 13'd2006)) begin
              VBI <= 1'b0;
              VBI_hold <= 1'b1;
              ANTIC_writeNMI <= 1'b1;
              VCOUNT <= 8'd0;
            end
          
            vblankcount <= vblankcount + 13'd1;
            
            if (vblankcount == 13'd5012) begin
              waitvblank <= 1'b0;
              vblankcount <= 13'd0;
              loadIR <= 1'b1; // Trigger jump to new pointer location
            end
          end
          
          else begin
          
            update_WSYNC <= 1'b0;

            // Mode 0: Blank Lines
            //  - Used to create 1-8 blank lines on the display in background color
            if (mode == 4'h0) begin
              charMode <= 3'd0;
              width <= `width;
              height <= `height;
              numLines <= `one;
              
              // Start of blank lines instruction:
              // Place number of blank lines in 'blankCount'
              // (Number of blank mode lines * 320 pixels per TV scan line)
              if (newBlank == 1'b1) begin
                blankCount <= ((IR[6:4]+1)*320);
                AN <= `modeNorm_bgColor;  // Send first blank pixel
                newBlank <= 1'b0;
                loadIR <= 1'b0;
                clearGRAF <= 1'b1;
              end
              
              else if (newBlank == 1'b0) begin
                
                clearGRAF <= 1'b0;
                
                // Normal operation, send blank pixel to GTIA and decrement blankCount
                AN <= `modeNorm_bgColor;
                blankCount <= blankCount - 15'd1;
                
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
                    
                    // Jump to address & wait for vertical blank period (used to end the Display List)
                    if (jumpType == 1'b1) begin
                      VBI <= 1'b1; // Send vertical blank interrupt
                      waitvblank <= 1'b1;
                      DLISTend <= 1'b1;
                    end
                  end
                  
                `jumpEnd:
                  begin
                    jumpState <= `jumpStart;
                    loadDLIST <= 1'b0;
                    DLISTend <= 1'b0;
                    idle <= 1'b1; // Idle until next vertical blank
                  end
              endcase
              
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
              
              // Load sprite data
              else if (~loadSpritesDone) begin
                
                case (loadSpriteState)
                  
                  `sprite1:
                    begin
                      loadSpriteState <= `sprite2;
                      loadM <= 1'b1;
                    end
                  
                  `sprite2:
                    begin
                      loadM <= 1'b0;
                      if (IR_rdy) begin
                        loadSpriteState <= `sprite3;
                        loadP0 <= 1'b1;
                      end
                    end
                    
                  `sprite3:
                    begin
                      loadP0 <= 1'b0;
                      if (IR_rdy) begin
                        loadSpriteState <= `sprite4;
                        loadP1 <= 1'b1;
                      end
                    end
                    
                  `sprite4:
                    begin
                      loadP1 <= 1'b0;
                      if (IR_rdy) begin
                        loadSpriteState <= `sprite5;
                        loadP2 <= 1'b1;
                      end
                    end
                  
                  `sprite5:
                    begin
                      loadP2 <= 1'b0;
                      if (IR_rdy) begin
                        loadSpriteState <= `sprite6;
                        loadP3 <= 1'b1;
                      end
                    end
                    
                  `sprite6:
                    begin
                      loadP3 <= 1'b0;
                      if (IR_rdy) begin
                        loadSpriteState <= `sprite1;
                        if (spriteRepeat == 4'd0)
                          loadSpritesDone <= 1'b1;
                        else
                          spriteRepeat <= spriteRepeat - 4'd1;
                      end
                    end
                endcase
              end
              
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
                        width <= `width;
                        height <= `height;
                        charSingleColor <= 1'b0;
                      end
                      
                      else begin
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveY <= 1'b0;
                        if (MSRdata_rdy) begin
                          // Informs GTIA that display is sent in 8x8 char blocks
                          charMode <= 3'd3;
                          loadChar <= 1'b1;
                          saveY <= 1'b1;
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
                                AN <= `modeNorm_lum1col2; // Text foreground color
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
                            //waithblank <= 1'b1;
                            update_WSYNC <= 1'b1;
                            VCOUNT <= VCOUNT + 8'd8;
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
                        width <= `width;
                        height <= `height;
                        charSingleColor <= 1'b0;
                        sentTwice <= 1'b0;
                        if (DLI) begin
                          DLI <= 1'b0;
                          DLI_hold <= 1'b1;
                          ANTIC_writeNMI <= 1'b1;
                        end
                      end
                      
                      else begin
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveY <= 1'b0;
                        if (MSRdata_rdy) begin
                          // Informs GTIA that display is sent in 8x8 char blocks
                          charMode <= 3'd3;
                          loadChar <= 1'b1;
                          saveY <= 1'b1;
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
                              if (fifthColor&&({charData[charBit],charData[charBit+1]}!=2'd0))
                                AN <= `modeNorm_playfield3;
                              else begin
                                case ({charData[charBit],charData[charBit+1]})
                                  2'd0: AN <= `modeNorm_bgColor;
                                  2'd1: AN <= `modeNorm_playfield0;
                                  2'd2: AN <= `modeNorm_playfield1;
                                  2'd3: AN <= `modeNorm_playfield2;
                                endcase
                              end
                              if (sentTwice) begin
                                charBit <= charBit + 7'd2;
                                sentTwice <= 1'b0;
                              end
                              else
                                sentTwice <= 1'b1;
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
                            //waithblank <= 1'b1;
                            update_WSYNC <= 1'b1;
                            VCOUNT <= VCOUNT + 8'd8;
                          end
                        end
                        
                      end
                    end
                  
                  // Mode 5: Character, 32/40/48 bytes per mode line, 16 TV scan lines per mode line, 5 color
                  4'h5:
                    begin
                    
                    end
                  
                  // Mode 6: Character, 16/20/24 bytes per mode line, 8 TV scan lines per mode line, 5 color      
                  4'h6:
                    begin
                    
                      // Set the byte-width of the mode line
                      if (~loadedNumBytes) begin
                        loadedNumBytes <= 1'b1;
                        if (playfieldWidth == `narrowPlayfield)
                          numBytes <= 7'd16;
                        else if (playfieldWidth == `standardPlayfield)
                          numBytes <= 7'd20;
                        else if (playfieldWidth == `widePlayfield)
                          numBytes <= 7'd24;
                        else
                          numBytes <= 7'd0;
                        loadMSRdata <= 1'b1;
                        incrMSR <= 1'b1;
                        width <= `width;
                        height <= `height;
                        numRepeat <= 3'd1;
                        charSingleColor <= 1'b1;
                        if (DLI) begin
                          DLI <= 1'b0;
                          DLI_hold <= 1'b1;
                          ANTIC_writeNMI <= 1'b1;
                        end
                      end
                      
                      else begin
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveY <= 1'b0;
                        if (MSRdata_rdy) begin
                          // Informs GTIA that display is sent in 16x8 char blocks
                          charMode <= 3'd4;
                          loadChar <= 1'b1;
                          saveY <= 1'b1;
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
                              if (charData[charBit] == 1'b1) begin
                                case (colorSel)
                                  2'd0: AN <= `modeNorm_playfield0;
                                  2'd1: AN <= `modeNorm_playfield1;
                                  2'd2: AN <= `modeNorm_playfield2;
                                  2'd3: AN <= `modeNorm_playfield3;
                                endcase
                              end
                              else
                                AN <= `modeNorm_bgColor;
                                
                              if (numRepeat != 3'd0) begin
                                numRepeat <= numRepeat - 3'd1;
                              end
                              else begin
                                numRepeat <= 3'd1;
                                charBit <= charBit + 7'd1;
                              end
                            end
                          end
                          
                          // Mode line complete
                          else begin
                            loadIR <= 1'b1;
                            charLoadHold <= 1'b0;
                            loadMSRdone <= 1'b0;
                            holdMode <= 1'b0;
                            loadedNumBytes <= 1'b0;
                            charSingleColor <= 1'b0;
                            idle <= 1'b1;
                            //waithblank <= 1'b1;
                            update_WSYNC <= 1'b1;
                            VCOUNT <= VCOUNT + 8'd16;
                          end
                        end
                      end
                    end
                    
                  // Mode 7: Character, 16/20/24 bytes per mode line, 16 TV scan lines per mode line, 5 color  
                  4'h7:
                    begin
                                  
                      // Set the byte-width of the mode line
                      if (~loadedNumBytes) begin
                        loadedNumBytes <= 1'b1;
                        if (playfieldWidth == `narrowPlayfield)
                          numBytes <= 7'd16;
                        else if (playfieldWidth == `standardPlayfield)
                          numBytes <= 7'd20;
                        else if (playfieldWidth == `widePlayfield)
                          numBytes <= 7'd24;
                        else
                          numBytes <= 7'd0;
                        loadMSRdata <= 1'b1;
                        incrMSR <= 1'b1;
                        width <= `width;
                        height <= `height;
                        numRepeat <= 3'd3;
                        charSingleColor <= 1'b1;
                      end
                      
                      else begin
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveY <= 1'b0;
                        if (MSRdata_rdy) begin
                          saveY <= 1'b1;
                          charMode <= 3'd2;
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
                              if (charData[charBit] == 1'b1) begin
                                case (colorSel)
                                  2'd0: AN <= `modeNorm_playfield0;
                                  2'd1: AN <= `modeNorm_playfield1;
                                  2'd2: AN <= `modeNorm_playfield2;
                                  2'd3: AN <= `modeNorm_playfield3;
                                endcase
                              end
                              else
                                AN <= `modeNorm_bgColor;
                                
                              if (numRepeat != 3'd0) begin
                                numRepeat <= numRepeat - 3'd1;
                              end
                              else begin
                                numRepeat <= 3'd3;
                                charBit <= charBit + 7'd1;
                              end
                            end
                          end
                          
                          // Mode line complete
                          else begin
                            loadIR <= 1'b1;
                            charLoadHold <= 1'b0;
                            loadMSRdone <= 1'b0;
                            holdMode <= 1'b0;
                            loadedNumBytes <= 1'b0;
                            charSingleColor <= 1'b0;
                            idle <= 1'b1;
                            //waithblank <= 1'b1;
                            update_WSYNC <= 1'b1;
                            VCOUNT <= VCOUNT + 8'd16;
                          end
                        end
                      end
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
                      loadIR <= 1'b0;
                    
                      // Set the byte-width of the mode line
                      if (~loadedNumBytes) begin
                        loadedNumBytes <= 1'b1;
                        if (playfieldWidth == `narrowPlayfield)
                          numBytes <= 7'd16;
                        else if (playfieldWidth == `standardPlayfield)
                          numBytes <= 7'd20;
                        else if (playfieldWidth == `widePlayfield)
                          numBytes <= 7'd24;
                        else
                          numBytes <= 7'd0;
                        loadMSRdata <= 1'b1;
                        incrMSR <= 1'b1;
                        numPixel <= 4'd0;
                        width <= `width;
                        height <= `height;
                        numLines <= `one;
                        saveMSR <= 1'b1;
                      end
                      
                      else begin
                        charMode <= 3'd0;
                        loadChar <= 1'b0;
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveMSR <= 1'b0;

                        // Repeat for the number of bytes in the mode line
                        if (numBytes != 7'd0) begin
                          
                          // Display next 8 pixels from 1 MSR data byte
                          if (MSRdata_rdy|MSRdata_rdy_hold) begin
                            if (MSRdata_rdy)
                              MSRdata_rdy_hold <= 1'b1;
                            
                            if (numPixel != 4'd8) begin
                        
                              case (colorSel8)
                                1'd0: AN <= `modeNorm_bgColor;
                                1'd1: AN <= `modeNorm_playfield0;
                              endcase
                              
                              if (sentTwice) begin
                                numPixel <= numPixel + 4'd1;
                                sentTwice <= 1'b0;
                              end
                              else
                                sentTwice <= 1'b1;
                            end
                                                                              
                            // Load next MSR data byte
                            else begin
                              MSRdata_rdy_hold <= 1'b0;
                              numBytes <= numBytes - 7'd1;
                              numPixel <= 4'd0;
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
                          //waithblank <= 1'b1;
                          update_WSYNC <= 1'b1;
                          VCOUNT <= VCOUNT + 8'd1;
                        end
                      end
                    end
                
                  // Mode 13: Map, 32/40/48 bytes per mode line, 2 TV scan lines per mode line, 4 color
                  4'hD:
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
                        numPixel <= 4'd0;
                        numRepeat <= 3'd1;
                        width <= `width;
                        height <= `height;
                        numLines <= `one; //  modified
                        saveMSR <= 1'b1;
                      end
                      
                      else begin
                        charMode <= 3'd0;
                        loadChar <= 1'b0;
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;
                        saveMSR <= 1'b0;

                        // Repeat for the number of bytes in the mode line
                        if (numBytes != 7'd0) begin
                          
                          // Display next 4 pixels from 1 MSR data byte
                          if (MSRdata_rdy|MSRdata_rdy_hold) begin
                            if (MSRdata_rdy)
                              MSRdata_rdy_hold <= 1'b1;
                            
                            if (numPixel != 4'd4) begin
                        
                              case (colorSel4)
                                2'd0: AN <= `modeNorm_bgColor;
                                2'd1: AN <= `modeNorm_playfield0;
                                2'd2: AN <= `modeNorm_playfield1;
                                2'd3: AN <= `modeNorm_playfield2;
                              endcase
                              
                              if (sentTwice) begin
                                numPixel <= numPixel + 4'd1;
                                sentTwice <= 1'b0;
                              end
                              else
                                sentTwice <= 1'b1;
                              
                            end
                                                                              
                            // Load next MSR data byte
                            else begin
                              MSRdata_rdy_hold <= 1'b0;
                              numBytes <= numBytes - 7'd1;
                              numPixel <= 4'd0;
                              if (numBytes != 7'd1) begin
                                loadMSRdata <= 1'b1;
                                incrMSR <= 1'b1;
                              end
                              else if ((numBytes == 7'd1)&&(numRepeat != 3'd0))begin
                                resetMSR <= 1'b1;
                              end
                            end
                            
                          end
                        end
                        
                        // Setup to repeat mode line
                        else if (numRepeat != 3'd0) begin
                          resetMSR <= 1'b0;
                          numRepeat <= numRepeat - 3'd1;
                          loadMSRdata <= 1'b1;
                          incrMSR <= 1'b1;
                          numBytes <= 7'd40; // Modify for different playfield widths
                          update_WSYNC <= 1'b1;
                          VCOUNT <= VCOUNT + 8'd1;
                        end
                          
                        // Mode line complete
                        else begin
                          loadIR <= 1'b1;
                          loadMSRdone <= 1'b0;
                          holdMode <= 1'b0;
                          loadedNumBytes <= 1'b0;
                          idle <= 1'b1;
                          //waithblank <= 1'b1;
                          update_WSYNC <= 1'b1;
                          VCOUNT <= VCOUNT + 8'd1;
                        end
                      end
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
                        width <= `width;
                        height <= `height;
                        numLines <= `one;
                      end
                      
                      else begin
                        charMode <= 3'd0;
                        loadChar <= 1'b0;
                        loadMSRdata <= 1'b0;
                        incrMSR <= 1'b0;

                        // Repeat for the number of bytes in the mode line
                        if (numBytes != 7'd0) begin
                          
                          // Display next 4 pixels from 1 MSR data byte
                          if (MSRdata_rdy|MSRdata_rdy_hold) begin
                            if (MSRdata_rdy)
                              MSRdata_rdy_hold <= 1'b1;
                            
                            if (numPixel != 4'd4) begin
                        
                              case (colorSel4)
                                2'd0: AN <= `modeNorm_bgColor;
                                2'd1: AN <= `modeNorm_playfield0;
                                2'd2: AN <= `modeNorm_playfield1;
                                2'd3: AN <= `modeNorm_playfield2;
                              endcase
                              
                              if (sentTwice) begin
                                numPixel <= numPixel + 4'd1;
                                sentTwice <= 1'b0;
                              end
                              else
                                sentTwice <= 1'b1;
                            end
                            
                                                  
                            // Load next MSR data byte
                            else begin
                              MSRdata_rdy_hold <= 1'b0;
                              numBytes <= numBytes - 7'd1;
                              numPixel <= 4'd0;
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
                          //waithblank <= 1'b1;
                          update_WSYNC <= 1'b1;
                          VCOUNT <= VCOUNT + 8'd1;
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
    end
    
  end

endmodule
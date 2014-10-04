// module to translate display list instructions into 3-bit data to GTIA
// last updated: 10/02/2014 2345H

`include "GTIA_modeDef.v"

`define jumpStart       3'b000
`define jumpLoadByte1   3'b001
`define jumpLoadByte2   3'b010
`define jumpExecute     3'b011
`define jumpEnd         3'b100

// To translate display list commands into AN[2:0] bits to GTIA
module dataTranslate(IR, IR_rdy, Fphi0, RST, vblank, AN, loadIR, loadDLISTL, loadDLISTH, 
                     DLISTjump, DLISTend, loadPtr);
  
  input [7:0] IR;
  input IR_rdy;
  input Fphi0;
  input RST;
  input vblank;
  output reg [2:0] AN;
  output reg loadIR;
  output reg loadDLISTL;
  output reg loadDLISTH;
  output reg DLISTjump;
  output reg DLISTend;
  output reg loadPtr;
  
  reg idle;
  reg [3:0] mode;
  reg holdMode;
  reg newBlank;
  reg [2:0] blankCount;
  reg jumpType;
  reg [1:0] jumpState;
  reg loadIR_hold;
  reg modeComplete;
  reg loadDLIST_hold;
  
  wire loadDLIST;
  assign loadDLIST = (loadDLISTH | loadDLISTL);
  
  // 1. Retrieve data from RAM via DMA
  // 2. Evaluate retrieved data
  // 3. Output bits to AN
  always @ (posedge Fphi0) begin
  
    // Will be overwritten if bits are sent on this clock cycle
    AN <= 3'bzzz;
  
    if (RST) begin
      // Initialize registers
      holdMode <= 1'b0;
      newBlank <= 1'b1;
      blankCount <= 3'd0;
      loadIR <= 1'b0;
      loadDLISTL <= 1'b0;
      loadDLISTH <= 1'b0;
      DLISTjump <= 1'b0;
      DLISTend <= 1'b0;
      idle <= 1'b0;
      loadIR_hold <= 1'b0;
      modeComplete <= 1'b0;
      jumpState <= `jumpStart;
      loadDLIST_hold <= 1'b0;
      loadPtr <= 1'b0;
    end
    
    else if (idle) begin
      if (vblank)
        idle <= 1'b0;
    end
    
    // Holds required signals to the ANTIC FSM for 2 Fphi0 cycles (1 phi2 cycle)
    else if (modeComplete || loadDLIST) begin
    
      if (modeComplete) begin
        if (loadIR && ~loadIR_hold)
          loadIR_hold <= 1'b1;
        else if (loadIR && loadIR_hold) begin
          loadIR <= 1'b0;
          loadIR_hold <= 1'b0;
          modeComplete <= 1'b0;
        end
      end
      
      if (loadDLIST) begin
        if (loadDLISTL) begin
          if (loadDLISTL && ~loadDLIST_hold)
            loadDLIST_hold <= 1'b1;
          else if (loadDLISTL && loadDLIST_hold) begin
            loadDLIST_hold <= 1'b0;
            loadDLISTL <= 1'b0;
          end
        end
        else if (loadDLISTH) begin
          if (loadDLISTH && ~loadDLIST_hold)
            loadDLIST_hold <= 1'b1;
          else if (loadDLISTH && loadDLIST_hold) begin
            loadDLIST_hold <= 1'b0;
            loadDLISTH <= 1'b0;
          end
        end
      end
      
    end
    
    else begin

      // Load new mode if not halfway through another mode's instruction
      if (IR_rdy && ~holdMode)
        mode <= IR[3:0];
      
      case (mode)
      
        // Mode 0: Blank Lines
        //  - Used to create 1-8 blank lines on the display in background color
        // * TODO: Send background color or horizontal blank intruction to GTIA?
        4'h0:
          begin
            
            // Start of blank lines instruction:
            // Place number of blank lines in 'blankCount' and send first blank line struction to GTIA
            if (newBlank == 1'b1) begin
              blankCount <= IR[6:4];    // Number of blank lines = IR[6:4]
              AN <= `modeNorm_bgColor;  // Send first blank line
              
              // Single blank line has been displayed; End of instruction
              if (IR[6:4] == 3'd0) begin
                newBlank <= 1'b1;
                loadIR <= 1'b1;
                modeComplete <= 1'b1;
              end  
              
              // More than 1 blank line required; Continue instruction
              else begin
                newBlank <= 1'b0;
                loadIR <= 1'b0;
              end
            end
            
            else if (newBlank == 1'b0) begin
              
              // One last blank line to display
              if (blankCount == 3'd1) begin
                AN <= `modeNorm_bgColor;
                newBlank <= 1'b1;
                loadIR <= 1'b1;
                modeComplete <= 1'b1;
              end
            
              // More to display; Continue displaying blank lines
              else begin
                AN <= `modeNorm_bgColor;
                blankCount <= blankCount - 3'd1;
              end
            
            end
            
            // * TODO: Add Interrupt Routine: DLI modifier bit = IR[7]
          
          end
        
        // Mode 1: Jump
        //  - Used to reload the display counter
        //  - Next 2 bytes specify the address to be loaded
        4'h1:
          begin
            
            case (jumpState)
              
              `jumpStart:
                begin
                  jumpState <= `jumpLoadByte1;
                  holdMode <= 1'b1;
                  loadIR <= 1'b1;
                  jumpType <= IR[6];
                end
              
              `jumpLoadByte1:
                begin
                  if (IR_rdy) begin
                    jumpState <= `jumpLoadByte2;
                    loadDLISTL <= 1'b1;
                    loadIR <= 1'b0;
                    loadPtr <= 1'b1;  // Block ANTIC FSM from incr dlistptr
                  end
                end
              
              `jumpLoadByte2:
                begin
                  if (IR_rdy) begin
                    jumpState <= `jumpExecute;
                    loadDLISTH <= 1'b1;
                  end
                end
               
              `jumpExecute:
                begin
                  holdMode <= 1'b0;
                  jumpState <= `jumpEnd;
                  loadPtr <= 1'b0;
                  
                  // Trigger jump to new pointer location
                  DLISTjump <= 1'b1;
                  loadIR <= 1'b1;
                  
                  // Jump to address (used for crossing over 1K boundary)
                  if (jumpType == 1'b0) begin
                    DLISTend <= 1'b0;
                  end
                
                  // Jump to address & wait for vertical blank (used to end the Display List)
                  else if (jumpType == 1'b1) begin
                    DLISTend <= 1'b1;
                    idle <= 1'b1; // Idle until next vertical blank
                  end
                end
                
              `jumpEnd:
                begin
                  jumpState <= `jumpStart;
                  DLISTjump <= 1'b1;
                end
                
              default:
                begin
                  jumpState <= `jumpStart;
                end
            endcase
            
            // * TODO: Add Interrupt Routine: DLI modifier bit = IR[7]
            
          end
        
        // Mode 2: Character, 32/40/48 bytes per mode line, 8 TV scan lines per mode line, 1.5 color
        4'h2:
          begin
          
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
          
          end
        
        // Mode 15: Map, 32/40/48 bytes per mode line, 1 TV scan lines per mode line, 1.5 color
        4'hF:
          begin
          
          end
          
        // No mode selected
        default:
          begin
            
          end
        
      endcase
      
    end
    
  end

endmodule
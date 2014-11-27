// top module for the GTIA processor.
// last updated: 10/21/2014 2330H

`include "Graphics/GTIA_modeDef.v"
`include "Graphics/colorTable.v"

module GTIA(address, AN, CS, DEL, OSC, RW, trigger, Fphi0, rst, charMode, DLISTend, numLines,
            width, height, incrY, saveY,
            COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,
            HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
            SIZEP0, SIZEP1, SIZEP2, SIZEP3, SIZEM, GRAFP0, GRAFP1, GRAFP2,
            GRAFP3, GRAFM, COLPM0, COLPM1, COLPM2, CONSPK,
            DB, switch,
            M0PF, M1PF, M2PF, M3PF, P0PF, P1PF, P2PF, P3PF, M0PL, M1PL, 
            M2PL, M3PL, P0PL, P1PL, P2PL, P3PL, TRIG0, TRIG1, TRIG2, TRIG3, 
            PAL, CONSOL,
            COL, CSYNC, HALT, L,
            dBuf_data, dBuf_addr, dBuf_writeEn,
            vblank, hblank, x, y, colorData, RGB);

      // Control inputs
      input [4:0] address;
      input [3:0] AN;
      input CS;
      input DEL;
      input OSC;
      input RW;
      input [3:0] trigger;
      input Fphi0;
      input rst;
      input [2:0] charMode;
      input DLISTend;
      input [1:0] numLines;
      input [8:0] width;
      input [7:0] height;
      input incrY;
      input saveY;
      
      // Memory-mapped register inputs
      input [7:0] COLPM3;
      input [7:0] COLPF0;
      input [7:0] COLPF1;
      input [7:0] COLPF2;
      input [7:0] COLPF3;
      input [7:0] COLBK;
      input [7:0] PRIOR;
      input [7:0] VDELAY;
      input [7:0] GRACTL;
      input [7:0] HITCLR;
      
      input [7:0] HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
                  SIZEP0, SIZEP1, SIZEP2, SIZEP3, SIZEM, GRAFP0, GRAFP1, GRAFP2,
                  GRAFP3, GRAFM, COLPM0, COLPM1, COLPM2, CONSPK;
      
      // Control inouts
      inout [7:0] DB;
      inout [3:0] switch;
      
      output reg [7:0] M0PF = 8'h00;
      output reg [7:0] M1PF = 8'h00;
      output reg [7:0] M2PF = 8'h00;
      output reg [7:0] M3PF = 8'h00;
      output reg [7:0] P0PF = 8'h00;
      output reg [7:0] P1PF = 8'h00;
      output reg [7:0] P2PF = 8'h00;
      output reg [7:0] P3PF = 8'h00;
      output reg [7:0] M0PL = 8'h00;
      output reg [7:0] M1PL = 8'h00;
      output reg [7:0] M2PL = 8'h00;
      output reg [7:0] M3PL = 8'h00;
      output reg [7:0] P0PL = 8'h00;
      output reg [7:0] P1PL = 8'h00;
      output reg [7:0] P2PL = 8'h00;
      output reg [7:0] P3PL = 8'h00;
      output reg [7:0] TRIG0 = 8'h00;
      output reg [7:0] TRIG1 = 8'h00;
      output reg [7:0] TRIG2 = 8'h00;
      output reg [7:0] TRIG3 = 8'h00;
      output reg [7:0] PAL = 8'h00;
      output reg [7:0] CONSOL = 8'h00;
      
      // Control output signals
      output COL;
      output CSYNC;
      output HALT;
      output [3:0] L;
      
      // Display buffer outputs
      output [31:0] dBuf_data;
      output [16:0] dBuf_addr;
      output reg dBuf_writeEn = 1'b0;
      
      // Other outputs
      output reg vblank = 1'b0;
      output reg hblank = 1'b0;
      output [8:0] x;
      output [7:0] y;
      output [7:0] colorData;//
      output [23:0] RGB;//
      
      reg [1:0] clkdiv = 2'd0;
      reg [8:0] x = 9'd0; // 320 pixels
      reg [7:0] y = 8'd0; // 192(216) pixels
      reg [7:0] baseColor = 8'd0;
      reg [3:0] baseType = 4'd0;
      reg incrXY = 1'b0;
      reg incrXY_nextcycle = 1'b0;
      reg [7:0] savedY = 8'd0;
      
      wire [23:0] RGB;
      wire [1:0] mode;
      wire P0set, P1set, P2set, P3set, M0set, M1set, M2set, M3set;
      wire [7:0] colorData;
      
      assign mode = PRIOR[7:6];
      assign dBuf_data = {8'd0, RGB};
      assign dBuf_addr = (y*9'd320)+x; // * TODO: Change to parameters for variable screen size
      
			// Module instantiations here
      colorTable ct(.colorData(colorData), .RGB(RGB));
      prioritySel pr(PRIOR[5:0], baseColor, COLPM0, COLPM1, COLPM2, COLPM3, baseType,
                     P0set, P1set, P2set, P3set, M0set, M1set, M2set, M3set, colorData);
      spriteDisplay sd(x, HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
                       GRAFP0, GRAFP1, GRAFP2, GRAFP3, GRAFM, P0set, P1set, P2set, P3set,
                       M0set, M1set, M2set, M3set);
      
      always @(posedge Fphi0 or posedge rst) begin
      
        if (rst) begin
          incrXY <= 1'b0;
          incrXY_nextcycle <= 1'b0;
          dBuf_writeEn <= 1'b0;
          baseColor <= 8'd0;
          baseType <= 4'd0;
        end
        
        else begin
        
          if (DLISTend) begin
            incrXY <= 1'b0;
            incrXY_nextcycle <= 1'b0;
          end
            
          if (incrXY_nextcycle) begin
            incrXY <= 1'b1;
          end
          else
            incrXY <= 1'b0;
        
          if (mode == `mode_normal) begin
            if (AN != `noTransmission) begin
              case (AN)
                `modeNorm_bgColor:
                  baseColor <= COLBK;
                `modeNorm_vSync:
                  ;
                `modeNorm_hBlank_c40:
                  ;
                `modeNorm_lum1col2:
                  baseColor <= {COLPF2[7:4], COLPF1[3:0]};
                `modeNorm_playfield0:
                  baseColor <= COLPF0;
                `modeNorm_playfield1:
                  baseColor <= COLPF1;
                `modeNorm_playfield2:
                  baseColor <= COLPF2;
                `modeNorm_playfield3:
                  baseColor <= COLPF3;
              endcase
              baseType <= AN;
              dBuf_writeEn <= 1'b1;
              incrXY_nextcycle <= 1'b1;
            end
            else begin
              baseColor <= 8'd0;
              dBuf_writeEn <= 1'b0;
              incrXY_nextcycle <= 1'b0;
            end
          end
          
          else begin
            dBuf_writeEn <= 1'b0;
          end
          
        end
      end
      
      // Clock the pixels into display buffer
      always @(negedge Fphi0 or posedge rst) begin
      
        if (rst) begin
          x <= 9'd0;
          y <= 8'd0;
          vblank <= 1'b0;
          hblank <= 1'b0;
          savedY <= 8'd0;
        end
        
        else begin
        
          if (saveY)
            savedY <= y;
      
          if (DLISTend) begin
            x <= 9'd0;
            y <= 8'd0;
          end
          
          else if (incrY) begin
            if (y == (height - 8'd1))
              y <= 8'd0;
            else
              y <= y + 8'd1;
          end
      
          else if (incrXY) begin
            
            vblank <= 1'b0;
            hblank <= 1'b0;

            // Display in 8 by 8 blocks
            if (charMode != 3'd0) begin
              
              case (charMode)
              
                // 16 x 8 blocks (x=16, y=8)
                3'd1: begin
                  // End of entire display block
                  if ((x == (width-1))&&(y == (height-1))) begin
                    x <= 9'd0;
                    y <= 8'd0;
                    vblank <= 1'b1;
                  end
                  
                  else begin
                    // Transition from end of 20/40 blocks to start of next line of blocks
                    if ((x == (width-1))&&((y % 8) == 8'd7)) begin
                      x <= 9'd0;
                      y <= y + 8'd1;
                      hblank <= 1'b1;
                    end
                    
                    else begin
                      // Transition from end of single block to start of next block
                      if (((x % 16) == 9'd15)&&((y % 8) == 8'd7)) begin
                        x <= x + 9'd1;
                        y <= y - 8'd7;
                      end
                      
                      else begin
                        // Transition from end of single line in block to start of next line
                        if ((x % 16) == 9'd15) begin
                          x <= x - 9'd15;
                          y <= y + 8'd1;
                        end
                        
                        // Normal transition to next pixel on the right
                        else begin
                          x <= x + 9'd1;
                        end
                      end
                    end
                  end
                end
                
                // 16 x 16 blocks (x=16, y=16)
                3'd2: begin
                
                  // End of entire display block
                  if ((x == (width-1))&&(y == (height-1))) begin
                    x <= 9'd0;
                    y <= 8'd0;
                    vblank <= 1'b1;
                  end
                  
                  else begin
                    
                    // Transition from end of 20 blocks to start of next line of blocks
                    if ((x == (width-1))&&(((y - savedY) % 16) == 8'd15)) begin
                      x <= 9'd0;
                      y <= y + 8'd1;
                      hblank <= 1'b1;
                    end
                    
                    else begin
                    
                      // Transition from end of single block to start of next block
                      if (((x % 16) == 9'd15)&&(((y - savedY) % 16) == 8'd15)) begin
                        x <= x + 9'd1;
                        y <= y - 8'd15;
                      end
                      
                      else begin
                      
                        // Transition from end of double line in block to start of next double line
                        if (((x % 16) == 9'd15)&&((y % 2) == 8'd1)) begin
                          x <= x - 9'd15;
                          y <= y + 8'd1;
                        end
                        
                        else begin
                        
                          // Transition from end of mini-block to start of next mini-block
                          if (((x % 2) == 9'd1)&&((y % 2) == 8'd1)) begin
                            x <= x + 9'd1;
                            y <= y - 8'd1;
                          end
                          
                          else begin
                          
                            // Transition from first line pixel 1 to next line pixel 0
                            if ((x % 2) == 9'd1) begin
                              x <= x - 9'd1;
                              y <= y + 8'd1;
                            end
                            
                            // Transition to next pixel on the right
                            else
                              x <= x + 9'd1;
                              
                          end
                        end
                      end
                    end
                  end
                end
                
                // 8 x 8 blocks (x=8, y=8)
                3'd3: begin
                  // End of entire display block
                  if ((x == (width-1))&&(y == (height-1))) begin
                    x <= 9'd0;
                    y <= 8'd0;
                    vblank <= 1'b1;
                  end
                  
                  else begin
                    // Transition from end of 40 blocks to start of next line of blocks
                    if ((x == (width-1))&&(((y - savedY) % 8) == 8'd7)) begin
                      x <= 9'd0;
                      y <= y + 8'd1;
                      hblank <= 1'b1;
                    end
                    
                    else begin
                      // Transition from end of single block to start of next block
                      if (((x % 8) == 9'd7)&&(((y - savedY) % 8) == 8'd7)) begin
                        x <= x + 9'd1;
                        y <= y - 8'd7;
                      end
                      
                      else begin
                        // Transition from end of single line in block to start of next line
                        if ((x % 8) == 9'd7) begin
                          x <= x - 9'd7;
                          y <= y + 8'd1;
                        end
                        
                        // Normal transition to next pixel on the right
                        else begin
                          x <= x + 9'd1;
                        end
                      end
                    end
                  end
                end
                
                // 16 x 8 blocks (x=16, y=8)
                3'd4: begin
                  // End of entire display block
                  if ((x == (width-1))&&(y == (height-1))) begin
                    x <= 9'd0;
                    y <= 8'd0;
                    vblank <= 1'b1;
                  end
                  
                  else begin
                    // Transition from end of 40 blocks to start of next line of blocks
                    if ((x == (width-1))&&(((y - savedY) % 8) == 8'd7)) begin
                      x <= 9'd0;
                      y <= y + 8'd1;
                      hblank <= 1'b1;
                    end
                    
                    else begin
                      // Transition from end of single block to start of next block
                      if (((x % 16) == 9'd15)&&(((y - savedY) % 8) == 8'd7)) begin
                        x <= x + 9'd1;
                        y <= y - 8'd7;
                      end
                      
                      else begin
                        // Transition from end of single line in block to start of next line
                        if ((x % 16) == 9'd15) begin
                          x <= x - 9'd15;
                          y <= y + 8'd1;
                        end
                        
                        // Normal transition to next pixel on the right
                        else begin
                          x <= x + 9'd1;
                        end
                      end
                    end
                  end
                end
                
              endcase
            end
          
            // Display line by line
            else begin

              case (numLines)
              
                // 1 scan line per mode line
                `one:
                  begin
                    if (x < (width-1)) // * TODO: Set parameters here
                      x <= x + 9'd1;
                    else begin
                      x <= 9'd0;
                      hblank <= 1'b1;
                      if (y < (height-1))
                        y <= y + 8'd1;
                      else begin
                        y <= 8'd0;
                        vblank <= 1'b1;
                      end
                    end
                  end
                
                // 2 scan lines per mode line
                `two:
                  begin
                    // Transition from end of screen to start
                    if ((x == (width-1))&&(y == (height-1))) begin
                      x <= 9'd0;
                      y <= 8'd0;
                    end
                    else begin
                      
                      // Transition from end of mode line to next mode line
                      if ((x == (width-1))&&((y % 2) == 1)) begin 
                        x <= 9'd0;
                        y <= y + 8'd1;
                      end
                      
                      else begin
                        
                        // Transition from lower pixel to next upper pixel
                        if ((y % 2) == 1) begin
                          x <= x + 9'd1;
                          y <= y - 8'd1;
                        end
                        
                        // Transition from upper pixel to lower pixel
                        else begin
                          y <= y + 8'd1;
                        end
                      
                      end
                      
                    end
                  end
                
                `four:
                  begin
                  
                  end
                
                `eight:
                  begin
                  
                  end
                  
              endcase
            end
          end
        end
      end
      
endmodule


module prioritySel(PRIOR, baseColor, PM0color, PM1color, PM2color, PM3color, baseType,
                   P0set, P1set, P2set, P3set, M0set, M1set, M2set, M3set, colorData);
  
  input [5:0] PRIOR;
  input [7:0] baseColor;
  input [7:0] PM0color, PM1color, PM2color, PM3color;
  input [3:0] baseType;
  input P0set, P1set, P2set, P3set, M0set, M1set, M2set, M3set;
  output reg [7:0] colorData;
  
  wire [3:0] priority = PRIOR[3:0];
  
  always @(*) begin
    
    case (priority)
          
      4'd0:
        begin
          if (P0set|M0set) begin
            if (P0set&&((baseType == `modeNorm_playfield0)||(baseType == `modeNorm_playfield1)))
              colorData <= PM0color|baseColor;
            else
              colorData <= PM0color;
          end
          else if (P1set|M1set) begin
            if (P1set&&((baseType == `modeNorm_playfield0)||(baseType == `modeNorm_playfield1)))
              colorData <= PM1color|baseColor;
            else
              colorData <= PM1color;
          end
          else if ((baseType == `modeNorm_playfield0)||(baseType == `modeNorm_playfield1))
            colorData <= baseColor;
          else if (P2set|M2set) begin
            if (P2set&&((baseType == `modeNorm_playfield2)||(baseType == `modeNorm_playfield3)))
              colorData <= PM2color|baseColor;
            else
              colorData <= PM2color;
          end
          else if (P3set|M3set) begin
            if (P3set&&((baseType == `modeNorm_playfield2)||(baseType == `modeNorm_playfield3)))
              colorData <= PM3color|baseColor;
            else
              colorData <= PM3color;
          end
          else
            colorData <= baseColor;
        end
        
      4'd1:
        begin
          if (P0set|M0set)
            colorData <= PM0color;
          else if (P1set|M1set)
            colorData <= PM1color;
          else if (P2set|M2set)
            colorData <= PM2color;
          else if (P3set|M3set)
            colorData <= PM3color;
          else
            colorData <= baseColor;
        end
      
    endcase
  end
  
endmodule


module spriteDisplay(x, HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
                     GRAFP0, GRAFP1, GRAFP2, GRAFP3, GRAFM, P0set, P1set, P2set, P3set,
                     M0set, M1set, M2set, M3set);

  input [8:0] x;
  input [7:0] HPOSP0, HPOSP1, HPOSP2, HPOSP3;
  input [7:0] HPOSM0, HPOSM1, HPOSM2, HPOSM3;
  input [7:0] GRAFP0, GRAFP1, GRAFP2, GRAFP3, GRAFM;
  output P0set, P1set, P2set, P3set, M0set, M1set, M2set, M3set;
  
  wire [7:0] HPOS = x[8:1] + 8'h30;
  
  playerInRange  p0(HPOS, HPOSP0, GRAFP0, P0set);
  playerInRange  p1(HPOS, HPOSP1, GRAFP1, P1set);
  playerInRange  p2(HPOS, HPOSP2, GRAFP2, P2set);
  playerInRange  p3(HPOS, HPOSP3, GRAFP3, P3set);
  missileInRange m0(HPOS, HPOSM0, GRAFM[1:0], M0set);
  missileInRange m1(HPOS, HPOSM1, GRAFM[3:2], M1set);
  missileInRange m2(HPOS, HPOSM2, GRAFM[5:4], M2set);
  missileInRange m3(HPOS, HPOSM3, GRAFM[7:6], M3set);

endmodule


module playerInRange(HPOS, HPOSX, GRAF, bitSet);

  input [7:0] HPOS;
  input [7:0] HPOSX;
  input [7:0] GRAF;
  output reg bitSet;
  
  always @(*) begin
    if ((HPOS >= HPOSX)&&(HPOS < (HPOSX + 8'd8)))
      bitSet <= GRAF[7-(HPOS-HPOSX)];
    else
      bitSet <= 1'b0;
  end
  
endmodule

module missileInRange(HPOS, HPOSX, GRAF, bitSet);

  input [7:0] HPOS;
  input [7:0] HPOSX;
  input [1:0] GRAF;
  output reg bitSet;
  
  always @(*) begin
    if ((HPOS >= HPOSX)&&(HPOS < (HPOSX + 8'd2)))
      bitSet <= GRAF[1-(HPOS-HPOSX)];
    else
      bitSet <= 1'b0;
  end
  
endmodule

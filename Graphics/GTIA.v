// top module for the GTIA processor.
// last updated: 10/21/2014 2330H

`include "GTIA_modeDef.v"
`include "colorTable.v"

module GTIA(address, AN, CS, DEL, OSC, RW, trigger, Fphi0, rst, charMode, DLISTend,
            COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,
            DB, switch,
            HPOSP0_M0PF_bus, HPOSP1_M1PF_bus, HPOSP2_M2PF_bus, HPOSP3_M3PF_bus, HPOSM0_P0PF_bus, 
            HPOSM1_P1PF_bus, HPOSM2_P2PF_bus, HPOSM3_P3PF_bus, SIZEP0_M0PL_bus, SIZEP1_M1PL_bus, 
            SIZEP2_M2PL_bus, SIZEP3_M3PL_bus, SIZEM_P0PL_bus, GRAFP0_P1PL_bus, GRAFP1_P2PL_bus, 
            GRAFP2_P3PL_bus, GRAFP3_TRIG0_bus, GRAFPM_TRIG1_bus, COLPM0_TRIG2_bus, COLPM1_TRIG3_bus, 
            COLPM2_PAL_bus, CONSPK_CONSOL_bus,
            COL, CSYNC, phi2, HALT, L,
            dBuf_data, dBuf_addr, dBuf_writeEn,
            vblank, hblank);

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
      input charMode;
      input DLISTend;
      
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
      
      // Control inouts
      inout [7:0] DB;
      inout [3:0] switch;
      
      // Memory-mapped register inouts
      inout [7:0] HPOSP0_M0PF_bus;
      inout [7:0] HPOSP1_M1PF_bus;
      inout [7:0] HPOSP2_M2PF_bus;
      inout [7:0] HPOSP3_M3PF_bus;
      inout [7:0] HPOSM0_P0PF_bus;
      inout [7:0] HPOSM1_P1PF_bus;
      inout [7:0] HPOSM2_P2PF_bus;
      inout [7:0] HPOSM3_P3PF_bus;
      inout [7:0] SIZEP0_M0PL_bus;
      inout [7:0] SIZEP1_M1PL_bus;
      inout [7:0] SIZEP2_M2PL_bus;
      inout [7:0] SIZEP3_M3PL_bus;
      inout [7:0] SIZEM_P0PL_bus;
      inout [7:0] GRAFP0_P1PL_bus;
      inout [7:0] GRAFP1_P2PL_bus;
      inout [7:0] GRAFP2_P3PL_bus;
      inout [7:0] GRAFP3_TRIG0_bus;
      inout [7:0] GRAFPM_TRIG1_bus;
      inout [7:0] COLPM0_TRIG2_bus;
      inout [7:0] COLPM1_TRIG3_bus;
      inout [7:0] COLPM2_PAL_bus;
      inout [7:0] CONSPK_CONSOL_bus;
      
      // Control output signals
      output COL;
      output CSYNC;
      output phi2;
      output HALT;
      output [3:0] L;
      
      // Display buffer outputs
      output [31:0] dBuf_data;
      output [15:0] dBuf_addr;
      output reg dBuf_writeEn = 1'b0;
      
      // Other outputs
      output reg vblank = 1'b0;
      output reg hblank = 1'b0;
      
      reg [1:0] clkdiv = 2'd0;
      reg [8:0] x = 9'd0; // 320 pixels
      reg [7:0] y = 8'd0; // 192 pixels
      reg [7:0] colorData = 8'd0;
      reg incrXY = 1'b0;
      
      wire [23:0] RGB;
      wire [1:0] mode;
      
      assign mode = PRIOR[7:6];
      assign dBuf_data = {8'd0, RGB};
      assign dBuf_addr = (y*9'd320)+x; // * TODO: Change to parameters for variable screen size
      
      // * TODO: Replace with 'x ? (a : b)' when writing to mapped registers 
      // Register read/write control
      assign HPOSP0_M0PF_bus = 8'hzz;
      assign HPOSP1_M1PF_bus = 8'hzz;
      assign HPOSP2_M2PF_bus = 8'hzz;
      assign HPOSP3_M3PF_bus = 8'hzz;
      assign HPOSM0_P0PF_bus = 8'hzz;
      assign HPOSM1_P1PF_bus = 8'hzz;
      assign HPOSM2_P2PF_bus = 8'hzz;
      assign HPOSM3_P3PF_bus = 8'hzz;
      assign SIZEP0_M0PL_bus = 8'hzz;
      assign SIZEP1_M1PL_bus = 8'hzz;
      assign SIZEP2_M2PL_bus = 8'hzz;
      assign SIZEP3_M3PL_bus = 8'hzz;
      assign SIZEM_P0PL_bus = 8'hzz;
      assign GRAFP0_P1PL_bus = 8'hzz;
      assign GRAFP1_P2PL_bus = 8'hzz;
      assign GRAFP2_P3PL_bus = 8'hzz;
      assign GRAFP3_TRIG0_bus = 8'hzz;
      assign GRAFPM_TRIG1_bus = 8'hzz;
      assign COLPM0_TRIG2_bus = 8'hzz;
      assign COLPM1_TRIG3_bus = 8'hzz;
      assign COLPM2_PAL_bus = 8'hzz;
      assign CONSPK_CONSOL_bus = 8'hzz;
      
			// Module instantiations here
      colorTable ct(.colorData(colorData), .RGB(RGB));
      
      always @(posedge Fphi0 or posedge rst) begin
      
        if (rst) begin
          incrXY <= 1'b0;
          dBuf_writeEn <= 1'b0;
          colorData <= 8'd0;
        end
        
        else begin
        
          if (DLISTend)
            incrXY <= 1'b0;
        
          if (mode == `mode_normal) begin
            if (AN != `noTransmission) begin
              case (AN)
                `modeNorm_bgColor:
                  colorData <= COLBK;
                `modeNorm_vSync:
                  ;
                `modeNorm_hBlank_c40:
                  ;
                `modeNorm_hBlank_s40:
                  ;
                `modeNorm_playfield0:
                  colorData <= COLPF0;
                `modeNorm_playfield1:
                  colorData <= COLPF1;
                `modeNorm_playfield2:
                  colorData <= COLPF2;
                `modeNorm_playfield3:
                  colorData <= COLPF3;
              endcase
              dBuf_writeEn <= 1'b1;
              incrXY <= 1'b1;
            end
            else begin
              colorData <= 8'd0;
              dBuf_writeEn <= 1'b0;
              incrXY <= 1'b0;
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
        end
        
        else begin
      
          if (DLISTend) begin
            x <= 9'd0;
            y <= 8'd0;
          end
      
          else if (incrXY) begin
            
            vblank <= 1'b0;
            hblank <= 1'b0;

            // Display in 8 by 8 blocks
            if (charMode) begin
              
              // End of entire display block
              if ((x == 9'd319)&&(y == 8'd191)) begin
                x <= 9'd0;
                y <= 8'd0;
                vblank <= 1'b1;
              end
              
              else begin
                // Transition from end of 40 blocks to start of next line of blocks
                if ((x == 9'd319)&&((y % 8) == 8'd7)) begin
                  x <= 9'd0;
                  y <= y + 8'd1;
                  hblank <= 1'b1;
                end
                
                else begin
                  // Transition from end of single block to start of next block
                  if (((x % 8) == 9'd7)&&((y % 8) == 8'd7)) begin
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
          
            // Display line by line
            else begin
              if (x < 9'd159) // * TODO: Set parameters here
                x <= x + 9'd1;
              else begin
                x <= 9'd0;
                hblank <= 1'b1;
                if (y < 8'd191)
                  y <= y + 8'd1;
                else begin
                  y <= 8'd0;
                  vblank <= 1'b1;
                end
              end
            end
          end
        end
      end
      
      // Clock divider
      assign phi2 = clkdiv[1];
      always @(posedge Fphi0) begin
        if (clkdiv == 2'b11) 
          clkdiv <= 2'b00;
        else
          clkdiv <= clkdiv + 2'd1;
      end
      
endmodule




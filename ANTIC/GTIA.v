// top module for the GTIA processor.
// last updated: 10/15/2014 1115H

module GTIA(address, AN, CS, DEL, OSC, RW, trigger, Fphi0, 
            COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,
            DB, switch,
            HPOSP0_M0PF_bus, HPOSP1_M1PF_bus, HPOSP2_M2PF_bus, HPOSP3_M3PF_bus, HPOSM0_P0PF_bus, 
            HPOSM1_P1PF_bus, HPOSM2_P2PF_bus, HPOSM3_P3PF_bus, SIZEP0_M0PL_bus, SIZEP1_M1PL_bus, 
            SIZEP2_M2PL_bus, SIZEP3_M3PL_bus, SIZEM_P0PL_bus, GRAFP0_P1PL_bus, GRAFP1_P2PL_bus, 
            GRAFP2_P3PL_bus, GRAFP3_TRIG0_bus, GRAFPM_TRIG1_bus, GRAFPM_TRIG2_bus, GRAFPM_TRIG3_bus, 
            COLPM2_PAL_bus, CONSPK_CONSOL_bus,
            COL, CSYNC, phi2, HALT, L);

      // Control inputs
      input [4:0] address;
      input [2:0] AN;
      input CS;
      input DEL;
      input OSC;
      input RW;
      input [3:0] trigger;
      input Fphi0;
      
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
      inout [7:0] GRAFPM_TRIG2_bus;
      inout [7:0] GRAFPM_TRIG3_bus;
      inout [7:0] COLPM2_PAL_bus;
      inout [7:0] CONSPK_CONSOL_bus;
      
      // Control output signals
      output COL;
      output CSYNC;
      output phi2;
      output HALT;
      output [3:0] L;
      
      reg [1:0] clkdiv = 2'd0;
      
			// Module instantiations here
      always @(posedge Fphi0) begin
      
      
      
      end
      
      // Clock divider
      assign phi2 = clkdiv[1];
      always @(posedge Fphi0 or negedge Fphi0) begin
        if (clkdiv == 2'b11) 
          clkdiv <= 2'b00;
        else
          clkdiv <= clkdiv + 2'd1;
      end
      
endmodule
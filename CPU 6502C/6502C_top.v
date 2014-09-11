// top module for the 6502C cpu.
// last updated: 09/11/2014 1434H

module 6502C(RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in, 
			DB,
			phi1_out, SYNC, AB, phi2_out, RW)
			
			input RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
			inout [7:0] DB;
			output phi1_out, SYNC, phi2_out,RW;
			output [15:0] AB;
		
			//module instantiations here
			
			
endmodule
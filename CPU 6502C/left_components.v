// this module contains all contains that are driven by clocks and the left side of the block diagram
// last updated: 09/11/2014 1534H

module clockGen(phi0_in,
				phi1_out,phi2_out,phi1_extout,phi2_extout);
				
	input phi0_in;
	output phi1_out,phi2_out,phi1_extout,phi2_extout;

endmodule

module predecodeRegister(phi2_in,
						extDataBus,
						outToIR);
						
	input phi2_in;
	inout extDataBus;
	output outToIR;
						
endmodule
						
module instructionRegister(inFromPredecode, 
						outToDecodeRom);
						
	input inFromPredecode; //sigIn - (T1)(phi2)(RDY)(phi1)
	output outToDecodeRom;
	
endmodule

module timingGeneration(TZPRE, clockFromControl,
						SYNC, clockToDecode, clockToControl);
						
	input TZPRE, clockFromControl;
	output SYNC, clockToDecode, clockToControl;
						
endmodule

module decodeROM(inFromIR, clock,
				outToRandomControl);
				
	input inFromIR, clock;
	output outToRandomControl;
	
endmodule

module interruptResetControl(NMI_L, IRQ_L, RES_L,
							outToControl);
	input NMI_L,IRQ_L,RES_L;
	output outToControl;
	
endmodule

module readyControl(RDY,RwFromControl,
					RDYout)
	
	input RDY, RwFromControl;
	output RDYout;
	
endmodule

module randomControl(clock, decoded, interrupt, rdyControl, SV,
					clock_out, RW, controlSig_t);
					
	input clock, decoded, interrupt, rdyControl, SV;
	output clock_out, RW;
	output controlSig_t;

endmodule
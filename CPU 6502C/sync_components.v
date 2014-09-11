// this module contains all contains that are driven by clocks
// last updated: 09/11/2014 1534H

module predecodeRegister(phi2_in,
						outToIR);
						
	input phi2_in;
	output outToIR;
						
endmodule
						
module instructionRegister(inFromPredecode, 
						outToDecodeRom);
						
	input inFromPredecode; //sigIn - (T1)(phi2)(RDY)(phi1)
	output outToDecodeRom;
	
endmodule

module decodeROM(inFromIR, clock,
				outToRandomControl);
				
	input inFromIR, clock;
	output outToRandomControl;
	
endmodule

module randomControl(clock, decoded, interrupt, rdyControl, SV,
					clock_out, RW, controlSig_t);
					
	input clock, decoded, interrupt, rdyControl, SV;
	output clock_out, RW;
	output controlSig_t;

endmodule
// this module contains all contains that are driven by clocks and the right side of the block diagram
// last updated: 09/11/2014 1534H

module dataBusTristate(en, dataIn,
						extDataBus);
						
	input en;
	input [7:0] dataIn;
	inout [7:0] extDataBus;
	
endmodule

module dataOutReg(ld, dataIn,
				dataOut);
				
	input ld;
	input [7:0] dataIn;
	output [7:0] dataOut;

endmodule

module inputDataLatch(phi2_in, DL_DB, DL_ADL, DL_ADH,
						extDataBus,DB,ADL,ADH);
	
	input phi2_in, DL_DB, DL_ADL, DL_ADH;
	inout [7:0] extDataBus, DB, ADL, ADH;
	
endmodule

module PcSelectReg(PCL_PCL, ADL_PCL, inFromPCL, ADL, 
				outToIncre);
	
	input PCL_PCL, ADL_PCL;
	input [7:0] inFromPCL, ADL;
	output [7:0] outToIncre;
	
endmodule

module increment(inc, inAdd,
				carry,outAdd);
				
	input inc;
	input [7:0] inAdd;
	output carry;
	output [7:0] outAdd;
	
endmodule

module PC(phi2, PCL_DB, PCL_ADL,
			DB, ADL,
			PCout);
			
	input phi2, PCL_DB, PCL_ADL;
	input [7:0] DB, ADL;
	output [7:0] PCout;

endmodule

module inverter(DB,
				dataOut);
	
	input [7:0] DB;
	output [7:0] dataOut;
	
endmodule

module SPreg(S_S, SB_S, S_ADL, S_SB, SBin,
			ADL, SB);
			
	input S_S, SB_S, S_ADL, S_SB;
	input [7:0] SBin;
	inout [7:0] ADL, SB;
	
endmodule

module Breg(DB_L_AD, DB_ADD, ADL_ADD, dataIn, INVdataIn, ADL,
			outToALU);
			
	input DB_L_AD, DB_ADD, ADL_ADD;
	input [7:0] dataIn, INVdataIn;
	input [7:0] ADL;
	output [7:0] outToALU;
	
endmodule

module Areg(ground, O_ADD, SB_ADD, SB,
			outToALU);
			
	input ground, O_ADD, SB_ADD;
	input [7:0] SB;
	output [7:0] outToALU;
	
endmodule

module AdderHoldReg(phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, addRes,
					ADL,SB);

	input phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
	input [7:0] addRes;
	inout [7:0] ADL, SB;
	
endmodule

module ALU(DAA, I_ADDC, SRS, SUMS, ANDS, EORS, ORS, Ain, Bin,
			AVR, ACR, HC,adderOut);
	
	input DAA,I_ADDC, SRS, SUMS, ANDS, EORS, ORS;
	input [7:0] Ain, Bin;
	output AVR, ACR, HC;
	output [7:0] adderOut;

endmodule

module decimalAdjust(SBin, DSA, DAA, ACR, HC, phi2,
					dataOut);

	input [7:0] SBin;
	input DSA, DAA, ACR, HC, phi2;
	output [7:0] dataOut;
	
	//refer to http://imrannazar.com/Binary-Coded-Decimal-Addition-on-Atmel-AVR
	// for the function of this. basically i think this converts the input, into BCD format.
endmodule

module accum(inFromDecAdder, SB_AC, AC_DB, AC_SB,
			DB,SB);
		
	input [7:0] inFromDecAdder;
	input SB_AC, AC_DB, AC_SB;
	inout DB, SB;
	
endmodule
			
module ABreg(load, dataOut);

	input load;
	output [7:0] dataOut;

endmodule

module register(load, bus_en,
			SB);
	
	input load, bus_en;
	inout [7:0] SB;
	
endmodule

module statusReg(P_DB, DBZ, IR5, ACR ,AVR ,
					DBO_C , IR5_C, ACR_C, 
					DBI_Z, DBZ_Z, 
					DB2_I, IR5_I, 
					DB3_D, IR5_D, 
					DB6_V, AVR_V, I_V, 
					DB7_N, DBin,
					DBinout);
	
	input P_DB, DBZ, IR5, ACR ,AVR ,
					DBO_C , IR5_C, ACR_C, 
					DBI_Z, DBZ_Z, 
					DB2_I, IR5_I, 
					DB3_D, IR5_D, 
					DB6_V, AVR_V, I_V, 
					DB7_N;
	input [7:0] DBin;
					
	inout [7:0] Binout;
	
endmodule

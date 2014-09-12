/****************************************************
 * Project: Atari 5200                              *
 *                                                  *
 * Top Module: 6502C CPU                            *
 * Sub-module: Right-side of diagram (re-org?)      *
 *                                                  *
 * Team Atari                                       *
 *    Alvin Goh     (chuehsig)                      *
 *    Benjamin Hong (bhong)                         *
 *    Jonathan Ong  (jonathao)                      *
 ****************************************************/
 
/* Changelog:
    11 Sept 2014, 2300hrs: Updated ALU, AdderHoldReg, Areg, Breg modules (jong)
    11 Sept 2014, 1534hrs: Created modules (chue)
*/

// Note: Decimal Enable (DAA) not yet understood or implemented
module ALU(ALU_out, AVR, ACR, HC, A, B, DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS);

  output reg [7:0] ALU_out;
  output reg AVR, ACR, HC;
  input [7:0] A, B;
  input DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS;
  
  always @ (*) begin
    // Addition operation: A + B + Cin
    // Perform in two steps to produce half-carry value
    // Overflow if (A[7]==B[7]) && (ALU_out[7]!=A[7]) 
    if (SUMS) begin
      {HC, ALU_out[3:0]} <= A[3:0] + B[3:0] + I_ADDC;
      {ACR, ALU_out[7:4]} <= A[7:4] + B[7:4] + HC;
      AVR <= ((A[7]==B[7])!=ALU_out[7]);
    end
    else if (ANDS)
      ALU_out <= A & B;
    else if (EORS)
      ALU_out <= A ^ B;
    else if (ORS)
      ALU_out <= A | B;
    else if (SRS)
      ALU_out <= {1'b0, ALU_out[7:1]};
  end
  
endmodule


module AdderHoldReg(phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, addRes,	ADL,SB);

	input phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
	input [7:0] addRes;
	inout [7:0] ADL, SB;
	
  reg [7:0] adderReg;
  
  always @ (phi2) begin
    adderReg <= addRes;
  end
  
  assign ADL = ADD_ADL ? adderReg : 8'hZZ;
  assign SB[6:0] = ADD_SB0to6 ? adderReg[6:0] : 7'bZZZZZZZ;
  assign SB[7] = ADD_SB7 ? adderReg[7] : 1'bZ;
  
endmodule


module Areg(O_ADD, SB_ADD, SB,
			outToALU);
			
	input O_ADD, SB_ADD;
	input [7:0] SB;
	output reg [7:0] outToALU;
  
  always @ (*) begin
    if (SB_ADD)
      outToALU <= SB;
    else if (O_ADD)
      outToALU <= 8'h00;
  end
	
endmodule


module Breg(DB_L_AD, DB_ADD, ADL_ADD, dataIn, INVdataIn, ADL,
			outToALU);
			
	input DB_L_AD, DB_ADD, ADL_ADD;
	input [7:0] dataIn, INVdataIn;
	input [7:0] ADL;
	output reg [7:0] outToALU;
  
  always @ (*) begin
    if (DB_L_AD)
      outToALU <= INVdataIn;
    else if (DB_ADD)
      outToALU <= dataIn;
    else if (ADL_ADD)
      outToALU <= ADL;
  end
	
endmodule


/* -------------------- */


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

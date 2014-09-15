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
	14 Sep 2014,  1940hrs: verified ALU, AdderReg. Waiting for confirmation from author (jong).
						   Also finished up the other modules except status reg.
    11 Sept 2014, 2300hrs: Updated ALU, AdderHoldReg, Areg, Breg modules (jong)
    11 Sept 2014, 1534hrs: Created modules (chue)
*/

//chue verified
// Note: Decimal Enable (DAA) not yet understood or implemented
module ALU(A, B, DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS, ALU_out, AVR, ACR, HC);

  input [7:0] A, B;
  input DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS;
  output reg [7:0] ALU_out;
  output reg AVR, ACR, HC;
  
  always @ (*) begin
	AVR = 1'b1;
	ACR = 1'b1;
	HC = 1'b1;
    // Addition operation: A + B + Cin
    // Perform in two steps to produce half-carry value
    // Overflow if (A[7]==B[7]) && (ALU_out[7]!=A[7]) 
    if (SUMS) begin
      {HC, ALU_out[3:0]} = A[3:0] + B[3:0] + I_ADDC;
      {ACR, ALU_out[7:4]} = A[7:4] + B[7:4] + HC;
      AVR = ((A[7]==B[7]) & (A[7]!=ALU_out[7]); //jong double-check. ALU is not sync. use = instead of <=
    end
    else if (ANDS)
      ALU_out = A & B;
    else if (EORS)
      ALU_out = A ^ B;
    else if (ORS)
      ALU_out = A | B;
    else if (SRS) // which to shift? A or B? can we just default to A.
      //ALU_out = {1'b0, ALU_out[7:1]};
	  ALU_out = {1'b0, A[7:1]};
	  // need to shift out the carry i thk.
	  ACR = A[0];
  end
  
endmodule

//chue verified
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

// is this sync or async?
module Areg(O_ADD, SB_ADD, SB,
			outToALU);
			
	input O_ADD, SB_ADD;
	input [7:0] SB;
	output reg [7:0] outToALU;
  
  always @ (*) begin
  // which case should take priority
    if (SB_ADD)
      outToALU <= SB;
    else if (O_ADD)
      outToALU <= 8'h00;
  end
	
endmodule

// is this sync or async
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
	
	always @ (*) begin
		if (en)
		extDataBus = dataIn;
		else
		extDataBus = 8'bZZZZZZZZ;
	end	
	
endmodule

module dataOutReg(ld, dataIn,
				dataOut);
				
	input ld;
	input [7:0] dataIn;
	output [7:0] dataOut;
	
	always @(*) begin
		if (ld)
			dataOut = dataIn;
		else	
			dataOut = 8'bZZZZZZZZ;
	end

endmodule

module inputDataLatch(phi2_in, DL_DB, DL_ADL, DL_ADH,extDataBus,
						DB,ADL,ADH);
	
	input phi2_in, DL_DB, DL_ADL, DL_ADH;
	input [7:0] extDataBus;
	inout [7:0] DB, ADL, ADH;
	
	reg [7:0] dataInLatch;
	
	always @ (posedge phi2_in) begin
			dataInLatch <= extDataBus;
	end
	
	always @ (DL_DB, DL_ADL, DL_ADH, dataInLatch) begin
		DB = (DL_DB) ? dataInLatch : 8'bZZZZZZZZ;
		ADL = (ADL_DB) ? dataInLatch : 8'bZZZZZZZZ;
		ADH = (ADH_DB) ? dataInLatch : 8'bZZZZZZZZ;
			
	end
	
endmodule

// TOTAL OF TWO OF THESE IN THE FULL IMPLEMENTATION. 1 for low add, 1 for high add.
module PcSelectReg(PCL_PCL, ADL_PCL, inFromPCL, ADL, 
				outToIncre);
	
	input PCL_PCL, ADL_PCL;
	input [7:0] inFromPCL, ADL;
	output [7:0] outToIncre;
	
	wire PCL_PCL, ADL_PCL;
	wire [7:0] inFromPCL, ADL;
	reg [7:0] outToIncre;
	
	always @ (*) begin
		outToIncre = (PCL_PCL)? inFromPCL : ADL;
		if (PCL_PCL == ADL_PCL) 
			outToIncre = 8'bzzzzzzzz; //sth is wrong if this happens.
	end
	
	
endmodule

module increment(inc, inAdd,
				carry,outAdd);
				
	input inc;
	input [7:0] inAdd;
	output carry;
	output [7:0] outAdd;
	
	reg [8:0] result;
	
	always @(*)begin
		carry = 1'b0;
		if (inc) begin
			result = {1'b0,inAdd} + 8'b1;
			outAdd = result[7:0];
			if (result[8]) carry = 1'b1;
		end
		else 
			outAdd = inAdd;
	end
	
	
endmodule

module PC(ld, PCL_DB, PCL_ADL,
			DB, ADL, inFromIncre,
			PCout);
			
	input ld, PCL_DB, PCL_ADL;
	input [7:0] DB, ADL, inFromIncre;
	output [7:0] PCout;
	
	wire ld, PCL_DB, PCL_ADL;
	wire [7:0] DB, ADL, inFromIncre;
	reg [7:0] PCout;
	
	always @ (posedge ld) begin
	if (PCL_DB)
		PCout <= DB;
	else if (PCL_ADL)
		PCout <= ADL;
	else 
		PCout <= inFromIncre;
		
	end

endmodule

module inverter(DB,
				dataOut);
	
	input [7:0] DB;
	output [7:0] dataOut;
	
	wire [7:0] DB;
	wire [7:0] dataOut;
	
	assign dataOut = ~DB;
	
endmodule

module SPreg(S_S, SB_S, S_ADL, S_SB, SBin,
			ADL, SB);
			
	input S_S, SB_S, S_ADL, S_SB;
	input [7:0] SBin;
	inout [7:0] ADL, SB;
	
	wire S_S, SB_S, S_ADL, S_SB;
	wire [7:0] SBin;
	reg [7:0] ADL, SB;
	
	reg [7:0] currSP;
	
	always @ (*) begin
	if (S_S) begin
		ADL = (S_ADL) ? currSP : 8'bzzzzzzzz;
		SB = (S_SB) ? currSP : 8'bzzzzzzzz;
	end
	else if (SB_S) begin
		currSP = (S_ADL) ? ADL : SB;
		if (S_ADL == S_SB) currSP = 8'bzzzzzzzz; //should not reach here!
	end
	
	end
	
	
endmodule

module decimalAdjust(SBin, DSA, DAA, ACR, HC, phi2,
					dataOut);

	input [7:0] SBin;
	input DSA, DAA, ACR, HC, phi2;
	output [7:0] dataOut;
	
	reg [7:0] dataOut;
	//refer to http://imrannazar.com/Binary-Coded-Decimal-Addition-on-Atmel-AVR
	// for the function of this. basically i think this converts the input, into BCD format.
	
	// I DO NOT UNDERSTAND THE BLOCK DIAGRAM. WHY GOT WIRES AND GATES ON THE OUTSIDE OF THE ADJUSTERS.
	// there seems to be 8 decimal adjusters???? lol.
	// AND WHAT DO I DO WITH THE CLOCK INPUT -.-
	// and what is DSA?
	
	// implementation based on website above:

	always @ (*) begin
	
		if (DAA) begin
			if (SBin[3:0] > 4'd9 || HC) begin
				dataOut = SBin + 8'h6;
			end
				
			if (ACR || (SBin > 8'h99)) begin
				dataOut = SBin + 8'h60;
				// BCD carry has occurred. Do anything??
			end 
		
		end
		
		else dataOut = SBin;
	
	end
	
	// this module is a mess!
	
endmodule

module accum(inFromDecAdder, SB_AC, AC_DB, AC_SB,
			DB,SB);
		
	input [7:0] inFromDecAdder;
	input SB_AC, AC_DB, AC_SB;
	inout DB, SB;
	
	reg [7:0] currAccum;
	
	always @ (*) begin
		if (SB_AC) currAccum = inFromDecAdder;
	
		DB = (AC_DB) ? currAccum : 8'bzzzzzzzz;
		SB = (AC_SB) ? currAccum : 8'bzzzzzzzz;
		
	end
	
endmodule
			
module AdressBusReg(load, dataIn,
				dataOut);

	input load;
	input [7:0] dataIn;
	output [7:0] dataOut;

	wire load;
	reg [7:0] dataOut;
	
	always @ (posedge load) begin
		dataOut = dataIn;
	end
	
	
endmodule

//used for x and y registers
module register(load, bus_en,
			SB);
	
	input load, bus_en;
	inout [7:0] SB;
	
	reg [7:0] currVal;
	
	
	always @(*) begin
		if (load) currVal = SB;
		SB = (bus_en) ? currVal : 8'bzzzzzzzz;
	
	end
	
endmodule

module statusReg(P_DB, DBZ, IR5, ACR ,AVR,
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
					
	inout [7:0] DBinout;
	
	reg [7:0] currVal;
	
	// bit arrangement: (bit 7) NV_BDIZC (bit 0) - bit 2 has no purpose.
	always @(*) begin
		
		
		currVal[0] = DBO_C | IR5_C | ACR_C;
		currVal[1] = DBI_Z | DBZ_Z;
		currVal[2] = DB2_I | IR5_I;
		currVal[3] = DB3_D | IR5_D;
		currVal[4] = 1'b0; //read documents, but dont undestand what this bit does...
		currVal[5] = 1'b0;
		currVal[6] = DB6_V | AVR_V | I_V;
		currVal[7] = DB7_N;
		
		DBinout = (P_DB) ? currVal : 8'bzzzzzzzz;
	end
	
endmodule

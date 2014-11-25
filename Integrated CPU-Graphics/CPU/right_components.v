/****************************************************
 * Project: Atari 5200                              *
 *                                                  *
 * Top Module: 6502C CPU                            *
 * Sub-module: Right-side of diagram (re-org?)      *
 *                                                  *
 * Team Atari                                       *
 *    Alvin Goh     (chuehsig)                   *
 *    Benjamin Hong (bhong)                         *
 *    Jonathan Ong  (jonathao)            
 *
 ****************************************************/
 
/* Changelog:

*/

module sigLatchWclkDual(haltAll,clk,in,out);
  input haltAll,clk;
  input in;
  output out;
  
  reg ffout = 1'b0;


  wire seen;
  assign seen = (ffout == 1'b1);

  always @ (posedge clk) begin
		if (haltAll) ffout <= ffout;
		else ffout <= (seen) ? 1'b0 : in;
  end

  assign out = ffout | in;
  
endmodule


module sigLatchWclk8nohold(haltAll,refclk,clk,in,out);
  input haltAll,refclk,clk;
  input [7:0] in;
  output [7:0] out;
  
  reg [7:0] ffout = 8'd0;
 // assign ffin = (ffout) ? 1'b0 : in;
  always @ (posedge clk) begin
    if (haltAll) ffout <= ffout;
	 else ffout <= (refclk) ? in : 8'd0;
  end
  
  assign out = ffout;
  
endmodule
//only latch if ref clock is high.
module sigLatchWclknohold(haltAll,refclk,clk,in,out);
  input haltAll,refclk,clk, in;
  output out;
  
  reg ffout = 1'b0;
 // assign ffin = (ffout) ? 1'b0 : in;
  always @ (posedge clk) begin
	 if (haltAll) ffout <= ffout;
    else ffout <= (refclk) ? in : 1'b0;
  end
  
  //FDCPE #(.INIT(1'b0)) FF0(.Q(ffout),.C(clk),.CE(refclk),.CLR(1'b0),.D(ffin),.PRE(1'b0));

  assign out = ffout;
  
endmodule



module sigLatchWclk8(haltAll,refclk,clk,in,out);
  input haltAll,refclk,clk;
  input [7:0] in;
  output [7:0] out;
  
  reg [7:0] ffout = 8'd0;
 // assign ffin = (ffout) ? 1'b0 : in;
  always @ (posedge clk) begin
    if (haltAll) ffout <= ffout;
    else ffout <= (refclk) ? in : 8'd0;
  end
  
  assign out = ffout | in;
  
endmodule

//only latch if ref clock is high.
module sigLatchWclk(haltAll,refclk,clk,in,out);
  input haltAll,refclk,clk, in;
  output out;
  
  reg ffout = 1'b0;
 // assign ffin = (ffout) ? 1'b0 : in;
  always @ (posedge clk) begin
    if (haltAll) ffout <= ffout;
    else ffout <= (refclk) ? in : 1'b0;
  end
  
  //FDCPE #(.INIT(1'b0)) FF0(.Q(ffout),.C(clk),.CE(refclk),.CLR(1'b0),.D(ffin),.PRE(1'b0));

  assign out = ffout | in;
  
endmodule

module sigLatch(clk,in,out);
  input clk, in;
  output out;
  
  wire ffout;
  assign ffin = (ffout) ? 1'b0 : in;
  FDCPE #(.INIT(1'b0)) FF0(.Q(ffout),.C(clk),.CE(1'b1),.CLR(1'b0),.D(ffin),.PRE(1'b0));

  assign out = ffout | in;
endmodule

  
module FlipFlop8clr(clk,in,en,out,clr);
    input clk;
    input [7:0] in;
    input en,clr;
    output [7:0] out;
    
    FDCPE #(.INIT(1'b0)) FF0(.Q(out[0]),.C(clk),.CE(en),.CLR(clr),.D(in[0]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF1(.Q(out[1]),.C(clk),.CE(en),.CLR(clr),.D(in[1]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF2(.Q(out[2]),.C(clk),.CE(en),.CLR(clr),.D(in[2]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF3(.Q(out[3]),.C(clk),.CE(en),.CLR(clr),.D(in[3]),.PRE(1'b0));
   
    FDCPE #(.INIT(1'b0)) FF4(.Q(out[4]),.C(clk),.CE(en),.CLR(clr),.D(in[4]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF5(.Q(out[5]),.C(clk),.CE(en),.CLR(clr),.D(in[5]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF6(.Q(out[6]),.C(clk),.CE(en),.CLR(clr),.D(in[6]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF7(.Q(out[7]),.C(clk),.CE(en),.CLR(clr),.D(in[7]),.PRE(1'b0));

endmodule


module FlipFlop8(clk,in,en,out);
    input clk;
    input [7:0] in;
    input en;
    output [7:0] out;
    
    FDCPE #(.INIT(1'b0)) FF0(.Q(out[0]),.C(clk),.CE(en),.CLR(1'b0),.D(in[0]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF1(.Q(out[1]),.C(clk),.CE(en),.CLR(1'b0),.D(in[1]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF2(.Q(out[2]),.C(clk),.CE(en),.CLR(1'b0),.D(in[2]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF3(.Q(out[3]),.C(clk),.CE(en),.CLR(1'b0),.D(in[3]),.PRE(1'b0));
   
    FDCPE #(.INIT(1'b0)) FF4(.Q(out[4]),.C(clk),.CE(en),.CLR(1'b0),.D(in[4]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF5(.Q(out[5]),.C(clk),.CE(en),.CLR(1'b0),.D(in[5]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF6(.Q(out[6]),.C(clk),.CE(en),.CLR(1'b0),.D(in[6]),.PRE(1'b0));
    FDCPE #(.INIT(1'b0)) FF7(.Q(out[7]),.C(clk),.CE(en),.CLR(1'b0),.D(in[7]),.PRE(1'b0));

endmodule

// Note: Decimal Enable (DAA) not yet understood or implemented
module ALU(A, B, DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS, ALU_out, AVR, ACR, HC,relDirection);

  input [7:0] A, B;
  input DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS;
  output [7:0] ALU_out;
  output AVR, ACR, HC,relDirection; 
  
  
  wire [8:0] result;
  assign result = (A + B + I_ADDC) & 9'h1ff;
  wire [4:0] halfResult;
  assign halfResult = (A[3:0] + B[3:0] + I_ADDC) & 5'h1f;
  
    assign ACR = (DAA) ? (result > 9'h99) :
						((SUMS) ? (result[8]) : 
               ((SRS) ? B[0] : 1'b0));
               
               
    assign HC = halfResult[4];
    assign AVR = (SUMS) ?  ((A[7]==B[7]) & (A[7] != result[7])) : 1'b0;
    assign ALU_out = (SUMS) ? (result[7:0]) :
                           ((ANDS) ? (A&B) : 
                           ((EORS) ? (A^B) :
                           ((ORS) ? (A|B) :
                           ((SRS) ? {I_ADDC, B[7:1]} : 8'hzz))));
                           
   assign relDirection = ~A[7];

endmodule

module ACRlatch(haltAll,phi1,
                in_nDSA,in_nDAA,inAVR,inACR,inHC,inDir,
                nDSA,nDAA,AVR,ACR,HC,dir);
    input haltAll,phi1,in_nDSA,in_nDAA,inAVR,inACR,inHC,inDir;
    output nDSA,nDAA,AVR,ACR,HC,dir;
    
    reg AVR,ACR,HC,dir = 1'b0;
    reg nDSA,nDAA = 1'b1;
    
    always @ (posedge phi1) begin

        if (haltAll) begin
            AVR <= AVR;
            ACR <= ACR;
            HC <= HC;
            dir <= dir;
            nDSA <= nDSA;
            nDAA <= nDAA;
        end
        else begin
            AVR <= inAVR;
            ACR <= inACR;
            HC <= inHC;
            dir <= inDir;            
            nDSA <= in_nDSA;
            nDAA <= in_nDAA;
            
        end

    end

    

endmodule

module AdderHoldReg(haltAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, 
    addRes,temp_nDSA,temp_nDAA,tempAVR,tempACR,tempHC,tempRel,
		ADL,SB,
    adderReg,alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel);

    input haltAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    input [7:0] addRes;
    input temp_nDSA,temp_nDAA,tempAVR,tempACR,tempHC,tempRel;
    inout [7:0] ADL, SB;
    output [7:0] adderReg;
    output alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel;
    
    wire phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    wire tempAVR,tempACR,tempHC,tempRel;
    wire [7:0] addRes;
    wire [7:0] ADL,SB;
    reg [7:0] adderReg = 8'h00;
    reg alu_nDSA, alu_nDAA, aluAVR,aluACR,aluHC,aluRel = 1'b0;

    always @ (posedge phi2) begin
        if (haltAll) begin
            adderReg <= adderReg;
            aluAVR <= aluAVR;
            aluACR <= aluACR;
            aluHC <= aluHC;
            aluRel <= aluRel;
            alu_nDSA <= alu_nDSA;
            alu_nDAA <= alu_nDAA;
            
        end
        else begin
            adderReg <= addRes;
            aluAVR <= tempAVR;
            aluACR <= tempACR;
            aluHC <= tempHC;
            aluRel <= tempRel;
            alu_nDSA <= temp_nDSA;
            alu_nDAA <= temp_nDAA;
        end

    end

    triState adl[7:0](ADL,adderReg,ADD_ADL);
    triState sb1[6:0](SB[6:0],adderReg[6:0],ADD_SB0to6);
    triState sb2(SB[7],adderReg[7], ADD_SB7);
  
endmodule

// is this sync or async? - async for now
module Areg(O_ADD, SB_ADD, SB,
            outToALU);
            
    input O_ADD, SB_ADD;
    input [7:0] SB;
    output [7:0] outToALU;
  
    wire O_ADD, SB_ADD;
    wire [7:0] SB;
    wire [7:0] outToALU;
    
    assign outToALU = (SB_ADD) ? SB : 8'h00;
  
endmodule

// is this sync or async - async for now
module Breg(DB_L_AD, DB_ADD, ADL_ADD, dataIn, INVdataIn, ADL,
            outToALU);
            
    input DB_L_AD, DB_ADD, ADL_ADD;
    input [7:0] dataIn, INVdataIn;
    input [7:0] ADL;
    output [7:0] outToALU;
    
    wire DB_L_AD, DB_ADD, ADL_ADD;
    wire [7:0] dataIn, INVdataIn, ADL;
    wire [7:0] outToALU;
  
    assign outToALU = DB_L_AD ? INVdataIn :
                        (DB_ADD ? dataIn :
                            (ADL_ADD ? ADL : 8'h00));
    
endmodule


/* -------------------- */
/*

// latched on phi1, driven onto data pins in phi2(if write is done).
module dataOutReg(haltAll,phi2,en,PC_lo,jsrHi,jsrLo,dataIn,
                dataOut);
                
    input haltAll,phi2,en;
    input [7:0] PC_lo;
    input jsrHi, jsrLo;
    input [7:0] dataIn;
    output reg [7:0] dataOut;

    wire nHaltAll;
    not make(nHaltAll,haltAll);
    
    reg [7:0] dataIn_b;
    always @ (dataIn or PC_lo or jsrHi or jsrLo) begin
        if (jsrHi) begin
            dataIn_b = dataIn + (PC_lo == 8'hff);
        end
        else if (jsrLo) begin
            dataIn_b = dataIn + 8'd1;
        end
     
     else dataIn_b = dataIn;
    
        dataIn_b = dataIn;
    end
    
    always @ (posedge phi2) begin
        if (nHaltAll & en) dataOut <= dataIn_b;
        else dataOut <= dataOut;
    
    end
    
endmodule
*/

module dataOutReg(haltAll,phi2, en, dataIn,
                    dataOut);
    input haltAll,phi2,en;
    input [7:0] dataIn;
    output [7:0] dataOut;
    
    wire nHaltAll;
    not make(nHaltAll,haltAll);
    
    FlipFlop8 dor(phi2,dataIn,nHaltAll&en,dataOut);
endmodule

module eDBlatch(phi2, haltAll, extDB, latchRdy,eDB_latch);
    input phi2,haltAll;
    input [7:0] extDB;
    output reg latchRdy = 1'b0;
    output reg [7:0] eDB_latch = 8'd0;

    
    always @ (posedge phi2) begin
      if (haltAll & ~latchRdy) begin
        eDB_latch <= extDB;
        latchRdy <= 1'b1;
      end
      else if (~haltAll & latchRdy) begin
        eDB_latch <= 8'h00; //dummy value
        latchRdy <= 1'b0;
      end
      else eDB_latch <= eDB_latch;
    end
            
endmodule
            
module inputDataLatch(haltAll,data,rstAll, phi2, DL_DB, DL_ADL, DL_ADH,extDataBus,
                        DB,ADL,ADH);
    output [7:0] data; 
    input haltAll,rstAll, phi2, DL_DB, DL_ADL, DL_ADH;
    input [7:0] extDataBus;
    inout [7:0] DB, ADL, ADH;
    
    wire rstAll,phi2,DL_DB, DL_ADL, DL_ADH;
    wire [7:0] extDataBus;
    wire [7:0] DB, ADL, ADH; 
    
    // internal
    reg [7:0] data = 8'h00;

    triState db[7:0](DB,data,DL_DB);
    triState adl[7:0](ADL,data,DL_ADL);
    triState adh[7:0](ADH,data,DL_ADH);
    
    always @ (posedge phi2) begin
        if (haltAll) data <= data;
        else data <= extDataBus;              
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
    reg [7:0] outToIncre = 8'h00;
    
    always @ (*) begin
        outToIncre = (PCL_PCL)? inFromPCL : ADL;
        if (PCL_PCL == ADL_PCL) 
            outToIncre = 8'bzzzzzzzz; //sth is wrong if this happens.
    end
    
    
endmodule
/*
module increment(inc, inAdd,
                carry,outAdd);
                
    input inc;
    input [7:0] inAdd;
    output carry;
    output [7:0] outAdd;
    
    //internal    
    wire [8:0] result;
    
    assign result = inAdd + inc;
    assign carry = result[8];
    assign outAdd = result[7:0];
    
endmodule
*/
module decOrAddADH(inc,dec,inCarry,inAdd,outAdd);
    input inc,dec,inCarry;
    input [7:0] inAdd;
    output reg [7:0] outAdd = 8'd0;
    
    reg carry;
    always @ (*) begin
        if (inc) begin
           {carry,outAdd} = {1'b0,inAdd} + {8'd0,inCarry};
        end
        
        else if (dec) begin
           {carry,outAdd} = {1'b0,inAdd} - {8'd0,inCarry};
        end
        else begin
            outAdd = inAdd;
        end
    end
    
endmodule


module decOrAddADL(inc,dec,inAdd,carry,outAdd);
    input inc,dec;
    input [7:0] inAdd;
    output reg carry = 1'b0;
    output reg [7:0] outAdd = 8'd0;
    
    reg nborrow;
    always @ (*) begin
        if (inc) begin
            {carry,outAdd} = {1'b0,inAdd} + 9'd1;
        end
        else if (dec) begin
           {nborrow,outAdd} = {1'b1,inAdd} - 9'd1;
           if (nborrow == 1) carry = 0; //no rollover
           else carry = 1; //rollover occured.
        end
        else begin
            carry = 1'b0;
            outAdd = inAdd;
        end
    end
    
endmodule
module PC(haltAll,rstAll, phi2, PCL_DB, PCL_ADL,inFromIncre,
            DB, ADL,
            PCout);
            
    input haltAll,rstAll,phi2, PCL_DB, PCL_ADL;
    input [7:0] inFromIncre;
    inout [7:0] DB, ADL;
    output [7:0] PCout;
    
    wire rstAll,phi2, PCL_DB, PCL_ADL;
    wire [7:0] DB, ADL, inFromIncre;
    wire [7:0] PCout;
    
    reg [7:0] currPC = 8'h00;
    triState db[7:0](DB,currPC,PCL_DB);
    triState adl[7:0](ADL,currPC,PCL_ADL);

    assign PCout = currPC;
    
    always @ (posedge phi2) begin
       // if (rstAll) currPC <= 8'h00;
        if (haltAll) currPC <= currPC;
        else currPC <= inFromIncre;
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

module SPreg(haltAll,rstAll,phi2,S_S, SB_S, S_ADL, S_SB, SBin,
            ADL, SB);
            
    input haltAll,rstAll,phi2,S_S, SB_S, S_ADL, S_SB;
    input [7:0] SBin;
    inout [7:0] ADL, SB;
    
    wire rstAll, phi2,S_S, SB_S, S_ADL, S_SB;
    wire [7:0] SBin;
    wire [7:0] ADL, SB;
    
    reg [7:0] latchOut = 8'h00;
    
    triState adl[7:0](ADL,latchOut,S_ADL);
    triState sb[7:0](SB,latchOut,S_SB);

    always @ (posedge phi2) begin
    
        if (haltAll) latchOut <= latchOut;
        else if (SB_S) latchOut <= SBin;
        else latchOut <= latchOut;
                   
    end
    
endmodule

//DSA - Decimal subtract adjust
//DAA - Decimal add adjust
module decimalAdjust(haltAll,SBin, DSA, DAA, ACR, HC, phi2,
                    data);
    
    input haltAll;
    input [7:0] SBin;
    input DSA, DAA, ACR, HC, phi2;
    output reg [7:0] data = 8'd0;
 
    
    //refer to http://imrannazar.com/Binary-Coded-Decimal-Addition-on-Atmel-AVR

    always @ (*) begin
        data = SBin;

        if (DAA) begin
            if (SBin[3:0] > 4'd9 || HC) begin
                data = data + 8'h06;
            end
                
            if (ACR || (SBin > 8'h99)) begin
                data = data + 8'h60;
                // BCD carry has occurred. Do anything??
            end 
        
        end
        
        else if (DSA)//decimal mode
        begin
            if (~HC) begin //always minus, except when HC = 1.
                data = data - 8'h06;
            end
            if (~ACR) begin
            data = data - 8'h60;
            end
        end 
        else data = SBin;
            
        
        
    end

    
endmodule

module accum(haltAll,accumVal,rstAll,phi2,inFromDecAdder, SB_AC, AC_DB, AC_SB,
            DB,SB);
    output [7:0] accumVal;
    input haltAll,rstAll,phi2;
    input [7:0] inFromDecAdder;
    input SB_AC, AC_DB, AC_SB;
    inout [7:0] DB, SB;
    
    wire rstAll,phi2;
    wire [7:0] inFromDecAdder;
    wire SB_AC, AC_DB, AC_SB;
    wire [7:0] DB, SB;
       
    reg [7:0] currAccum = 8'h00;
    
    triState DB_b[7:0](DB,currAccum,AC_DB);
    triState SB_b[7:0](SB,currAccum,AC_SB);

    always @ (posedge phi2) begin
    
        if (haltAll) currAccum <= currAccum;
        else if (SB_AC) currAccum <= inFromDecAdder;
        else currAccum <= currAccum;
 
    end
    
    assign accumVal = currAccum;
endmodule


module AddressBusReg(haltAll,phi1,hold, dataIn,
                dataOut);

    input haltAll,phi1;
    input hold;
    input [7:0] dataIn;
    output [7:0] dataOut;
    
    //wire ce;
    //nor findce(ce,hold,haltAll);
    FlipFlop8 test(phi1,dataIn,~(hold|haltAll),dataOut);
    /*
    reg [7:0] dataOut = 8'd0;
    always @ (posedge phi1) begin
        if (hold|haltAll) dataOut <= dataOut;
        else dataOut <= dataIn;
        
        //dataOut <= (ld) ? dataIn : dataOut;
    end
    
    assign dataABH = (haltAll) ? 8'bzzzzzzzz : dataOut;
*/
endmodule

//used for x and y registers
module register(haltAll,currVal,rstAll,phi2, load, bus_en,SBin,
            SB);
    output [7:0] currVal;
    input haltAll,rstAll,phi2, load, bus_en;
    input [7:0] SBin;
    output [7:0] SB;
   
    wire rstAll,phi2, load, bus_en;
    wire [7:0] SB;
    
    reg [7:0] currVal = 8'h00;
    
    assign SB = (bus_en) ? currVal : 8'bzzzzzzzz;
    
    always @(posedge phi2) begin
        if (rstAll) currVal <= 8'h00;
        else if (haltAll) currVal <= currVal;
        else if (load) currVal <= SBin;
        else currVal <= currVal;
       
    end
   
    
endmodule

//this needs to push out B bit when its a BRK.
//the x_set and x_clr are edge triggered.
//everything else is ticked in when 'update' is asserted.
module statusReg(haltAll,rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ, ALUZ, ACR, AVR, B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr,
                        DB,ALU,storedDB,opcode,DBout,
                        status);
    input haltAll,rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ,ALUZ, ACR, AVR,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr; 
                        
    input [7:0] DB,ALU,storedDB,opcode;
    inout [7:0] DBout;
    output [7:0] status; //used by the FSM
    
    wire rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                    P_DB, DBZ,ALUZ,ACR, AVR,B,
                    C_set, C_clr,
                    I_set,I_clr, 
                    V_clr,
                    D_set,D_clr; 

    wire [7:0] DB,ALU,opcode;
    wire [7:0] DBout;
    wire [7:0] status;
    

    reg currVal7,currVal6,currVal3,currVal2,currVal1,currVal0;
    assign DBout = (P_DB) ? status : 8'bzzzzzzzz;
    assign status = {currVal7,currVal6,1'b1,B,currVal3,currVal2,currVal1,currVal0};

    
    wire class1,class2,class3,class4,class5; //diff classes of opcodes affect diff status bits.
    assign class1 = (opcode == `ADC_abs || opcode == `ADC_abx || opcode == `ADC_aby || opcode == `ADC_imm || 
                 opcode == `ADC_izx || opcode == `ADC_izy || opcode == `ADC_zp  || opcode == `ADC_zpx ||
                 opcode == `SBC_abs || opcode == `SBC_abx || opcode == `SBC_aby || opcode == `SBC_imm || 
                 opcode == `SBC_izx || opcode == `SBC_izy || opcode == `SBC_zp  || opcode == `SBC_zpx );
                 
    assign class2 =  (opcode == `ORA_izx ||opcode == `ORA_izy ||opcode == `ORA_aby ||opcode == `ORA_abx ||
                        opcode == `ORA_abs ||opcode == `ORA_imm ||opcode == `ORA_zp || opcode == `ORA_zpx||
                        opcode == `AND_izx ||opcode == `AND_izy ||opcode == `AND_aby ||opcode == `AND_abx ||
                        opcode == `AND_abs ||opcode == `AND_imm ||opcode == `AND_zp || opcode == `AND_zpx||
                        opcode == `EOR_izx ||opcode == `EOR_izy ||opcode == `EOR_aby ||opcode == `EOR_abx ||
                        opcode == `EOR_abs ||opcode == `EOR_imm ||opcode == `EOR_zp || opcode == `EOR_zpx) ;  
     
    assign class3 = (opcode == `BIT_zp || opcode == `BIT_abs);
    assign class4 = (opcode == `TAX || opcode == `TAY ||  
            opcode == `TXA ||  opcode == `TYA || opcode == `TSX);             
    
    assign class5 = (opcode == `CMP_izx ||opcode == `CMP_izy ||opcode == `CMP_aby ||opcode == `CMP_abx ||
                        opcode == `CMP_abs ||opcode == `CMP_imm ||opcode == `CMP_zp || opcode == `CMP_zpx);
 
    always @ (posedge phi1) begin

      if (rstAll) begin
        currVal7 <= 1'b0;
        currVal6 <= 1'b0;
        currVal3 <= 1'b0;
        currVal2 <= 1'b0;
        currVal1 <= 1'b0;
        currVal0 <= 1'b0;
      end
      else begin
        if (haltAll) begin
          currVal7 <= currVal7;
          currVal6 <= currVal6;
          currVal3 <= currVal3;
          currVal2 <= currVal2;
          currVal1 <= currVal1;
          currVal0 <= currVal0;
        end
        else begin
          currVal7 <= currVal7;
          currVal6 <= currVal6;
          currVal3 <= currVal3;
          currVal2 <= currVal2;
          currVal1 <= currVal1;
          currVal0 <= currVal0;
        
          //N bit
          if (flagsALU) currVal7 <= ALU[7];
          else if (flagsDB) begin
            if (class4) currVal7 <= storedDB[7];
            else currVal7 <= DB[7];
          end
          else if (DB_P) currVal7 <= DB[7];
          
          //V bit
          if (flagsALU & class1) currVal6 <= AVR;
          else if (flagsDB & class3) currVal6 <= DB[6];
          else if (DB_P) currVal6 <= DB[6];
          else if (V_clr) currVal6 <= 1'b0;
          
          //D bit
          if (DB_P) currVal3 <= DB[3];
          else if (D_set) currVal3 <= 1'b1;
          else if (D_clr) currVal3 <= 1'b0;
          
          //I bit
          if (DB_P) currVal2 <= DB[2];
          else if (I_set) currVal2 <= 1'b1;
          else if (I_clr) currVal2 <= 1'b0;
          
          //Z bit
          if (loadDBZ) currVal1 <= DBZ;
          else if (flagsDB) begin
            if (class4) currVal1 <= (storedDB == 8'd0);
            else if (class3) currVal1 <= currVal1;
            else currVal1 <= DBZ;
          end
          else if (flagsALU) currVal1 <= ALUZ;
          else if (DB_P) currVal1 <= DB[1];
          
          //C bit
          if (flagsALU) begin
            if (class2) currVal0 <= currVal0;
            else currVal0 <= ACR;
          end
          else if (DB_P) currVal0 <= DB[0];
          else if (C_set) currVal0 <= 1'b1;
          else if (C_clr) currVal0 <= 1'b0;
        
        end
        
      end

    
	end

         
    


endmodule

/*
//backup
//this needs to push out B bit when its a BRK.
//the x_set and x_clr are edge triggered.
//everything else is ticked in when 'update' is asserted.
module statusReg(haltAll,rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ, ALUZ, ACR, AVR, B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr,
                        DB,ALU,storedDB,opcode,DBout,
                        status);
    output phi1_1,phi1_7;
    input haltAll,rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ,ALUZ, ACR, AVR,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr; 
                        
    input [7:0] DB,ALU,storedDB,opcode;
    inout [7:0] DBout;
    output [7:0] status; //used by the FSM
    
    wire rstAll,phi1,DB_P,loadDBZ,flagsALU,flagsDB,
                    P_DB, DBZ,ALUZ,ACR, AVR,B,
                    C_set, C_clr,
                    I_set,I_clr, 
                    V_clr,
                    D_set,D_clr; 

    wire [7:0] DB,ALU,opcode;
    wire [7:0] DBout;
    wire [7:0] status;
    

    reg currVal7,currVal6,currVal3,currVal2,currVal1,currVal0;
    assign DBout = (P_DB) ? status : 8'bzzzzzzzz;
    assign status = {currVal7,currVal6,1'b1,B,currVal3,currVal2,currVal1,currVal0};

    //Negative
    wire phi1_7,phi1_6,phi1_3,phi1_2,phi1_1,phi1_0;
 
    always @ (posedge phi1) begin
		
		if (haltAll) begin
		      currVal7 <= currVal7;
            currVal6 <= currVal6;
            currVal3 <= currVal3;
            currVal2 <= currVal2;
            currVal1 <= currVal1;
            currVal0 <= currVal0;
		end
       else begin
            currVal7 <= phi1_7;
            currVal6 <= phi1_6;
            currVal3 <= phi1_3;
            currVal2 <= phi1_2;
            currVal1 <= phi1_1;
            currVal0 <= phi1_0;
        end
    end

    
    wire class1,class2,class3,class4,class5; //diff classes of opcodes affect diff status bits.
    assign class1 = (opcode == `ADC_abs || opcode == `ADC_abx || opcode == `ADC_aby || opcode == `ADC_imm || 
                 opcode == `ADC_izx || opcode == `ADC_izy || opcode == `ADC_zp  || opcode == `ADC_zpx ||
                 opcode == `SBC_abs || opcode == `SBC_abx || opcode == `SBC_aby || opcode == `SBC_imm || 
                 opcode == `SBC_izx || opcode == `SBC_izy || opcode == `SBC_zp  || opcode == `SBC_zpx );
                 
    assign class2 =  (opcode == `ORA_izx ||opcode == `ORA_izy ||opcode == `ORA_aby ||opcode == `ORA_abx ||
                        opcode == `ORA_abs ||opcode == `ORA_imm ||opcode == `ORA_zp || opcode == `ORA_zpx||
                        opcode == `AND_izx ||opcode == `AND_izy ||opcode == `AND_aby ||opcode == `AND_abx ||
                        opcode == `AND_abs ||opcode == `AND_imm ||opcode == `AND_zp || opcode == `AND_zpx||
                        opcode == `EOR_izx ||opcode == `EOR_izy ||opcode == `EOR_aby ||opcode == `EOR_abx ||
                        opcode == `EOR_abs ||opcode == `EOR_imm ||opcode == `EOR_zp || opcode == `EOR_zpx) ;  
     
    assign class3 = (opcode == `BIT_zp || opcode == `BIT_abs);
    assign class4 = (opcode == `TAX || opcode == `TAY ||  
            opcode == `TXA ||  opcode == `TYA || opcode == `TSX);             
    
    assign class5 = (opcode == `CMP_izx ||opcode == `CMP_izy ||opcode == `CMP_aby ||opcode == `CMP_abx ||
                        opcode == `CMP_abs ||opcode == `CMP_imm ||opcode == `CMP_zp || opcode == `CMP_zpx);
                        
    //N bit
    wire special_7;
    assign special_7 = storedDB[7];
    assign phi1_7 = loadDBZ ? currVal7 :
                    ((flagsALU) ? ALU[7] :
                    ((flagsDB&class4) ? special_7 :
                     (flagsDB ? DB[7] : 
                     (DB_P ? DB[7] : currVal7))));
    
    //V bit
    assign phi1_6 = loadDBZ ? currVal6 :
                    (flagsALU ? ((class1|class3) ? AVR : currVal6) :
                    (flagsDB ? (class3 ? DB[6] : currVal6) :
                    (DB_P ? DB[6] :  (V_clr ? 1'b0 : currVal6))));
    

    //D bit
    assign phi1_3 = loadDBZ ? currVal3 : 
                    (flagsALU  ? currVal3 : 
                    (flagsDB ? currVal3 :
                    (DB_P ? DB[3] : (D_set ? 1'b1 : (D_clr ? 1'b0 : currVal3)))));
                    

    //I bit
    assign phi1_2 = DB_P ? DB[2] : (I_set ? 1'b1 : (I_clr ? 1'b0 : currVal2));           

    
    //Z bit
    wire special_1;
    assign special_1 = ~(|storedDB);
    assign phi1_1 = loadDBZ ? DBZ :
                    ((flagsDB&class3) ? currVal1 :
                    ((flagsDB&class4) ? special_1 :
                    (flagsDB ? DBZ :
                    (flagsALU ? ALUZ :
                    (DB_P ? DB[1] : currVal1)))));

    //C bit
    assign phi1_0 = loadDBZ ? currVal0 :
                    (flagsALU ?  (class1 ? ACR : (class2 ? currVal0 : ACR)) :
                    (flagsDB ? currVal0 :
                    (DB_P ? DB[0] :
                    (C_set ? 1'b1 : (C_clr ? 1'b0 : currVal0)))));


endmodule

*/

module prechargeMos(rstAll,phi2,
                    bus);
    input rstAll;
    input phi2;
    output [7:0] bus;
    
    wire rstAll;
    wire phi2;
    wire [7:0] bus;
    
    wire [7:0] pull;
    PULLUP inst[7:0](.O(pull));
    
/*
    reg [7:0] pullupReg = 8'h00;
    always @ (posedge rstAll) begin
        pullupReg = 8'hff;
    end
   
    bufif1 (weak1, highz0) a[7:0](bus,pullupReg,1'b1);
 */
    bufif1 a[7:0](bus,pull,phi2); 
endmodule

module opendrainMosADL(rstAll,O_ADL0, O_ADL1, O_ADL2,
                    bus);
    input rstAll;
    input O_ADL0, O_ADL1, O_ADL2;
    output [7:0] bus;
                 
    wire rstAll;
    wire O_ADL0, O_ADL1, O_ADL2;
    wire [7:0] bus;
  /*  
   reg pulldownReg0,pulldownReg1,pulldownReg2 = 1'b0;
    always @ (posedge rstAll) begin
        pulldownReg0 = 1'b0;
        pulldownReg1 = 1'b0;
        pulldownReg2 = 1'b0;
    end
    
    
    bufif1 (highz1, supply0) a(bus[0],pulldownReg0,O_ADL0);
    bufif1 (highz1, supply0) b(bus[1],pulldownReg1,O_ADL1);
    bufif1 (highz1, supply0) c(bus[2],pulldownReg2,O_ADL2);
    */

    wire pull;
    assign pull = 1'b0;
    
    bufif1 a(bus[0],pull,O_ADL0);
    bufif1 b(bus[1],pull,O_ADL1);
    bufif1 c(bus[2],pull,O_ADL2);


endmodule


module opendrainMosADH(rstAll,O_ADH0, O_ADH17,
                    bus);
    input rstAll;
    input O_ADH0, O_ADH17;
    output [7:0] bus;
    
    wire rstAll;
    wire O_ADH0, O_ADH17;
    wire [7:0] bus;
   /* 
    reg pulldownReg0 = 1'b0;
    reg [6:0] pulldownReg17 = 7'b0000000;
    
    always @ (posedge rstAll) begin
        pulldownReg0 = 1'b0;
        pulldownReg17 = 7'b000_0000;
    end
    
    bufif1 (highz1, supply0) a(bus[0],pulldownReg0,O_ADH0);
    bufif1 (highz1, supply0) b[6:0](bus[7:1],pulldownReg17,O_ADH17);
    */

    wire pull;
    //bufif1 d(pull,1'b0,1'b1);
    assign pull = 1'b0;
    bufif1 a(bus[0],pull,O_ADH0);
    bufif1 b[6:0](bus[7:1],pull,O_ADH17);

    
endmodule


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


// Note: Decimal Enable (DAA) not yet understood or implemented
module ALU(A, B, DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS, ALU_out, AVR, ACR, HC);

  input [7:0] A, B;
  input DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS;
  output [7:0] ALU_out;
  output AVR, ACR, HC; 
  
  
  wire [8:0] result;
  assign result = (A + B + I_ADDC) & 9'h1ff;
  wire [4:0] halfResult;
  assign halfResult = (A[3:0] + B[3:0]) & 5'h1f;
  
  
    assign ACR = (SUMS) ? (result[8]) : 
               ((SRS) ? B[0] : 1'b0);
               
    assign HC = halfResult[4];
    assign AVR = (SUMS) ?  ((A[7]==B[7]) & (A[7] != result[7])) : 1'b0;
    assign ALU_out = (SUMS) ? (result[7:0]) :
                           ((ANDS) ? (A&B) : 
                           ((EORS) ? (A^B) :
                           ((ORS) ? (A|B) :
                           ((SRS) ? {I_ADDC, B[7:1]} : 8'hzz))));
  /*  
  always @ (*) begin

    AVR = 1'b0;
    ACR = 1'b0;
    HC = 1'b0;

        // Addition operation: A + B + Cin
        // Perform in two steps to produce half-carry value
        // Overflow if (A[7]==B[7]) && (ALU_out[7]!=A[7]) 
        if (SUMS) begin
          {HC, ALU_out[3:0]} = A[3:0] + B[3:0] + I_ADDC;
          {ACR, ALU_out[7:4]} = A[7:4] + B[7:4] + HC;
          AVR = (A[7]==B[7]) & (A[7]!=ALU_out[7]); 
        end
        else if (ANDS)
          ALU_out = A & B;
        else if (EORS)
          ALU_out = A ^ B;
        else if (ORS)
          ALU_out = A | B;
        else if (SRS) begin// which to shift? A or B? can we just default to A.
          //ALU_out = {1'b0, ALU_out[7:1]};
          ALU_out = {I_ADDC, B[7:1]};
          // need to shift out the carry i thk.
          ACR = B[0];
        end
    
  end
  */
endmodule

module ACRlatch(rstAll,phi1,inAVR,inACR,inHC,AVR,ACR,HC);
    input rstAll,phi1,inAVR,inACR,inHC;
    output AVR,ACR,HC;
    
    reg AVR,ACR,HC = 1'b0;
    
    always @ (posedge phi1) begin
        if (rstAll) begin
            AVR <= 1'b0;
            ACR <= 1'b0;
            HC <= 1'b0;
        end
        else begin
            AVR <= inAVR;
            ACR <= inACR;
            HC <= inHC;        
        end

    end

    

endmodule

module AdderHoldReg(phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, addRes,tempAVR,tempACR,tempHC,
		ADL,SB,adderReg,aluAVR,aluACR,aluHC);

    input phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    input [7:0] addRes;
    input tempAVR,tempACR,tempHC;
    inout [7:0] ADL, SB;
    output [7:0] adderReg;
    output aluAVR,aluACR,aluHC;
    
    wire phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    wire tempAVR,tempACR,tempHC;
    wire [7:0] addRes;
    wire [7:0] ADL,SB;
    reg [7:0] adderReg = 8'h00;
    reg aluAVR,aluACR,aluHC = 1'b0;
  	/*
    always @ (posedge phi2 or posedge rstAll) begin
        adderReg <= (rstAll) ? 8'h00 :
                    ((phi2) ? addRes : adderReg);

        aluAVR <= (rstAll) ? 1'b0 :
                    ((phi2) ? tempAVR : aluAVR);

        aluACR <= (rstAll) ? 1'b0 :
                    ((phi2) ? tempACR : aluACR);

        aluHC <= (rstAll) ? 1'b0 :
                    ((phi2) ? tempHC : aluHC);

    end
    */
    always @ (posedge phi2) begin
        adderReg <= addRes;

        aluAVR <= tempAVR;

        aluACR <= tempACR;

        aluHC <= tempHC;

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


// latched on phi1, driven onto data pins in phi2(if write is done).
module dataOutReg(phi2, en, dataIn,
                dataOut);
                
    input phi2,en;
    input [7:0] dataIn;
    output [7:0] dataOut;

    reg [7:0] data = 8'h00;
    
    always @(posedge phi2) begin
        data <= dataIn;                       
    end
    
    triState b[7:0](dataOut,data,en);
endmodule

module inputDataLatch(data,rstAll, phi2, DL_DB, DL_ADL, DL_ADH,extDataBus,
                        DB,ADL,ADH);
    output [7:0] data; 
    input rstAll, phi2, DL_DB, DL_ADL, DL_ADH;
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
        if (rstAll) data <= 8'h00;
        else data <= extDataBus;
       // data <= (rstAll) ? 8'h00 :
       //          ((phi2) ? extDataBus : data);
                    
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

module PC(rstAll, phi2, PCL_DB, PCL_ADL,inFromIncre,
            DB, ADL,
            PCout);
            
    input rstAll,phi2, PCL_DB, PCL_ADL;
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
        if (rstAll) currPC <= 8'h00;
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

module SPreg(rstAll,phi2,S_S, SB_S, S_ADL, S_SB, SBin,
            ADL, SB);
            
    input rstAll,phi2,S_S, SB_S, S_ADL, S_SB;
    input [7:0] SBin;
    inout [7:0] ADL, SB;
    
    wire rstAll, phi2,S_S, SB_S, S_ADL, S_SB;
    wire [7:0] SBin;
    wire [7:0] ADL, SB;
    
    reg [7:0] latchOut = 8'h00;
    
    triState adl[7:0](ADL,latchOut,S_ADL);
    triState sb[7:0](SB,latchOut,S_SB);

    always @ (posedge phi2) begin
        latchOut <= (rstAll) ? 8'h00 :
                    ((SB_S) ? SBin : latchOut);
                   
    end
    
endmodule

//DSA - Decimal subtract adjust
//DAA - Decimal add adjust
module decimalAdjust(SBin, DSA, DAA, ACR, HC, phi2,
                    dataOut);

    input [7:0] SBin;
    input DSA, DAA, ACR, HC, phi2;
    output [7:0] dataOut;
   
    wire [7:0] SBin;
    wire DSA,DAA,ACR,HC,phi2;
    wire [7:0] dataOut;
    
    //internal
    reg [7:0] data = 8'h00;
    reg iDSA,iDAA =1'b0;
    reg iACR,iHC = 1'b0;
   
    always @ (posedge phi2) begin
        iDAA <= DAA;
        iDSA <= DSA;
        iACR <= ACR;
        iHC <= HC;
    end
    
    //refer to http://imrannazar.com/Binary-Coded-Decimal-Addition-on-Atmel-AVR
    //tada. settled. refer to webstie for more details
    always @ (*) begin
        data = SBin;
        if (iDAA) begin
            if (SBin[3:0] > 4'd9 || iHC) begin
                data = data + 8'h06;
            end
                
            if (iACR || (SBin > 8'h99)) begin
                data = data + 8'h60;
                // BCD carry has occurred. Do anything??
            end 
        
        end
        
        else if (iDSA)//decimal mode
        begin
            if (~iHC) begin //always minus, except when HC = 1.
                data = data - 8'h06;
            end
            if (~iACR) begin
            data = data - 8'h60;
            end
        end 
        //else begin
        //direct pass-through
        //    data = SBin;
        //end
    end
    
    //always @ (posedge phi2) begin
    //    dataOut <= data;
    //end
    assign dataOut = data;

    // this module is a mess!
    
endmodule

module accum(accumVal,rstAll,phi2,inFromDecAdder, SB_AC, AC_DB, AC_SB,
            DB,SB);
    output [7:0] accumVal;
    input rstAll,phi2;
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
        currAccum <= (rstAll) ? 8'h00 :
                    ((SB_AC) ? inFromDecAdder : currAccum);
 
    end
    
    assign accumVal = currAccum;
endmodule


module AddressBusReg(phi1,hold, dataIn,
                dataOut);

    input phi1;
    input hold;
    input [7:0] dataIn;
    output [7:0] dataOut;

    wire phi1;
    wire ld;
    wire [7:0] dataIn;

    reg [7:0] dataOut = 8'h00;
    
    always @ (posedge phi1) begin
        if (hold) dataOut <= dataOut;
        else dataOut <= dataIn;
        
        //dataOut <= (ld) ? dataIn : dataOut;
    end
   
    
endmodule

//used for x and y registers
module register(currVal,rstAll,phi2, load, bus_en,SBin,
            SB);
    output [7:0] currVal;
    input rstAll,phi2, load, bus_en;
    input [7:0] SBin;
    output [7:0] SB;
   
    wire rstAll,phi2, load, bus_en;
    wire [7:0] SB;
    
    reg [7:0] currVal = 8'h00;
    
    assign SB = (bus_en) ? currVal : 8'bzzzzzzzz;
    
    always @(posedge phi2) begin
            currVal <= (rstAll) ? 8'h00 :
                        ((load) ? SBin : currVal);

    end
   
    
endmodule

//this needs to push out B bit when its a BRK.
//the x_set and x_clr are edge triggered.
//everything else is ticked in when 'update' is asserted.
module statusReg(phi1_1,phi2_1,rstAll,fastClk,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ, ALUZ, ACR, AVR, B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr,
                        DB,ALU,opcode,DBinout,
                        status);
    output phi1_1,phi2_1;
    input rstAll,fastClk,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ,ALUZ, ACR, AVR,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_clr,
                        D_set,D_clr; 
                        
    input [7:0] DB,ALU,opcode;
    inout [7:0] DBinout;
    output [7:0] status; //used by the FSM
    
    wire rstAll,fastClk,DB_P,loadDBZ,flagsALU,flagsDB,
                    P_DB, DBZ,ALUZ,ACR, AVR,B,
                    C_set, C_clr,
                    I_set,I_clr, 
                    V_clr,
                    D_set,D_clr; 

    wire [7:0] DB,ALU,opcode;
    wire [7:0] DBinout;
    wire [7:0] status;
    
    // internal
   // wire [7:0] currVal;
//    = 8'b0010_0000;
    
    // bit arrangement: (bit 7) NV_BDIZC (bit 0) - bit 5 has no purpose.
    //assign currVal[4] = B;
    /* 
    always @ (B) begin
        currVal[4] = B;
    end
    

 */
    reg currVal7,currVal6,currVal3,currVal2,currVal1,currVal0;
    assign DBinout = (P_DB) ? status : 8'bzzzzzzzz;
    assign status = {currVal7,currVal6,1'b1,B,currVal3,currVal2,currVal1,currVal0};
    //assign currVal[5] = 1'b1;
    
    
    
    //Negative
    wire phi1_7,phi1_6,phi1_3,phi1_2,phi1_1,phi1_0;
  /*  wire phi2_7,phi2_6,phi2_3,phi2_2,phi2_1,phi2_0;
    
    wire load7,load6,load3,load2,load1,load0;
    assign load7 = ((phi1) ? phi1_7 : ((phi2) ? phi2_7 : 1'b0));
    assign load6 = ((phi1) ? phi1_6 : ((phi2) ? phi2_6 : 1'b0));
    assign load3 = ((phi1) ? phi1_3 : ((phi2) ? phi2_3 : 1'b0));
    assign load2 = ((phi1) ? phi1_2 : ((phi2) ? phi2_2 : 1'b0));
    assign load1 = ((phi1) ? phi1_1 : ((phi2) ? phi2_1 : 1'b0));
    assign load0 = ((phi1) ? phi1_0 : ((phi2) ? phi2_0 : 1'b0));
 */  
    always @ (posedge fastClk) begin
    
        if (rstAll) begin
            currVal7 <= 1'b0;
            currVal6 <= 1'b0;
            currVal3 <= 1'b0;
            currVal2 <= 1'b0;
            currVal1 <= 1'b0;
            currVal0 <= 1'b0;
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

    
    wire class1,class2,class3,class4; //diff classes of opcodes affect diff opcodes.
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
    assign class4 = (opcode == `TAX || opcode == `TAY || opcode == `TSX || 
            opcode == `TXA || opcode == `TXS || opcode == `TYA);             
            
    //N bit
    assign phi1_7 = loadDBZ ? currVal7 :
                    ((flagsALU) ? ALU[7] :
                     (flagsDB ? DB[7] : 
                     (DB_P ? DB[7] : currVal7)));
                     
                     
    //assign phi2_7 = (flagsDB & class4) ? DB[7] : currVal7;
    
    //V bit
    assign phi1_6 = loadDBZ ? currVal6 :
                    (flagsALU ? (class1 ? AVR : (class2 ? currVal6 : AVR)) :
                    (flagsDB ? (class3 ? DB[6] : currVal6) :
                    (DB_P ? DB[6] :  (V_clr ? 1'b0 : currVal6))));
    
   // assign phi2_6 = currVal6;
    
    //D bit
    assign phi1_3 = loadDBZ ? currVal3 : 
                    (flagsALU  ? currVal3 : 
                    (flagsDB ? currVal3 :
                    (DB_P ? DB[3] : (D_set ? 1'b1 : (D_clr ? 1'b0 : currVal3)))));
                    
  //  assign phi2_3 = currVal3;
    
    //I bit
    assign phi1_2 = DB_P ? DB[2] : (I_set ? 1'b1 : (I_clr ? 1'b0 : currVal2));           
   // assign phi2_2 = currVal2;           
    
    //Z bit
    assign phi1_1 = loadDBZ ? DBZ :
                    (flagsALU ? (ALUZ) :
                    (flagsDB ? (class4 ? DBZ  : (class3 ? currVal1 :(DBZ))) :
                    (DB_P ? DB[1] : currVal1)));
                   
    //assign phi2_1 = (flagsDB & class4) ? (DBZ) : currVal1;
    
    //C bit
    assign phi1_0 = loadDBZ ? currVal0 :
                    (flagsALU ?  (class1 ? ACR : (class2 ? currVal0 : ACR)) :
                    (flagsDB ? currVal0 :
                    (DB_P ? DB[0] :
                    (C_set ? 1'b1 : (C_clr ? 1'b0 : currVal0)))));
                    
    //assign phi2_0 = currVal0;
                    
                    
    /*
    always @ (posedge phi1 or posedge phi2) begin
    
        if (phi1) begin
            if (rstAll)  begin
                currVal[7:5] <= 3'b001;
                currVal[3:0] <= 4'b0000;
            end
            
            else if (loadDBZ) begin
             
             
                currVal[`status_Z] <= DBZ;
                //just to keep synthesizer happy.
                currVal[`status_C] <= currVal[`status_C];
                currVal[`status_V] <= currVal[`status_V];
                currVal[`status_N] <= currVal[`status_N];
                currVal[5] <= currVal[5];
                currVal[3] <= currVal[3];
                currVal[2] <= currVal[2];
                
            end
            
            else if (flagsALU) begin
                if (opcode == `ADC_abs || opcode == `ADC_abx || opcode == `ADC_aby || opcode == `ADC_imm || 
                 opcode == `ADC_izx || opcode == `ADC_izy || opcode == `ADC_zp  || opcode == `ADC_zpx ||
                 opcode == `SBC_abs || opcode == `SBC_abx || opcode == `SBC_aby || opcode == `SBC_imm || 
                 opcode == `SBC_izx || opcode == `SBC_izy || opcode == `SBC_zp  || opcode == `SBC_zpx )begin

                    //ADC, SBC - NZCV (ALU)
                    currVal[`status_C] <= ACR;
                    currVal[`status_V] <= AVR;
                    currVal[`status_Z] <= ~(|ALU);
                    currVal[`status_N] <= ALU[7];
                    currVal[5] <= currVal[5];
                    currVal[3] <= currVal[3];
                    currVal[2] <= currVal[2];
                end
                
                else if (opcode == `ORA_izx ||opcode == `ORA_izy ||opcode == `ORA_aby ||opcode == `ORA_abx ||
                        opcode == `ORA_abs ||opcode == `ORA_imm ||opcode == `ORA_zp || opcode == `ORA_zpx||
                        opcode == `AND_izx ||opcode == `AND_izy ||opcode == `AND_aby ||opcode == `AND_abx ||
                        opcode == `AND_abs ||opcode == `AND_imm ||opcode == `AND_zp || opcode == `AND_zpx||
                        opcode == `EOR_izx ||opcode == `EOR_izy ||opcode == `EOR_aby ||opcode == `EOR_abx ||
                        opcode == `EOR_abs ||opcode == `EOR_imm ||opcode == `EOR_zp || opcode == `EOR_zpx) begin
                        
                    //AND,EOR,ORA,=NZ (ALU)

                    currVal[`status_Z] <= ~(|ALU);
                    currVal[`status_N] <= ALU[7];
                    
                    currVal[`status_C] <= currVal[`status_C];
                    currVal[`status_V] <= currVal[`status_V];
                    currVal[5] <= currVal[5];
                    currVal[3] <= currVal[3];
                    currVal[2] <= currVal[2];
                end
                
                else begin//opcode == NZC 
                    //ASL - NZC (ALU)
                    //CMP,CPX,CPY - NZC (ALU)
                    //LSR, ROL, ROR - NZC (ALU)
                    currVal[`status_C] <= ACR;
                    currVal[`status_V] <= AVR;
                    currVal[`status_Z] <= ~(|ALU);
                    currVal[`status_N] <= ALU[7];
                    currVal[5] <= currVal[5];
                    currVal[3] <= currVal[3];
                    currVal[2] <= currVal[2];
                    //NV_BDIZC
                end

            end

            else if (flagsDB) begin

                //INC,INX,INY,DEC,DEX,DEY,LDA,LDX,LDY - NZ 
             
                if (opcode == `BIT_zp || opcode == `BIT_abs) begin
                    currVal[`status_N] <= DB[7];
                    currVal[`status_V] <= DB[6];
                    
                    currVal[`status_C] <= currVal[`status_C];
                    currVal[`status_Z] <= currVal[`status_Z];
                    currVal[5] <= currVal[5];
                    currVal[3] <= currVal[3];
                    currVal[2] <= currVal[2];
                    
                end
                else begin
                    currVal[`status_Z] <= ~(|DB);
                    currVal[`status_N] <= DB[7];
                    
                    currVal[`status_C] <= currVal[`status_C];
                    currVal[`status_V] <= currVal[`status_V];
                    currVal[5] <= currVal[5];
                    currVal[3] <= currVal[3];
                    currVal[2] <= currVal[2];
                    
                end
            end
            else if (DB_P) begin
                currVal[7:5] <= DB[7:5];
                currVal[3:0] <= DB[3:0];
            end
            else begin
                currVal[`status_C] <=  C_set ? 1'b1 : (C_clr ? 1'b0 : currVal[`status_C]);
                currVal[`status_I] <=  I_set ? 1'b1 : (I_clr ? 1'b0 : currVal[`status_I]);
                currVal[`status_V] <=  (V_clr ? 1'b0 : currVal[`status_V]);
                currVal[`status_D] <=  D_set ? 1'b1 : (D_clr ? 1'b0 : currVal[`status_D]);
                
                currVal[5] <= currVal[5];
                currVal[7] <= currVal[7];
                currVal[`status_Z] <= currVal[`status_Z];
                //NV_BDIZC
            end
            
            
        end    
        else if (phi2) begin
            
            
            if ((flagsDB) & (opcode == `TAX || opcode == `TAY || opcode == `TSX || 
            opcode == `TXA || opcode == `TXS || opcode == `TYA)) begin
            
                currVal[`status_Z] <= ~(|DB);
                currVal[`status_N] <= DB[7];
                
                currVal[`status_C] <= currVal[`status_C];
                currVal[`status_V] <= currVal[`status_V];
                currVal[5] <= currVal[5];
                currVal[3] <= currVal[3];
                currVal[2] <= currVal[2];
                
            end


        end
        
    
    end
    */
    


endmodule

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
    buf a[7:0](bus,pull); 
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

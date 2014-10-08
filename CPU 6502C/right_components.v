/****************************************************
 * Project: Atari 5200                              *
 *                                                  *
 * Top Module: 6502C CPU                            *
 * Sub-module: Right-side of diagram (re-org?)      *
 *                                                  *
 * Team Atari                                       *
 *    Alvin Goh     (chuehsig)                   *
 *    Benjamin Hong (bhong)                         *
 *    Jonathan Ong  (jonathao)                      *
 ****************************************************/
 
/* Changelog:
    14 Sep 2014,  1940hrs: verified ALU, AdderReg. Waiting for confirmation from author (jong).
                           Also finished up the other modules except status reg.
    11 Sept 2014, 2300hrs: Updated ALU, AdderHoldReg, Areg, Breg modules (jong)
    11 Sept 2014, 1534hrs: Created modules (chue)
*/



/* Tri-State Buffer
 * Much like a transmition gate, 
 * by asserting "EN", the value of 
 * "A" goes to "Y". Otherwise, a floating
 * output is kept.
 * Size: 6
 */
module TRIBUF (A, EN, Y);
	input A, EN;
	output Y;
	bufif1 g(Y,A,EN);
endmodule



// Note: Decimal Enable (DAA) not yet understood or implemented
module ALU(A, B, DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS, ALU_out, AVR, ACR, HC);

  input [7:0] A, B;
  input DAA, I_ADDC, SUMS, ANDS, EORS, ORS, SRS;
  output reg [7:0] ALU_out;
  output reg AVR, ACR, HC;
  
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
  
endmodule

module AdderHoldReg(rstAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, addRes, ADL,SB);

    input rstAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    input [7:0] addRes;
    inout [7:0] ADL, SB;
    
    wire rstAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    wire [7:0] addRes;
    wire [7:0] ADL,SB;
    
    reg [7:0] adderReg;
  
    always @ (posedge rstAll) begin
        adderReg <= 8'h00;
    end
    always @ (posedge phi2) begin
        adderReg <= addRes;
    end
  
    TRIBUF adl[7:0](adderReg, ADD_ADL, ADL);
    TRIBUF sb1[6:0](adderReg[6:0], ADD_SB0to6, SB[6:0]);
    TRIBUF sb2(adderReg[7], ADD_SB7, SB[7]);
  
endmodule

// is this sync or async? - async for now
module Areg(rstAll, O_ADD, SB_ADD, SB,
            outToALU);
            
    input rstAll, O_ADD, SB_ADD;
    input [7:0] SB;
    output [7:0] outToALU;
  
    wire rstAll, O_ADD, SB_ADD;
    wire [7:0] SB;
    reg [7:0] outToALU;
    
  always @ (*) begin
  // which case should take priority
    if (SB_ADD)
      outToALU <= SB;
    else if (O_ADD)
      outToALU <= 8'h00;
  end
    always @ (posedge rstAll) begin
        outToALU <= 8'h00;
    end
endmodule

// is this sync or async - async for now
module Breg(rstAll, DB_L_AD, DB_ADD, ADL_ADD, dataIn, INVdataIn, ADL,
            outToALU);
            
    input rstAll,DB_L_AD, DB_ADD, ADL_ADD;
    input [7:0] dataIn, INVdataIn;
    input [7:0] ADL;
    output [7:0] outToALU;
    
    wire rstAll,DB_L_AD, DB_ADD, ADL_ADD;
    wire [7:0] dataIn, INVdataIn, ADL;
    reg [7:0] outToALU;
  
  always @ (*) begin
    if (DB_L_AD)
      outToALU <= INVdataIn;
    else if (DB_ADD)
      outToALU <= dataIn;
    else if (ADL_ADD)
      outToALU <= ADL;
  end
    
    always @ (posedge rstAll) begin
        outToALU <= 8'h00;
    end
endmodule


/* -------------------- */


module dataBusTristate(en, dataIn,
                        extDataBus);
                        
    input en;
    input [7:0] dataIn;
    inout [7:0] extDataBus;

    TRIBUF eDatabus[7:0](dataIn,en,extDataBus);
    
endmodule

// latched on phi1, driven onto data pins in phi2(if write is done).
module dataOutReg(rstAll, phi2, en, dataIn,
                dataOut);
                
    input rstAll,phi2,en;
    input [7:0] dataIn;
    output [7:0] dataOut;
    
    wire rstAll,phi2,en;
    wire [7:0] dataIn;
    wire [7:0] dataOut;
    
    reg [7:0] data;
    
    always @(posedge phi2) begin
        data <= dataIn;
    end
    
    assign dataOut = (en) ? data : 8'hzz;

    always @ (posedge rstAll) begin
        data <= 8'h00;
    end
    
    
endmodule

module inputDataLatch(rstAll, phi1, phi2, DL_DB, DL_ADL, DL_ADH,extDataBus,
                        DB,ADL,ADH);
    
    input rstAll,phi1, phi2, DL_DB, DL_ADL, DL_ADH;
    input [7:0] extDataBus;
    inout [7:0] DB, ADL, ADH;
    
    wire rstAll,phi1,phi2,DL_DB, DL_ADL, DL_ADH;
    wire [7:0] extDataBus;
    wire [7:0] DB, ADL, ADH; 
    
    // internal
    reg [7:0] DBreg, ADLreg, ADHreg; 
    reg [7:0] dataDB,dataADL,dataADH;
  
    //TRIBUF db [7:0](dataDB,DL_DB,DB);
    //TRIBUF adl [7:0](dataADL,DL_ADL,ADL);
    //TRIBUF adh [7:0](dataADH,DL_ADH,ADH);
  
    bufif1 db[7:0](DB,dataDB,DL_DB);
    bufif1 adl[7:0](ADL,dataADL,DL_ADL);
    bufif1 adh[7:0](ADH,dataADH,DL_ADH);
    
    always @ (posedge phi2) begin
            dataDB <= extDataBus;
            dataADL <= extDataBus;
            dataADH <= extDataBus;
    end
  
    
    always @ (posedge rstAll) begin
        dataDB <= 8'h00;
        dataADL <= 8'h00;
        dataADH <= 8'h00;
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
    
    wire inc;
    wire [7:0] inAdd;
    reg carry;
    reg [7:0] outAdd;

    //internal    
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
    
    reg [7:0] currPC;
    TRIBUF db[7:0](currPC, PCL_DB, DB);
    //bufif1 (strong1,strong0) testbuf[7:0](DB,PCL_DB,currPC);
    
    //buf weird[7:0](DB,currPC);
    TRIBUF adl[7:0](currPC, PCL_ADL, ADL);

    assign PCout = currPC;
    
    always @ (posedge phi2) begin
        currPC <= inFromIncre;  
    end
    
    always @ (posedge rstAll) begin
        currPC <= 8'h00;
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
    
    reg [7:0] latchOut;
    
    TRIBUF adl[7:0](latchOut, S_ADL, ADL);
    TRIBUF sb[7:0](latchOut, S_SB, SB);
    
    
    
    always @ (posedge phi2) begin
        if (SB_S) latchOut = SBin;
    end
    
    always @ (posedge rstAll) begin
        latchOut <= 8'h00;
    end
    
endmodule

//DSA - Decimal subtract adjust
//DAA - Decimal add adjust
module decimalAdjust(rstAll,SBin, DSA, DAA, ACR, HC, phi2,
                    dataOut);
    input rstAll;
    input [7:0] SBin;
    input DSA, DAA, ACR, HC, phi2;
    output [7:0] dataOut;
    
    wire rstAll;
    wire [7:0] SBin;
    wire DSA,DAA,ACR,HC,phi2;
    wire [7:0] dataOut;
    
    //internal
    reg [7:0] data;
    reg iDSA,iDAA;
    reg iACR,iHC;
   
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
    always @ (posedge rstAll) begin
        data <= 8'h00;
    end
    // this module is a mess!
    
endmodule

module accum(rstAll,phi2,inFromDecAdder, SB_AC, AC_DB, AC_SB,
            DB,SB,updateSR);
    
    input rstAll,phi2;
    input [7:0] inFromDecAdder;
    input SB_AC, AC_DB, AC_SB;
    inout [7:0] DB, SB;
    output updateSR; //prompt SR to update itself according what's on the bus.
    
    wire rstAll,phi2;
    wire [7:0] inFromDecAdder;
    wire SB_AC, AC_DB, AC_SB;
    wire [7:0] DB, SB;
    reg updateSR;
    
    reg [7:0] currAccum;
    
    assign DB = (AC_DB) ? currAccum : 8'bzzzzzzzz;
    assign SB = (AC_SB) ? currAccum : 8'bzzzzzzzz;
        
    
    always @ (posedge phi2) begin
        if (SB_AC) begin
            currAccum = inFromDecAdder;
            updateSR = 1'b1;
        end
        else begin
            updateSR = 1'b0;
        end
    
    end
    
    always @ (posedge rstAll) begin
        currAccum <= 8'h00;
    end
    
    
endmodule


module AddressBusReg(rstAll,phi1,ld, dataIn,
                dataOut);

    input rstAll,phi1;
    input ld;
    input [7:0] dataIn;
    output [7:0] dataOut;

    wire rstAll,phi1;
    wire ld;
    wire [7:0] dataIn;
    wire [7:0] dataOut;
    
    reg [7:0] data;
    
    assign dataOut = data;
    always @ (posedge phi1) begin
        if (ld)data <= dataIn;
    end
    
    always @ (posedge rstAll) begin
        data <= 8'h00;
    end
    
endmodule

/*
//used to force an address to a vector
module AddressBusForce(phi2,dataIn,bus);

    input phi2;
    input [7:0] dataIn;
    output [7:0] bus;
    
    wire phi2;
    wire [7:0] dataIn;
    reg [7:0] bus;
    
    always @ (posedge phi2) begin
        if (dataIn !== `NO_INTERRUPTS) begin
            bus <= dataIn;
        end
        else begin
            bus <= 8'bzzzzzzzz;
        end
        
    end
endmodule
*/


//used for x and y registers
module register(rstAll,phi2, load, bus_en,
            SB,updateSR);
    
    input rstAll,phi2, load, bus_en;
    inout [7:0] SB;
    output updateSR; //prompt SR to update reg according to what's on the bus.
    
    wire rstAll,phi2, load, bus_en;
    wire [7:0] SB;
    reg updateSR;
    
    reg [7:0] currVal;
    
    assign SB = (bus_en) ? currVal : 8'bzzzzzzzz;
    
    always @(posedge phi2) begin
        if (load) begin
            currVal = SB;
            updateSR = 1'b1;
        end
        else begin
            currVal = currVal;
            updateSR = 1'b0;
        end
    end
    
    always @ (posedge rstAll) begin
        currVal <= 8'h00;
    end
    
endmodule

//this needs to push out B bit when its a BRK.
//the x_set and x_clr are edge triggered.
//everything else is ticked in when 'update' is asserted.
module statusReg(rstAll,phi1,phi2,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ, DB_N, ACR, AVR, DAA, B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_set,V_clr,
                        D_set,D_clr,
                        DB,ALU,opcode,DBinout,
                        status);
    
    input rstAll,phi1,phi2,DB_P,loadDBZ,flagsALU,flagsDB,
                        P_DB, DBZ,DB_N, ACR, AVR, DAA,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_set,V_clr,
                        D_set,D_clr; 
                        
    input [7:0] DB,ALU,opcode;
    inout [7:0] DBinout;
    output [7:0] status; //used by the FSM
    
    wire rstAll,phi1,phi2,DB_P,loadDBZ,flagsALU,flagsDB,
                    P_DB, DBZ,DB_N, ACR, AVR, DAA,B,
                    C_set, C_clr,
                    I_set,I_clr, 
                    V_set,V_clr,
                    D_set,D_clr; 

    wire [7:0] DB,ALU,opcode;
    wire [7:0] DBinout;
    wire decMode;
    wire [7:0] status;
    
    // internal
    reg [7:0] currVal;
    
    // bit arrangement: (bit 7) NV_BDIZC (bit 0) - bit 5 has no purpose.
    always @ (posedge C_set) begin
        currVal[`status_C] <= 1'b1;
    end
    
    always @ (posedge C_clr) begin
        currVal[`status_C] <= 1'b0;
    end
    
    always @ (posedge I_set) begin
        currVal[`status_I] <= 1'b1;
    end
    
    always @ (posedge I_clr) begin
        currVal[`status_I] <= 1'b0;
    end
    
    always @ (posedge V_set) begin
        currVal[`status_V] <= 1'b1;
    end
    
    always @ (posedge V_clr) begin
        currVal[`status_V] <= 1'b0;
    end
    
    always @ (posedge D_set) begin
        currVal[`status_D] <= 1'b1;
    end
    
    always @ (posedge D_clr) begin
        currVal[`status_D] <= 1'b0;
    end   
    
    always @ (B) begin
        currVal[4] = B;
    end
    always @ (posedge phi2) begin
        if (opcode == `TAX || opcode == `TAY || opcode == `TSX || 
        opcode == `TXA || opcode == `TXS || opcode == `TYA) begin
        
        currVal[`status_Z] <= ~(|ALU);
        currVal[`status_N] <= ALU[7];
        end
        
    end
    
    always @ (posedge phi1) begin
        
        if (loadDBZ) currVal[`status_Z] <= DBZ;
        
        if (flagsALU) begin
            if (opcode == `ADC_abs || opcode == `ADC_abx || opcode == `ADC_aby || opcode == `ADC_imm || 
             opcode == `ADC_izx || opcode == `ADC_izy || opcode == `ADC_zp  || opcode == `ADC_zpx ||
             opcode == `SBC_abs || opcode == `SBC_abx || opcode == `SBC_aby || opcode == `SBC_imm || 
             opcode == `SBC_izx || opcode == `SBC_izy || opcode == `SBC_zp  || opcode == `SBC_zpx )begin

                //ADC, SBC - NZCV (ALU)
                currVal[`status_C] <= ACR;
                currVal[`status_V] <= AVR;
                currVal[`status_Z] <= ~(|ALU);
                currVal[`status_N] <= ALU[7];
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
            end
            
            else begin//opcode == NZC 
                //ASL - NZC (ALU)
                //CMP,CPX,CPY - NZC (ALU)
                //LSR, ROL, ROR - NZC (ALU)
                currVal[`status_C] <= ACR;
                currVal[`status_V] <= AVR;
                currVal[`status_Z] <= ~(|ALU);
                currVal[`status_N] <= ALU[7];
            end

        end

        if (flagsDB) begin

            //INC,INX,INY,DEC,DEX,DEY,LDA,LDX,LDY - NZ 
         
            if (opcode == `BIT_zp || opcode == `BIT_abs) begin
                currVal[`status_N] <= DB[7];
                currVal[`status_V] <= DB[6];
            end
            else begin
                currVal[`status_Z] <= ~(|DB);
                currVal[`status_N] <= DB[7];
            end
        end
    end

    
    always @ (posedge phi2) begin
        if (DB_P) currVal <= DB;
    end
    always @ (posedge rstAll) begin
        currVal = 8'b0010_0000;
    end
    assign DBinout = (P_DB) ? currVal : 8'bzzzzzzzz;
    assign status = currVal;

endmodule

module prechargeMos(rstAll,phi2,
                    bus);
    input rstAll;
    input phi2;
    output [7:0] bus;
    
    wire rstAll;
    wire phi2;
    wire [7:0] bus;
    
    reg [7:0] pullupReg;
    always @ (posedge rstAll) begin
        pullupReg = 8'hff;
    end
    
    bufif1 (weak1, highz0) a[7:0](bus,pullupReg,phi2);
    //bufif1 (pull1, highz0) a[7:0](bus,8'hff,phi2);

    
    /*
    always @(posedge phi2) begin
        if (bus[7] !== 1'd0 && bus[7] !== 1'd1) bus[7] <= 1'd1;
        else bus[7] <= 1'bz;
        
        if (bus[6] !== 1'd0 && bus[6] !== 1'd1) bus[6] <= 1'd1;
        else bus[6] <= 1'bz;
        
        if (bus[5] !== 1'd0 && bus[5] !== 1'd1) bus[5] <= 1'd1;
        else bus[5] <= 1'bz;
        
        if (bus[4] !== 1'd0 && bus[4] !== 1'd1) bus[4] <= 1'd1;
        else bus[4] <= 1'bz;
        
        if (bus[3] !== 1'd0 && bus[3] !== 1'd1) bus[3] <= 1'd1;
        else bus[3] <= 1'bz;
        
        if (bus[2] !== 1'd0 && bus[2] !== 1'd1) bus[2] <= 1'd1;
        else bus[2] <= 1'bz;
        
        if (bus[1] !== 1'd0 && bus[1] !== 1'd1) bus[1] <= 1'd1;
        else bus[1] <= 1'bz;
        
        if (bus[0] !== 1'd0 && bus[0] !== 1'd1) bus[0] <= 1'd1;
        else bus[0] <= 1'bz;

    end
    always @(phi2) begin
        bus = 8'bZZZZZZZZ;
    end
   */
endmodule

module opendrainMosADL(rstAll,O_ADL0, O_ADL1, O_ADL2,
                    bus);
    input rstAll;
    input O_ADL0, O_ADL1, O_ADL2;
    output [7:0] bus;
                 
    wire rstAll;
    wire O_ADL0, O_ADL1, O_ADL2;
    wire [7:0] bus;
    
   reg pulldownReg0,pulldownReg1,pulldownReg2;
    always @ (posedge rstAll) begin
        pulldownReg0 = 1'b0;
        pulldownReg1 = 1'b0;
        pulldownReg2 = 1'b0;
    end
    
    
    bufif1 (highz1, supply0) a(bus[0],pulldownReg0,O_ADL0);
    bufif1 (highz1, supply0) b(bus[1],pulldownReg1,O_ADL1);
    bufif1 (highz1, supply0) c(bus[2],pulldownReg2,O_ADL2);
    
endmodule


module opendrainMosADH(rstAll,O_ADH0, O_ADH17,
                    bus);
    input rstAll;
    input O_ADH0, O_ADH17;
    output [7:0] bus;
    
    wire rstAll;
    wire O_ADH0, O_ADH17;
    wire [7:0] bus;
    
    reg pulldownReg0;
    reg [6:0] pulldownReg17;
    
    always @ (posedge rstAll) begin
        pulldownReg0 = 1'b0;
        pulldownReg17 = 7'b000_0000;
    end
    
    bufif1 (highz1, supply0) a(bus[0],pulldownReg0,O_ADH0);
    bufif1 (highz1, supply0) b[6:0](bus[7:1],pulldownReg17,O_ADH17);
    
endmodule

// holds bus value over ticks, when drivers get off.
// only for each phi1 tick, restore the prev value. otherwise lines go crazy when precharge mosfets turn off.
module busHold(rstAll,phi1,phi2,busIn,busOut);
    input rstAll;
    input phi1,phi2;
    input [7:0] busIn;
    output [7:0] busOut;
    
    wire rstAll;
    wire phi1,phi2;
    wire [7:0] busIn,busOut;
    
    reg [7:0] busReg;
    
    always @ (busIn) begin
        busReg = busIn;
    end
    always @ (posedge phi1) begin
        
    end
    
    buf (weak1,weak0) buffer[7:0](busOut,busReg);
    
    always @ (posedge rstAll) begin
        busReg <= 8'h00;
    end
    
endmodule


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

`define status_C 3'd0
`define status_Z 3'd1
`define status_I 3'd2
`define status_D 3'd3
`define status_V 3'd6
`define status_N 3'd7

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
          ALU_out = {1'b0, A[7:1]};
          // need to shift out the carry i thk.
          ACR = A[0];
        end
    
  end
  
endmodule

module AdderHoldReg(phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, addRes, ADL,SB);

    input phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    input [7:0] addRes;
    inout [7:0] ADL, SB;
    
    wire phi2, ADD_ADL, ADD_SB0to6, ADD_SB7;
    wire [7:0] addRes;
    wire [7:0] ADL,SB;
    
    reg [7:0] adderReg;
  
    always @ (posedge phi2) begin
        adderReg <= addRes;
    end
  
    TRIBUF adl[7:0](adderReg, ADD_ADL, ADL);
    TRIBUF sb1[6:0](adderReg[6:0], ADD_ADL0to6, SB[6:0]);
    TRIBUF sb2(adderReg[7], ADD_SB7, SB[7]);
  
endmodule

// is this sync or async? - async for now
module Areg(O_ADD, SB_ADD, SB,
            outToALU);
            
    input O_ADD, SB_ADD;
    input [7:0] SB;
    output [7:0] outToALU;
  
    wire O_ADD, SB_ADD;
    wire [7:0] SB;
    reg [7:0] outToALU;
    
  always @ (*) begin
  // which case should take priority
    if (SB_ADD)
      outToALU <= SB;
    else if (O_ADD)
      outToALU <= 8'h00;
  end
    
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
    reg [7:0] outToALU;
  
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

    TRIBUF eDatabus[7:0](dataIn,en,extDataBus);
    
endmodule

// latched on phi1, driven onto data pins in phi2(if write is done).
module dataOutReg(phi1, phi2, dataIn,
                dataOut);
                
    input phi1, phi2;
    input [7:0] dataIn;
    output [7:0] dataOut;
    
    wire phi1,phi2;
    wire [7:0] dataIn;
    reg [7:0] dataOut;
    
    reg [7:0] data;
    
    always @(posedge phi1) begin
        data <= dataIn;
    end
    
    always @(posedge phi2) begin
        dataOut <= data;
    end

endmodule

module inputDataLatch(phi1, phi2, DL_DB, DL_ADL, DL_ADH,extDataBus,
                        DB,ADL,ADH);
    
    input phi1, phi2, DL_DB, DL_ADL, DL_ADH;
    input [7:0] extDataBus;
    inout [7:0] DB, ADL, ADH;
    
    wire phi1,phi2,DL_DB, DL_ADL, DL_ADH;
    wire [7:0] extDataBus;
    wire [7:0] DB, ADL, ADH; 
    
    // internal
    reg [7:0] DBreg, ADLreg, ADHreg; 
    reg [7:0] data;
  
    TRIBUF db [7:0](DBreg,en,DB);
    TRIBUF adl [7:0](ADLreg,en,ADL);
    TRIBUF adh [7:0](ADHreg,en,ADH);
  
    always @ (posedge phi2) begin
            data <= extDataBus;
    end
    
    always @ (posedge phi1) begin
        DBreg <= (DL_DB) ? data : 8'bZZZZZZZZ;
        ADLreg <= (DL_ADL) ? data : 8'bZZZZZZZZ;
        ADHreg <= (DL_ADH) ? data : 8'bZZZZZZZZ;
            
    end
    assign DB = DBreg;
    assign ADL = ADLreg;
    assign ADH = ADHreg;
    
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

module PC(phi2, PCL_DB, PCL_ADL,inFromIncre,
            DB, ADL,
            PCout);
            
    input phi2, PCL_DB, PCL_ADL;
    input [7:0] inFromIncre;
    inout [7:0] DB, ADL;
    output [7:0] PCout;
    
    wire phi2, PCL_DB, PCL_ADL;
    wire [7:0] DB, ADL, inFromIncre;
    wire [7:0] PCout;
    
    reg [7:0] currPC;
    TRIBUF db[7:0](currPC, PCL_DB, DB);
    TRIBUF adl[7:0](currPC, PCL_ADL, ADL);

    assign PCout = currPC;
    
    always @ (posedge phi2) begin
        currPC <= inFromIncre;  
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
    wire [7:0] ADL, SB;
    
    reg [7:0] latchOut;
    
    TRIBUF adl[7:0](latchOut, S_ADL, ADL);
    TRIBUF sb[7:0](latchOut, S_SB, SB);
    
    
    
    always @ (SB_S) begin
        if (SB_S) latchOut = SBin;
    end
    
    
endmodule

//DSA - Decimal subtract adjust
//DAA - Decimal add adjust
module decimalAdjust(SBin, DSA, DAA, ACR, HC, phi2,
                    dataOut);

    input [7:0] SBin;
    input DSA, DAA, ACR, HC, phi2;
    output [7:0] dataOut;
    
    reg [7:0] dataOut;
    
    //internal
    reg [7:0] data;
    
    
    //refer to http://imrannazar.com/Binary-Coded-Decimal-Addition-on-Atmel-AVR
    //tada. settled. refer to webstie for more details
    always @ (*) begin
        if (DAA) begin
            if (SBin[3:0] > 4'd9 || HC) begin
                data = SBin + 8'h06;
            end
                
            if (ACR || (SBin > 8'h99)) begin
                data = data + 8'h60;
                // BCD carry has occurred. Do anything??
            end 
        
        end
        
        else if (DSA)//decimal mode
        begin
            if (SBin[3:0] > 4'd9) begin
                data = SBin - 8'h06;
            end
            if (SBin[7:4] > 4'd9) begin
                data = data - 8'h60;
            end
        end    
    end
    
    always @ (posedge phi2) begin
        dataOut <= data;
    end
    
    // this module is a mess!
    
endmodule

module accum(inFromDecAdder, SB_AC, AC_DB, AC_SB,
            DB,SB,updateSR);
        
    input [7:0] inFromDecAdder;
    input SB_AC, AC_DB, AC_SB;
    inout [7:0] DB, SB;
    output updateSR; //prompt SR to update itself according what's on the bus.
        
    wire [7:0] inFromDecAdder;
    wire SB_AC, AC_DB, AC_SB;
    wire [7:0] DB, SB;
    reg updateSR;
    
    reg [7:0] currAccum;
    
    assign DB = (AC_DB) ? currAccum : 8'bzzzzzzzz;
    assign SB = (AC_SB) ? currAccum : 8'bzzzzzzzz;
        
    
    always @ (SB_AC) begin
        if (SB_AC) begin
            currAccum = inFromDecAdder;
            updateSR = 1'b1;
        end
        else begin
            updateSR = 1'b0;
        end
    
    end
    
endmodule


module AddressBusReg(ld, dataIn,
                dataOut);

    input ld;
    input [7:0] dataIn;
    output [7:0] dataOut;

    wire ld;
    wire [7:0] dataOut;
    reg [7:0] data;
    
    assign dataOut = data;
    always @ (posedge ld) begin
        data <= dataIn;
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
module register(load, bus_en,
            SB,updateSR);
    
    input load, bus_en;
    inout [7:0] SB;
    output updateSR; //prompt SR to update reg according to what's on the bus.
    
    wire load, bus_en;
    wire [7:0] SB;
    reg updateSR;
    
    reg [7:0] currVal;
    
    assign SB = (bus_en) ? currVal : 8'bzzzzzzzz;
    
    always @(load) begin
        if (load) begin
            currVal = SB;
            updateSR = 1'b1;
        end
        else begin
            currVal = currVal;
            updateSR = 1'b0;
        end
    end
    
endmodule

//this needs to push out B bit when its a BRK.
//the x_set and x_clr are edge triggered.
//everything else is ticked in when 'update' is asserted.
module statusReg(phi2,update, P_DB, DBZ, ACR, AVR, DAA,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_set,V_clr,
                        D_set,D_clr,
                        DB_N, 
                        DBin,
                    DBinout,decMode,status);
    
    input phi2,update, P_DB, DBZ, ACR, AVR, DAA,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_set,V_clr,
                        D_set,D_clr,
                        DB_N;
                        
    input [7:0] DBin;
    inout [7:0] DBinout;
    output decMode;
    output [7:0] status; //used by the FSM
    
    wire phi2,update, P_DB, DBZ, ACR, AVR, DAA,B,
                        C_set, C_clr,
                        I_set,I_clr, 
                        V_set,V_clr,
                        D_set,D_clr,
                        DB_N;
    wire [7:0] DBin;
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
    
    always @ (posedge update) begin
       
        currVal[`status_C] <= ACR;
        currVal[`status_Z] <= DBZ;
        //currVal[`status_I] <= IR5;
        currVal[`status_D] <= DAA;
        //currVal[4] <= ((opcode == `BRK || opcode == `PHP) ? 1'b1 : 1'b0); //trying to inject B in..
        currVal[5] <= 1'b1; //default
        currVal[`status_V] <= AVR;
        currVal[`status_N] <= DB_N;
    end
    
    assign DBinout = (P_DB) ? currVal : 8'bzzzzzzzz;
    assign status = currVal;
    assign decMode = currVal[`status_D];
endmodule

module prechargeMos(phi2,
                    bus);
    
    input phi2;
    inout [7:0] bus;
    
    wire phi2;
    wire [7:0] bus;
    
    bufif0 (weak1, highz0) a[7:0](bus,8'hff,phi2);
    
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

module opendrainMosADL(O_ADL0, O_ADL1, O_ADL2,
                    bus);
    
    input O_ADL0, O_ADL1, O_ADL2;
    inout [7:0] bus;
                    
    wire O_ADL0, O_ADL1, O_ADL2;
    wire [7:0] bus;
    
    bufif0 (highz1, strong0) a(bus[0],1'b0,O_ADL0);
    bufif0 (highz1, strong0) b(bus[1],1'b0,O_ADL1);
    bufif0 (highz1, strong0) c(bus[2],1'b0,O_ADL2);
    
endmodule


module opendrainMosADH(O_ADH0, O_ADH17,
                    bus);
    
    input O_ADH0, O_ADH17;
    inout [7:0] bus;
    
    wire O_ADH0, O_ADH17;
    wire [7:0] bus;
    
    bufif0 (highz1, strong0) a(bus[0],1'b0,O_ADH0);
    bufif0 (highz1, strong0) b[6:0](bus[7:1],7'b111_1111,O_ADH17);
    
endmodule



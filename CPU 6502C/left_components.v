// this module contains all contains that are driven by clocks and the left side of the block diagram

`define G1ANDG2 2'd0
`include "Controls/plaFSM.v"

module BUF (Y,A);
    output Y;
    input A;
    buf #(0.5, 0.5) g(Y,A);
endmodule

/* Tri-State Buffer
 * Much like a transmition gate, 
 * by asserting "EN", the value of 
 * "A" goes to "Y". Otherwise, a floating
 * output is kept.
 * Size: 6
 */
module TRIBUF (Y, A, EN);
	output Y;
	input A, EN;
	bufif1 g(Y,A,EN);
endmodule




module clockGen(phi0_in,
                phi1_out,phi2_out,phi1_extout,phi2_extout);
                
    input phi0_in;
    output phi1_out,phi2_out,phi1_extout,phi2_extout;

    wire phi0_in;
    reg phi1_out,phi2_out,phi1_extout,phi2_extout;
    
    buf a(phi1_out,phi0_in);
    not b(phi2_out,phi1_out);
    
    assign phi1_extout = phi1_out;
    assign phi2_extout = phi2_out;
    
endmodule

module predecodeRegister(phi2_in,extDataBus,
                        outToIR);
                        
    input phi2_in;
    input [7:0] extDataBus;
    output outToIR;
    
    always @ (posedge phi2) begin
        outToIR <= extDataBus;
    end
                        
endmodule

module predecodeLogic(irIn, interrupt,
                        irOut);
                        
    input [7:0] irIn;
    input interrupt;
    output [7:0] irOut;
    
    assign irOut = (~interrupt) irIn : 8'd0;
    
endmodule
                        
module instructionRegister(en, inFromPredecode, 
                        outToDecodeRom);
                
    input en; //en - (T2)(phi1)(RDY) not sure!
    input [7:0] inFromPredecode; 
    output [7:0] outToDecodeRom;
    
    always @ (posedge en) begin
        outToDecodeRom <= inFromPredecode;
    end
    
endmodule


/*
module timingGeneration(TZPRE, clockFromControl,
                        SYNC, clockToDecode, clockToControl);
                        
    input TZPRE, clockFromControl;
    output SYNC, clockToDecode, clockToControl;
                        
endmodule

module decodeROM(in, T,
                out);
                
    input [7:0] in;
    input [5:0] T; // goes from T0 til T6. or T5?
    output [129:0] out;
    
    wire [7:0] in;
    wire [5:0] T;
    wire [129:0] out;
    
    assign out[0] = 1  & in[7] &~in[6] &~in[5] &     1 &     1 & in[2] &     1 &     1 &~in[1]&~in[0]; //STY
    assign out[1] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[3]; //T3INDYA
    assign out[2] = 1  &     1 &     1 &     1 & in[4] & in[3] &~in[2] &     1 &     1 & in[0] & T[2]; //T2ABSY
    assign out[3] = 1  & in[7] & in[6] &~in[5] &~in[4] &     1 &     1 &     1 &     1 &~in[1]&~in[0] & T[0]; //T0CPYINY
    assign out[4] = 1  & in[7] &~in[6] &~in[5] & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0TYAA
    assign out[5] = 1  & in[7] &     1 &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0DEYINY
    assign out[6] = 1  &~in[7] &~in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5INT
    assign out[7] = 1  & in[7] &~in[6] &     1 &     1 &     1 &     1 &     1 &     1 & in[1]; //LDXSDX
    assign out[8] = 1  &     1 &     1 &     1 & in[4] &     1 & in[2] &     1 &     1 & T[2]; //T2ANYX
    assign out[9] = 1  &     1 &     1 &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[2]; //T2XIND
    assign out[10] = 1  & in[7] &~in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0TXAA
    assign out[11] = 1  & in[7] & in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0DEX
    assign out[12] = 1  & in[7] & in[6] & in[5] &~in[4] &     1 &     1 &     1 &     1 &~in[1]&~in[0] & T[0]; //T0CPXINX
    assign out[13] = 1  & in[7] &~in[6] &~in[5] & in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0TXS
    assign out[14] = 1  & in[7] &~in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[1]; //SDX
    assign out[15] = 1  & in[7] &~in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[1] & T[0]; //T0TALDTSX
    assign out[16] = 1  & in[7] & in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[1]; //T1DEX
    assign out[17] = 1  & in[7] & in[6] & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[1]; //T1INX
    assign out[18] = 1  & in[7] &~in[6] & in[5] & in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0TSX
    assign out[19] = 1  & in[7] &     1 &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[1]; //T1DEYINY
    assign out[20] = 1  & in[7] &~in[6] & in[5] &     1 &     1 & in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0LDY1
    assign out[21] = 1  & in[7] &~in[6] & in[5] &~in[4] &     1 &     1 &     1 &     1 &~in[1]&~in[0] & T[0]; //T0LDY2TAY
    assign out[22] = 1  &~in[7] &     1 &     1 &~in[4] &     1 &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //CCC
    assign out[23] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0JSR
    assign out[24] = 1  &~in[7] &     1 &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0PSHASHP
    assign out[25] = 1  &~in[7] & in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[4]; //T4RTS
    assign out[26] = 1  &~in[7] &     1 & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[3]; //T3PLAPLPA
    assign out[27] = 1  &~in[7] & in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5RTI
    assign out[28] = 1  &~in[7] & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[1]; //RORRORA
    assign out[29] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2JSR
    assign out[30] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0]; //JMPA
    assign out[31] = 1  &     1 &     1 &     1 &     1 &     1 &     1 &     1 &     1 & T[2]; //T2
    assign out[32] = 1  &     1 &     1 &     1 &~in[4] & in[3] & in[2] &     1 &     1 & T[2]; //T2EXT
    assign out[33] = 1  &~in[7] & in[6] &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //RTIRTS
    assign out[34] = 1  &     1 &     1 &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[4]; //T4XIND
    assign out[35] = 1  &     1 &     1 &     1 &     1 &     1 &     1 &     1 &     1 & T[0]; //T0A
    assign out[36] = 1  &     1 &     1 &     1 &     1 &~in[3] &     1 &     1 &     1 & T[2]; //T2NANYABS
    assign out[37] = 1  &~in[7] & in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[4]; //T4RTIA
    assign out[38] = 1  &~in[7] &~in[6] &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[4]; //T4JSRINT
    assign out[39] = 1  &~in[7] &     1 &     1 &~in[4] &     1 &     1 &     1 &     1 &~in[1]&~in[0] & T[3]; //NAME1:T3_RTI_RTS_JSR_JMP_INT_PULA_PUPL
    assign out[40] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[3]; //T3INDYB
    assign out[41] = 1  &     1 &     1 &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[3]; //T3XIND
    assign out[42] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[4]; //T4INDYA
    assign out[43] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[2]; //T2INDY
    assign out[44] = 1  &     1 &     1 &     1 & in[4] & in[3] &     1 &     1 &     1 & T[3]; //T3ABSXYA
    assign out[45] = 1  &~in[7] &     1 & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //PULAPULP
    assign out[46] = 1  & in[7] & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[1]; //INC
    assign out[47] = 1  &~in[7] & in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0EOR
    assign out[48] = 1  & in[7] & in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0CMP
    assign out[49] = 1  & in[7] & in[6] &     1 &~in[4] &     1 &     1 &     1 &     1 &~in[1]&~in[0] & T[0]; //NAME2:T0_CPX_CPY_INX_INY
    assign out[50] = 1  &     1 & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0ADCSBC
    assign out[51] = 1  & in[7] & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0SBC
    assign out[52] = 1  &~in[7] &~in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[1]; //ROLROLA
    assign out[53] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0] & T[3]; //T3JMP
    assign out[54] = 1  &~in[7] &~in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0ORA
    assign out[55] = 1  &~in[7] &~in[6] &     1 &     1 &     1 &     1 &     1 &     1 & in[1]; //NAME8:ROL_ROLA_ASL_ASLA
    assign out[56] = 1  & in[7] &~in[6] &~in[5] & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0TYAB
    assign out[57] = 1  & in[7] &~in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0TXAB
    assign out[58] = 1  &     1 & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[1]; //T1ADCSBCA
    assign out[59] = 1  &~in[7] &     1 &     1 &     1 &     1 &     1 &     1 &     1 & in[0] & T[1]; //NAME7:T1_AND_EOR_OR_ADC
    assign out[60] = 1  &~in[7] &     1 &     1 &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[1]; //NAME4:T1_ASLA_ROLA_LSRA
    assign out[61] = 1  &~in[7] & in[6] & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0PULA
    assign out[62] = 1  &     1 &     1 &     1 & in[4] & in[3] &     1 &     1 &     1 & T[4]; //T4ABSXYA
    assign out[63] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[5]; //T5INDY
    assign out[64] = 1  & in[7] &~in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0LDA
    assign out[65] = 1  &     1 &     1 &     1 &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0G1
    assign out[66] = 1  &~in[7] &~in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[0]; //T0AND
    assign out[67] = 1  &~in[7] &~in[6] & in[5] &~in[4] &     1 & in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0BITA
    assign out[68] = 1  &~in[7] &     1 &     1 &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //NAME6:T0_ASLA_ROLA_LSRA
    assign out[69] = 1  & in[7] &~in[6] & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0TAX
    assign out[70] = 1  & in[7] &~in[6] & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0TAY
    assign out[71] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[0]; //T0LSRA
    assign out[72] = 1  &~in[7] & in[6] &     1 &     1 &     1 &     1 &     1 &     1 & in[1]; //LSRLSRA
    assign out[73] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5JSRA
    assign out[74] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2BR
    assign out[75] = 1  &~in[7] &~in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2INT
    assign out[76] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[3]; //T3JSR
    assign out[77] = 1  &     1 &     1 &     1 &     1 &~in[3] & in[2] &     1 &     1 & T[2]; //T2ANYZP
    assign out[78] = 1  &     1 &     1 &     1 &     1 &~in[3] &~in[2] &     1 &     1 & in[0] & T[2]; //T2ANYIND
    assign out[79] = 1  &     1 &     1 &     1 &     1 &     1 &     1 &     1 &     1 & T[4]; //T4
    assign out[80] = 1  &     1 &     1 &     1 &     1 &     1 &     1 &     1 &     1 & T[3]; //T3
    assign out[81] = 1  &~in[7] &     1 &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0RTIINT
    assign out[82] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0JMP
    assign out[83] = 1  &~in[7] &     1 &     1 &~in[4] &     1 &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //NAME3:T2_RTI_RTS_JSR_INT_PULA_PUPLP_PSHA_PSHP
    assign out[84] = 1  &~in[7] & in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5RTS
    assign out[85] = 1  &     1 &     1 &     1 &     1 & in[3] &     1 &     1 &     1 & T[2]; //T2ANYABS
    assign out[86] = 1  & in[7] &~in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[0]; //STA
    assign out[87] = 1  &~in[7] & in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2PSHA
    assign out[88] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0BR
    assign out[89] = 1  &~in[7] &     1 &     1 &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //PSHPULA
    assign out[90] = 1  &     1 &     1 &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[5]; //T5XIND
    assign out[91] = 1  &     1 &     1 &     1 &     1 & in[3] &     1 &     1 &     1 & T[3]; //T3ANYABS
    assign out[92] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 & in[0] & T[4]; //T4INDYB
    assign out[93] = 1  &     1 &     1 &     1 & in[4] & in[3] &     1 &     1 &     1 & T[3]; //T3ABSXYB
    assign out[94] = 1  &~in[7] &     1 &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //RTIINT
    assign out[95] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //JSR
    assign out[96] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0]; //JMPB
    assign out[97] = 1  & in[7] & in[6] &     1 &~in[4] &~in[3] &     1 &     1 &     1 &~in[1]&~in[0] & T[1]; //T1CPX2CY2
    assign out[98] = 1  &~in[7] &~in[6] &     1 &~in[4] & in[3] &~in[2] &     1 &     1 & in[1] & T[1]; //T1ASLARLA
    assign out[99] = 1  & in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0] & T[1]; //T1CPX1CY1
    assign out[100] = 1  & in[7] & in[6] &~in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[1]; //T1CMP
    assign out[101] = 1  &     1 & in[6] & in[5] &     1 &     1 &     1 &     1 &     1 & in[0] & T[1]; //T1ADCSBCB
    assign out[102] = 1  &~in[7] &~in[6] &     1 &     1 &     1 &     1 &     1 &     1 & in[1]; //NAME5:ROL_ROLA_ASL_ASLA
    assign out[103] = 1  &     1 & in[6] &     1 &     1 &     1 &     1 &     1 &     1 & in[1]; //LSRRADCIC
    assign out[104] = 1  &~in[7] &~in[6] & in[5] &~in[4] &     1 & in[2] &     1 &     1 &~in[1]&~in[0] & T[1]; //T1BIT
    assign out[105] = 1  &~in[7] &~in[6] &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2PSHP
    assign out[106] = 1  &~in[7] &~in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[4]; //T4INT
    assign out[107] = 1  & in[7] &~in[6] &~in[5] &     1 &     1 &     1 &     1 &     1; //STASTYSTX
    assign out[108] = 1  &     1 &     1 &     1 & in[4] & in[3] &     1 &     1 &     1 & T[4]; //T4ABSXYB
    assign out[109] = 1  &     1 &     1 &     1 &     1 &~in[3] &~in[2] &     1 &     1 & in[0] & T[5]; //T5ANYIND
    assign out[110] = 1  &     1 &     1 &     1 &~in[4] &~in[3] & in[2] &     1 &     1 & T[2]; //T2ZP
    assign out[111] = 1  &     1 &     1 &     1 &~in[4] & in[3] & in[2] &     1 &     1 & T[3]; //T3ABS
    assign out[112] = 1  &     1 &     1 &     1 & in[4] &~in[3] & in[2] &     1 &     1 & T[3]; //T3ZPX
    assign out[113] = 1  &~in[7] &     1 &~in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2PSHASHP
    assign out[114] = 1  &~in[7] & in[6] &     1 &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5RTIRTS
    assign out[115] = 1  &~in[7] &~in[6] & in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T5JSRB
    assign out[116] = 1  &~in[7] & in[6] &     1 &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0] & T[5]; //T4JMP
    assign out[117] = 1  &~in[7] & in[6] &~in[5] &~in[4] & in[3] & in[2] &     1 &     1 &~in[1]&~in[0] & T[2]; //T2JMPABS
    assign out[118] = 1  &~in[7] &     1 & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[3]; //T3PLAPLPB
    assign out[119] = 1  &     1 &     1 &     1 & in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[3]; //T3BR
    assign out[120] = 1  &~in[7] &~in[6] & in[5] &~in[4] &     1 & in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0BITB
    assign out[121] = 1  &~in[7] & in[6] &~in[5] &~in[4] &~in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[4]; //T4RTIB
    assign out[122] = 1  &~in[7] &~in[6] & in[5] &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0PULP
    assign out[123] = 1  &~in[7] &     1 &     1 &~in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //PSHPULB
    assign out[124] = 1  & in[7] &~in[6] & in[5] & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0]; //CLV
    assign out[125] = 1  &~in[7] &~in[6] &     1 & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0CLCSEC
    assign out[126] = 1  &~in[7] & in[6] &     1 & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0CLISEI
    assign out[127] = 1  & in[7] & in[6] &     1 & in[4] & in[3] &~in[2] &     1 &     1 &~in[1]&~in[0] & T[0]; //T0CLDSED
    assign out[128] = 1  &~in[7] &     1 &     1 &     1 &     1 &     1 &     1 &     1; //NI7P
    assign out[129] = 1  &     1 &~in[6] &     1 &     1 &     1 &     1 &     1 &     1; //NI6P
endmodule
*/

module interruptResetControl(phi2,NMI_L, IRQ_L, RES_L,nmiHandled, irqHandled, resHandled,
                            nmi,irq,res);
    input NMI_L,IRQ_L,RES_L;
    input nmiHandled, irqHandled, resHandled;
    output nmi,irq,res;
    
    wire NMI_L,IRQ_L,RES_L;
    
    wire nmiHandled, irqHandled, resHandled;
    reg nmi,irq,res;
    
    reg nmiPending, irqPending, resPending;
    
    always @ (posedge NMI_L) begin //NMI is captured on negedge.
        nmiPending <= NMI_L;
    end
    always (IRQ_L or RES_L) begin
        irqPending = ~IRQ_L;
        resPending = ~RES_L;
    end
    
    always @(negedge phi2) begin
        
        intg = nmiPending & irqPending; //if nmi and irq both asserted, nmi takes priority.
        nmi = intg | nmiPending;
        irq = ~intg & irqPending;
        res = resPending;
        
    end
    
    always @ (nmiHandled or irqHandled or resHandled)
        if (nmiHandled) nmiPending = 1'b0;
        if (irqHandled) irqPending = 1'b0;
        if (resHandled) resPending = 1'b0;
    end
    
endmodule

module readyControl(phi2, RDY,RW,
                    RDYout)
    input phi2;
    input RDY, RW;
    output RDYout;
    
    wire phi2;
    wire RDY,RW;
    reg RDYout;
    
    always @ (posedge phi2) begin
        RDYout <= RDY & RW;
    end
    
endmodule

module randomControl(clock, decoded, interrupt, rdyControl, SV,
                    clock_out, RW, controlSig_t);
                    
    input clock, decoded, interrupt, rdyControl, SV;
    output clock_out, RW;
    output controlSig_t;

endmodule
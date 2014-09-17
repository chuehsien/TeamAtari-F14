// this module contains all contains that are driven by clocks and the left side of the block diagram
// last updated: 17 Sept 2014 1709H; added control signals into decodeROM module (bhong)

`define G1ANDG2 2'd0

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

module decodeROM(in, timing,
				out);
				
	input [7:0] in;
	input [2:0] timing; // goes from T0 til T6. or T5?
	input clock;
	output [129:0] out;
	
	reg [1:0] G;
	case ({in[1],in[0]}) begin
		2'd0: G = 2'd3;
		2'd1: G = 2'd1;
		2'd2: G = 2'd2;
		2'd3: G = `G1ANDG2; // 
	end	
	
	
	assign out[0] = (in == 8'b100xx1xx) & (G==2'd3) & (T==3'dx); // STY
	assign out[1] = (in == 8'bxxx100xx) & (G==2'd1) & (T==3'd3); // T3INDYA
	assign out[2] = (in == 8'bxxx110xx) & (G==2'd1) & (T==3'd2); // T2ABSY
	assign out[3] = (in == 8'b1100xxxx) & (G==2'd3) & (T==3'd0); // T0CPYINY
	assign out[4] = (in == 8'b100110xx) & (G==2'd3) & (T==3'd0); // T0TYAA
	assign out[5] = (in == 8'b1x0010xx) & (G==2'd3) & (T==3'd0); // T0DEYINY
	assign out[6] = (in == 8'b000000xx) & (G==2'd3) & (T==3'd5); // T5INT
	assign out[7] = (in == 8'b10xxxxxx) & (G==2'd2) & (T==3'dx); // LDXSDX
	assign out[8] = (in == 8'bxxx1x1xx) & (G==2'dx) & (T==3'd2); // T2ANYX
	assign out[9] = (in == 8'bxxx000xx) & (G==2'd1) & (T==3'd2); // T2XIND
	assign out[10] = (in == 8'b100010xx) & (G==2'd2) & (T==3'd0); // T0TXAA
	assign out[11] = (in == 8'b110010xx) & (G==2'd2) & (T==3'd0); // T0DEX
	assign out[12] = (in == 8'b1110xxxx) & (G==2'd3) & (T==3'd0); // T0CPXINX
	assign out[13] = (in == 8'b100110xx) & (G==2'd2) & (T==3'd0); // T0TXS 
	assign out[14] = (in == 8'b100xxxxx) & (G==2'd2) & (T==3'dx); // SDX
	assign out[15] = (in == 8'b101xxxxx) & (G==2'd2) & (T==3'd0); // T0TALDTSX
	assign out[16] = (in == 8'b110010xx) & (G==2'd2) & (T==3'd1); // T1DEX
	assign out[17] = (in == 8'b111010xx) & (G==2'd3) & (T==3'd1); // T1INX
	assign out[18] = (in == 8'b101110xx) & (G==2'd2) & (T==3'd0); // T0TSX
	assign out[19] = (in == 8'b1x0010xx) & (G==2'd3) & (T==3'd1); // T1DEYINY
	assign out[20] = (in == 8'b101xx1xx) & (G==2'd3) & (T==3'd0); // T0LDY1
	assign out[21] = (in == 8'b1010xxxx) & (G==2'd3) & (T==3'd0); // T0LDY2TAY
	assign out[22] = (in == 8'b0xx0x0xx) & (G==2'd3) & (T==3'd2); // CCC
	assign out[23] = (in == 8'b001000xx) & (G==2'd3) & (T==3'd0); // T0JSR
	assign out[24] = (in == 8'b0x0010xx) & (G==2'd3) & (T==3'd0); // T0PSHASHP
	assign out[25] = (in == 8'b011000xx) & (G==2'd3) & (T==3'd4); // T4RTS
	assign out[26] = (in == 8'b0x1010xx) & (G==2'd3) & (T==3'd3); // T3PLAPLPA
	assign out[27] = (in == 8'b010000xx) & (G==2'd3) & (T==3'd5); // T5RTI
	assign out[28] = (in == 8'b011xxxxx) & (G==2'd2) & (T==3'dx); // RORRORA
	assign out[29] = (in == 8'b001000xx) & (G==2'd3) & (T==3'd2); // T2JSR
	assign out[30] = (in == 8'b01x011xx) & (G==2'd3) & (T==3'dx); // JMPA
	assign out[31] = (in == 8'bxxxxxxxx) & (G==2'dx) & (T==3'd2); // T2
	assign out[32] = (in == 8'bxxx011xx) & (G==2'dx) & (T==3'd2); // T2EXT
	assign out[33] = (in == 8'b01x000xx) & (G==2'd3) & (T==3'dx); // RTIRTS
	assign out[34] = (in == 8'bxxx000xx) & (G==2'd1) & (T==3'd4); // T4XIND
	assign out[35] = (in == 8'bxxxxxxxx) & (G==2'dx) & (T==3'd0); // T0A
	assign out[36] = (in == 8'bxxxx0xxx) & (G==2'dx) & (T==3'd2); // T2NANYABS
	assign out[37] = (in == 8'b010000xx) & (G==2'd3) & (T==3'd4); // T4RTIA
	assign out[38] = (in == 8'b00x000xx) & (G==2'd3) & (T==3'd4); // T4JSRINT
	assign out[39] = (in == 8'b0xx0xxxx) & (G==2'd3) & (T==3'd3); // NAME1:T3_RTI_RTS_JSR_JMP_INT_PULA_PUPL
	assign out[40] = (in == 8'bxxx100xx) & (G==2'd1) & (T==3'd3); // T3INDYB
	assign out[41] = (in == 8'bXXX000XX) & (G==2'd1) & (T==3'd3); // T3XIND
	assign out[42] = (in == 8'bXXX100XX) & (G==2'd1) & (T==3'd4); // T4INDYA
	assign out[43] = (in == 8'bXXX100XX) & (G==2'd1) & (T==3'd2); // T2INDY
	assign out[44] = (in == 8'bXXX11XXX) & (G==2'dx) & (T==3'd3); // T3ABSXYA
	assign out[45] = (in == 8'b0X1010XX) & (G==2'd3) & (T==3'dx); // PULAPULP
	assign out[46] = (in == 8'b111XXXXX) & (G==2'd2) & (T==3'dx); // INC
	assign out[47] = (in == 8'b010XXXXX) & (G==2'd1) & (T==3'd0); // T0EOR
	assign out[48] = (in == 8'b110XXXXX) & (G==2'd1) & (T==3'd0); // T0CMP
	assign out[49] = (in == 8'b11X0XXXX) & (G==2'd3) & (T==3'd0); // NAME2:T0_CPX_CPY_INX_INY
	assign out[50] = (in == 8'bX11XXXXX) & (G==2'd1) & (T==3'd0); // T0ADCSBC
	assign out[51] = (in == 8'b111XXXXX) & (G==2'd1) & (T==3'd0); // T0SBC
	assign out[52] = (in == 8'b001XXXXX) & (G==2'd2) & (T==3'dx); // ROLROLA
	assign out[53] = (in == 8'b01X011XX) & (G==2'd3) & (T==3'd3); // T3JMP
	assign out[54] = (in == 8'b000XXXXX) & (G==2'd1) & (T==3'd0); // T0ORA
	assign out[55] = (in == 8'b00XXXXXX) & (G==2'd2) & (T==3'dx); // NAME8:ROL_ROLA_ASL_ASLA
	assign out[56] = (in == 8'b100110XX) & (G==2'd3) & (T==3'd0); // T0TYAB
	assign out[57] = (in == 8'b100010XX) & (G==2'd2) & (T==3'd0); // T0TXAB
	assign out[58] = (in == 8'bX11XXXXX) & (G==2'd1) & (T==3'd1); // T1ADCSBCA
	assign out[59] = (in == 8'b0XXXXXXX) & (G==2'd1) & (T==3'd1); // NAME7:T1_AND_EOR_OR_ADC
	assign out[60] = (in == 8'b0XX010XX) & (G==2'd2) & (T==3'd1); // NAME4:T1_ASLA_ROLA_LSRA
	assign out[61] = (in == 8'b011010XX) & (G==2'd3) & (T==3'd0); // T0PULA
	assign out[62] = (in == 8'bXXX11XXX) & (G==2'dx) & (T==3'd4); // T4ABSXYA
	assign out[63] = (in == 8'bXXX100XX) & (G==2'd1) & (T==3'd5); // T5INDY
	assign out[64] = (in == 8'b101XXXXX) & (G==2'd1) & (T==3'd0); // T0LDA
	assign out[65] = (in == 8'bXXXXXXXX) & (G==2'd1) & (T==3'd0); // T0G1
	assign out[66] = (in == 8'b001XXXXX) & (G==2'd1) & (T==3'd0); // T0AND
	assign out[67] = (in == 8'b0010X1XX) & (G==2'd3) & (T==3'd0); // T0BITA
	assign out[68] = (in == 8'b0XX010XX) & (G==2'd2) & (T==3'd0); // NAME6:T0_ASLA_ROLA_LSRA
	assign out[69] = (in == 8'b101010XX) & (G==2'd2) & (T==3'd0); // T0TAX
	assign out[70] = (in == 8'b101010XX) & (G==2'd3) & (T==3'd0); // T0TAY
	assign out[71] = (in == 8'b01X010XX) & (G==2'd2) & (T==3'd0); // T0LSRA
	assign out[72] = (in == 8'b01XXXXXX) & (G==2'd2) & (T==3'dx); // LSRLSRA
	assign out[73] = (in == 8'b001000XX) & (G==2'd3) & (T==3'd5); // T5JSRA
	assign out[74] = (in == 8'bXXX100XX) & (G==2'd3) & (T==3'd2); // T2BR
	assign out[75] = (in == 8'b000000XX) & (G==2'd3) & (T==3'd2); // T2INT
	assign out[76] = (in == 8'b001000XX) & (G==2'd3) & (T==3'd3); // T3JSR
	assign out[77] = (in == 8'bXXXX01XX) & (G==2'dx) & (T==3'd2); // T2ANYZP
	assign out[78] = (in == 8'bXXXX00XX) & (G==2'd1) & (T==3'd2); // T2ANYIND
	assign out[79] = (in == 8'bXXXXXXXX) & (G==2'dx) & (T==3'd4); // T4
	assign out[80] = (in == 8'bXXXXXXXX) & (G==2'dx) & (T==3'd3); // T3
	assign out[81] = (in == 8'b0X0000XX) & (G==2'd3) & (T==3'd0); // T0RTIINT
	assign out[82] = (in == 8'b01X011XX) & (G==2'd3) & (T==3'd0); // T0JMP
	assign out[83] = (in == 8'b0XX0X0XX) & (G==2'd3) & (T==3'd2); // NAME3:T2_RTI_RTS_JSR_INT_PULA_PUPLP_PSHA_PSHP
	assign out[84] = (in == 8'b011000XX) & (G==2'd3) & (T==3'd5); // T5RTS
	assign out[85] = (in == 8'bXXXX1XXX) & (G==2'dx) & (T==3'd2); // T2ANYABS
	assign out[86] = (in == 8'b100XXXXX) & (G==2'd1) & (T==3'dx); // STA
	assign out[87] = (in == 8'b010010XX) & (G==2'd3) & (T==3'd2); // T2PSHA
	assign out[88] = (in == 8'bXXX100XX) & (G==2'd3) & (T==3'd0); // T0BR
	assign out[89] = (in == 8'b0XX010XX) & (G==2'd3) & (T==3'dx); // PSHPULA
	assign out[90] = (in == 8'bXXX000XX) & (G==2'd1) & (T==3'd5); // T5XIND
	assign out[91] = (in == 8'bXXXX1XXX) & (G==2'dx) & (T==3'd3); // T3ANYABS
	assign out[92] = (in == 8'bXXX100XX) & (G==2'd1) & (T==3'd4); // T4INDYB
	assign out[93] = (in == 8'bXXX11XXX) & (G==2'dx) & (T==3'd3); // T3ABSXYB
	assign out[94] = (in == 8'b0X0000XX) & (G==2'd3) & (T==3'dx); // RTIINT
	assign out[95] = (in == 8'b001000XX) & (G==2'd3) & (T==3'dx); // JSR
	assign out[96] = (in == 8'b01X011XX) & (G==2'd3) & (T==3'dx); // JMPB
	assign out[97] = (in == 8'b11X00XXX) & (G==2'd3) & (T==3'd1); // T1CPX2CY2
	assign out[98] = (in == 8'b00X010XX) & (G==2'd2) & (T==3'd1); // T1ASLARLA
	assign out[99] = (in == 8'b11X011XX) & (G==2'd3) & (T==3'd1); // T1CPX1CY1
	assign out[100] = (in == 8'b110XXXXX) & (G==2'd1) & (T==3'd1); // T1CMP
	assign out[101] = (in == 8'bX11XXXXX) & (G==2'd1) & (T==3'd1); // T1ADCSBCB
	assign out[102] = (in == 8'b00XXXXXX) & (G==2'd2) & (T==3'dx); // NAME5:ROL_ROLA_ASL_ASLA
	assign out[103] = (in == 8'bX1XXXXXX) & (G==2'd2) & (T==3'dx); // LSRRADCIC
	assign out[104] = (in == 8'b0010X1XX) & (G==2'd3) & (T==3'd1); // T1BIT
	assign out[105] = (in == 8'b000010XX) & (G==2'd3) & (T==3'd2); // T2PSHP
	assign out[106] = (in == 8'b000000XX) & (G==2'd3) & (T==3'd4); // T4INT
	assign out[107] = (in == 8'b100XXXXX) & (G==2'dx) & (T==3'dx); // STASTYSTX
	assign out[108] = (in == 8'bXXX11XXX) & (G==2'dx) & (T==3'd4); // T4ABSXYB
	assign out[109] = (in == 8'bXXXX00XX) & (G==2'd1) & (T==3'd5); // T5ANYIND
	assign out[110] = (in == 8'bXXX001XX) & (G==2'dx) & (T==3'd2); // T2ZP
	assign out[111] = (in == 8'bXXX011XX) & (G==2'dx) & (T==3'd3); // T3ABS
	assign out[112] = (in == 8'bXXX101XX) & (G==2'dx) & (T==3'd3); // T3ZPX
	assign out[113] = (in == 8'b0X0010XX) & (G==2'd3) & (T==3'd2); // T2PSHASHP
	assign out[114] = (in == 8'b01X000XX) & (G==2'd3) & (T==3'd5); // T5RTIRTS
	assign out[115] = (in == 8'b001000XX) & (G==2'd3) & (T==3'd5); // T5JSRB
	assign out[116] = (in == 8'b01X011XX) & (G==2'd3) & (T==3'd5); // T4JMP
	assign out[117] = (in == 8'b010011XX) & (G==2'd3) & (T==3'd2); // T2JMPABS
	assign out[118] = (in == 8'b0X1010XX) & (G==2'd3) & (T==3'd3); // T3PLAPLPB
	assign out[119] = (in == 8'bXXX100XX) & (G==2'd3) & (T==3'd3); // T3BR
	assign out[120] = (in == 8'b0010X1XX) & (G==2'd3) & (T==3'd0); // T0BITB
	assign out[121] = (in == 8'b010000XX) & (G==2'd3) & (T==3'd4); // T4RTIB
	assign out[122] = (in == 8'b001010XX) & (G==2'd3) & (T==3'd0); // T0PULP
	assign out[123] = (in == 8'b0XX010XX) & (G==2'd3) & (T==3'dx); // PSHPULB
	assign out[124] = (in == 8'b101110XX) & (G==2'd3) & (T==3'dx); // CLV
	assign out[125] = (in == 8'b00X110XX) & (G==2'd3) & (T==3'd0); // T0CLCSEC
	assign out[126] = (in == 8'b01X110XX) & (G==2'd3) & (T==3'd0); // T0CLISEI
	assign out[127] = (in == 8'b11X110XX) & (G==2'd3) & (T==3'd0); // T0CLDSED
	assign out[128] = (in == 8'b0XXXXXXX) & (G==2'dx) & (T==3'dx); // NI7P
	assign out[129] = (in == 8'bX0XXXXXX) & (G==2'dx) & (T==3'dx); // NI6P
	
	
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
//legend: N: normal, R: RMW instruction, B: branch
//
`define BRK       8'h00 //N
`define ORA_izx   8'h01 //N
//`define KIL       8'h02
//`define SLO_izx   8'h03
//`define NOP_zp    8'h04
`define ORA_zp    8'h05 //N
`define ASL_zp    8'h06 //N
//`define SLO_zp    8'h07
`define PHP       8'h08 //N
`define ORA_imm   8'h09 //N
`define ASL       8'h0a //N
//`define ANC_imm   8'h0b
//`define NOP_abs   8'h0c
`define ORA_abs   8'h0d //N
`define ASL_abs   8'h0e //N
//`define SLO_abs   8'h0f
`define BPL_rel   8'h10 //B
`define ORA_izy   8'h11 //R
//`define KIL       8'h12
//`define SLO_izy   8'h13
//`define NOP_zpx   8'h14
`define ORA_zpx   8'h15 //N
`define ASL_zpx   8'h16 //N
//`define SLO_zpx   8'h17
`define CLC       8'h18 //N
`define ORA_aby   8'h19 //R
//`define NOP_2     8'h1a
//`define SLO_aby   8'h1b
//`define NOP_abx   8'h1c
`define ORA_abx   8'h1d //R
`define ASL_abx   8'h1e //N
//`define SLO_abx   8'h1f
`define JSR_abs   8'h20 //N
`define AND_izx   8'h21 //N
//`define KIL       8'h22
//`define RLA_izx   8'h23
`define BIT_zp    8'h24 //N
`define AND_zp    8'h25 //N
`define ROL_zp    8'h26 //N
//`define RLA_zp    8'h27
`define PLP       8'h28 //N
`define AND_imm   8'h29 //N
`define ROL       8'h2a //N
//`define ANC_imm   8'h2b
`define BIT_abs   8'h2c //N
`define AND_abs   8'h2d //N
`define ROL_abs   8'h2e //N
//`define RLA_abs   8'h2f
`define BMI_rel   8'h30 //B
`define AND_izy   8'h31 //R
//`define KIL       8'h32
//`define RLA_izy   8'h33
//`define NOP_zpx   8'h34
`define AND_zpx   8'h35 //N
`define ROL_zpx   8'h36 //N
//`define RLA_zpx   8'h37
`define SEC       8'h38 //N
`define AND_aby   8'h39 //R
//`define NOP       8'h3a
//`define RLA_aby   8'h3b
//`define NOP_abx   8'h3c
`define AND_abx   8'h3d //R
`define ROL_abx   8'h3e //N
//`define RLA_abx   8'h3f
`define RTI       8'h40 //N
`define EOR_izx   8'h41 //N
//`define KIL       8'h42
//`define SRE_izx   8'h43
//`define NOP_zp    8'h44
`define EOR_zp    8'h45 //N
`define LSR_zp    8'h46 //N
//`define SRE_zp    8'h47
`define PHA       8'h48 //N
`define EOR_imm   8'h49 //N
`define LSR       8'h4a //N
//`define ALR_imm   8'h4b
`define JMP_abs   8'h4c //N
`define EOR_abs   8'h4d //N
`define LSR_abs   8'h4e //N
//`define SRE_abs   8'h4f
`define BVC_rel   8'h50 //B
`define EOR_izy   8'h51 //R
//`define KIL       8'h52
//`define SRE_izy   8'h53
//`define NOP_zpx   8'h54
`define EOR_zpx   8'h55 //N
`define LSR_zpx   8'h56 //N
//`define SRE_zpx   8'h57
`define CLI       8'h58 //N
`define EOR_aby   8'h59 //R
//`define NOP       8'h5a
//`define SRE_aby   8'h5b
//`define NOP_abx   8'h5c
`define EOR_abx   8'h5d //R
`define LSR_abx   8'h5e //N
//`define SRE_abx   8'h5f
`define RTS       8'h60 //N
`define ADC_izx   8'h61 //N
//`define KIL       8'h62
//`define RRA_izx   8'h63
//`define NOP_zp    8'h64
`define ADC_zp    8'h65 //N
`define ROR_zp    8'h66 //N
//`define RRA_zp    8'h67
`define PLA       8'h68 //N
`define ADC_imm   8'h69 //N
`define ROR       8'h6a //N
//`define ARR_imm   8'h6b
`define JMP_ind   8'h6c //N
`define ADC_abs   8'h6d //N
`define ROR_abs   8'h6e //N
//`define RRA_abs   8'h6f
`define BVS_rel   8'h70 //B
`define ADC_izy   8'h71 //R
//`define KIL       8'h72
//`define RRA_izy   8'h73
//`define NOP_zpx   8'h74
`define ADC_zpx   8'h75 //N
`define ROR_zpx   8'h76 //N
//`define RRA_zpx   8'h77
`define SEI       8'h78 //N
`define ADC_aby   8'h79 //R
//`define NOP       8'h7a
//`define RRA_aby   8'h7b
//`define NOP_abx   8'h7c
`define ADC_abx   8'h7d //R
`define ROR_abx   8'h7e //N
//`define RRA_abx   8'h7f
//`define NOP_imm   8'h80
`define STA_izx   8'h81 //N
//`define NOP_imm   8'h82
//`define SAX_izx   8'h83
`define STY_zp    8'h84 //N
`define STA_zp    8'h85 //N
`define STX_zp    8'h86 //N
//`define SAX_zp    8'h87
`define DEY       8'h88 //N
//`define NOP_imm   8'h89
`define TXA       8'h8a //N
//`define XAA_imm   8'h8b
`define STY_abs   8'h8c //N
`define STA_abs   8'h8d //N
`define STX_abs   8'h8e //N
//`define SAX_abs   8'h8f
`define BCC_rel   8'h90 //B
//`define STA_izy   8'h91
//`define KIL       8'h92
//`define AHX_izy   8'h93
`define STY_zpx   8'h94 //N
`define STA_zpx   8'h95 //N
`define STX_zpy   8'h96 //N
//`define SAX_zpy   8'h97
`define TYA       8'h98 //N
`define STA_aby   8'h99 //N
`define TXS       8'h9a //N
//`define TAS_aby   8'h9b
//`define SHY_abx   8'h9c
`define STA_abx   8'h9d //N
//`define SHX_aby   8'h9e
//`define AHX_aby   8'h9f
`define LDY_imm   8'ha0 //N
`define LDA_izx   8'ha1 //N
`define LDX_imm   8'ha2 //N
//`define LAX_izx   8'ha3
`define LDY_zp    8'ha4 //N
`define LDA_zp    8'ha5 //N
`define LDX_zp    8'ha6 //N
//`define LAX_zp    8'ha7
`define TAY       8'ha8 //N
`define LDA_imm   8'ha9 //N
`define TAX       8'haa //N
//`define LAX_imm   8'hab
`define LDY_abs   8'hac //N
`define LDA_abs   8'had //N
`define LDX_abs   8'hae //N
//`define LAX_abs   8'haf
`define BCS_rel   8'hb0 //B
`define LDA_izy   8'hb1 //R
//`define KIL       8'hb2
//`define LAX_izy   8'hb3
`define LDY_zpx   8'hb4 //N
`define LDA_zpx   8'hb5 //N
`define LDX_zpy   8'hb6 //N
//`define LAX_zpy   8'hb7
`define CLV       8'hb8 //N
`define LDA_aby   8'hb9 //R
`define TSX       8'hba //N
//`define LAS_aby   8'hbb
`define LDY_abx   8'hbc //R
`define LDA_abx   8'hbd //R
`define LDX_aby   8'hbe //R
//`define LAX_aby   8'hbf
`define CPY_imm   8'hc0 //N
`define CMP_izx   8'hc1 //N
//`define NOP_imm   8'hc2
//`define DCP_izx   8'hc3
`define CPY_zp    8'hc4 //N
`define CMP_zp    8'hc5 //N
`define DEC_zp    8'hc6 //N
//`define DCP_zp    8'hc7
`define INY       8'hc8 //N
`define CMP_imm   8'hc9 //N
`define DEX       8'hca //N
//`define AXS_imm   8'hcb
`define CPY_abs   8'hcc //N
`define CMP_abs   8'hcd //N
`define DEC_abs   8'hce //N
//`define DCP_abs   8'hcf
`define BNE_rel   8'hd0 //B
`define CMP_izy   8'hd1 //R
//`define KIL       8'hd2
//`define DCP_izy   8'hd3
//`define NOP_zpx   8'hd4
`define CMP_zpx   8'hd5 //N
`define DEC_zpx   8'hd6 //N
//`define DCP_zpx   8'hd7
`define CLD       8'hd8 //N
`define CMP_aby   8'hd9 //R
//`define NOP       8'hda
//`define DCP_aby   8'hdb
//`define NOP_abx   8'hdc
`define CMP_abx   8'hdd //R
`define DEC_abx   8'hde //N
//`define DCP_abx   8'hdf
`define CPX_imm   8'he0 //N
`define SBC_izx   8'he1 //N
//`define NOP_imm   8'he2
//`define ISC_izx   8'he3
`define CPX_zp    8'he4 //N
`define SBC_zp    8'he5 //N
`define INC_zp    8'he6 //N
//`define ISC_zp    8'he7
`define INX       8'he8 //N
`define SBC_imm   8'he9 //N
`define NOP       8'hea //N
//`define SBC_imm   8'heb
`define CPX_abs   8'hec //N
`define SBC_abs   8'hed //N
`define INC_abs   8'hee //N
//`define ISC_abs   8'hef
`define BEQ_rel   8'hf0 //B
`define SBC_izy   8'hf1 //R
//`define KIL       8'hf2
//`define ISC_izy   8'hf3
//`define NOP_zpx   8'hf4
`define SBC_zpx   8'hf5 //N
`define INC_zpx   8'hf6 //N
//`define ISC_zpx   8'hf7
`define SED       8'hf8 //N
`define SBC_aby   8'hf9 //R
//`define NOP       8'hfa
//`define ISC_aby   8'hfb
//`define NOP_abx   8'hfc
`define SBC_abx   8'hfd //R
`define INC_abx   8'hfe //N
//`define ISC_abx   8'hff
//
//
//
//
//
//
//

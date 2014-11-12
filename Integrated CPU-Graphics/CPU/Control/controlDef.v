`define DL_DB 7'd0 
`define DL_ADL 7'd1
`define DL_ADH 7'd2

`define O_ADH0 7'd3
`define O_ADH1to7 7'd4

`define nADH_ABH 7'd5
`define nADL_ABL 7'd6
`define PCL_PCL 7'd7
`define ADL_PCL 7'd8
`define nI_PC 7'd9
`define PCL_DB 7'd10
`define PCL_ADL 7'd11
`define PCH_PCH 7'd12
`define ADH_PCH 7'd13
`define PCH_DB 7'd14
`define PCH_ADH 7'd15
`define SB_ADH 7'd16
`define SB_DB 7'd17
`define O_ADL0 7'd18
`define O_ADL1 7'd19
`define O_ADL2 7'd20
`define S_ADL 7'd21
`define SB_S 7'd22
`define S_S 7'd23
`define S_SB 7'd24
`define DB_L_ADD 7'd25
`define DB_ADD 7'd26
`define ADL_ADD 7'd27
`define I_ADDC 7'd28
`define nDAA 7'd29
`define nDSA 7'd30

`define SUMS 7'd31
`define ANDS 7'd32
`define EORS 7'd33
`define ORS 7'd34
`define SRS 7'd35

`define ADD_ADL 7'd36
`define ADD_SB0to6 7'd37
`define ADD_SB7 7'd38
`define O_ADD 7'd39
`define SB_ADD 7'd40
`define SB_AC 7'd41
`define AC_DB 7'd42
`define AC_SB 7'd43
`define SB_X 7'd44
`define X_SB 7'd45
`define SB_Y 7'd46
`define Y_SB 7'd47
`define P_DB 7'd48
`define DB_P 7'd49

`define SET_C 7'd50
`define CLR_C 7'd51
`define SET_I 7'd52
`define CLR_I 7'd53
`define CLR_V 7'd54
`define SET_D 7'd55
`define CLR_D 7'd56
`define SET_B 7'd57
`define CLR_B 7'd58

`define FLAG_DBZ    7'd59
`define FLAG_DBN    7'd60
`define FLAG_DB     7'd61
`define FLAG_ALU    7'd62

`define STORE_DB    7'd63
`define STORE_ALU  7'd64


`define nRW         7'd65
`define DEC_PC      7'd66

`define emptyControl 65'd0
/*
`define DBO_C 6'd49
`define IR5_C 6'd50
`define ACR_C 6'd51
`define DBI_Z 6'd52
`define DBZ_Z 6'd53
`define DB2_I 6'd54
`define IR5_I 6'd55
`define DB3_D 6'd56
`define IR5_D 6'd57
`define DB6_V 6'd58
`define AVR_V 6'd59
`define I_V 6'd60
`define DB7_N 6'd61
*/

`define RST_i 3'd1
`define NMI_i 3'd2
`define IRQ_i 3'd3
`define BRK_i 3'd4
`define NONE 3'd0

`define status_C 3'd0
`define status_Z 3'd1
`define status_I 3'd2
`define status_D 3'd3
`define status_V 3'd6
`define status_N 3'd7

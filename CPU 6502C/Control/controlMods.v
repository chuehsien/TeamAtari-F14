

`include "Control/opcodeTasks.v"


`define status_C 3'd0
`define status_Z 3'd1
`define status_I 3'd2
`define status_D 3'd3
`define status_V 3'd6
`define status_N 3'd7



// differentiates between the 3 kinds of instructions
task instructionType;
	input [7:0] opcode;
	output [2:0] dummy_state;
	
	reg [2:0] dummy_state;
	begin
	if (
		opcode == `ORA_izx ||opcode == `ORA_zp  ||opcode == `ASL_zp  ||opcode == `PHP     ||opcode == `ORA_imm ||
		opcode == `ASL     ||opcode == `ORA_abs ||opcode == `ASL_abs ||opcode == `ORA_zpx ||opcode == `ASL_zpx ||
		opcode == `CLC     ||opcode == `ASL_abx ||opcode == `JSR_abs ||opcode == `AND_izx ||opcode == `BIT_zp  ||
		opcode == `AND_zp  ||opcode == `ROL_zp  ||opcode == `PLP     ||opcode == `AND_imm ||opcode == `ROL     ||
		opcode == `BIT_abs ||opcode == `AND_abs ||opcode == `ROL_abs ||opcode == `AND_zpx ||opcode == `ROL_zpx ||
		opcode == `SEC     ||opcode == `ROL_abx ||opcode == `RTI     ||opcode == `EOR_izx ||opcode == `EOR_zp  ||
		opcode == `LSR_zp  ||opcode == `PHA     ||opcode == `EOR_imm ||opcode == `LSR     ||opcode == `JMP_abs ||
		opcode == `EOR_abs ||opcode == `LSR_abs ||opcode == `EOR_zpx ||opcode == `LSR_zpx ||opcode == `CLI     ||
		opcode == `LSR_abx ||opcode == `RTS     ||opcode == `ADC_izx ||opcode == `ADC_zp  ||opcode == `ROR_zp  ||
		opcode == `PLA     ||opcode == `ADC_imm ||opcode == `ROR     ||opcode == `JMP_zp  ||opcode == `ADC_abs ||
		opcode == `ROR_abs ||opcode == `ADC_zpx ||opcode == `ROR_zpx ||opcode == `SEI     ||opcode == `ROR_abx ||
		opcode == `STA_izx ||opcode == `STY_zp  ||opcode == `STA_zp  ||opcode == `STX_zp  ||opcode == `DEY     ||
		opcode == `TXA     ||opcode == `STY_abs ||opcode == `STA_abs ||opcode == `STX_abs ||opcode == `STA_izy ||opcode == `STY_zpx ||
		opcode == `STA_zpx ||opcode == `STX_zpy ||opcode == `TYA     ||opcode == `STA_aby ||opcode == `TXS     ||
		opcode == `STA_abx ||opcode == `LDY_imm ||opcode == `LDA_izx ||opcode == `LDX_imm ||opcode == `LDY_zp  ||
		opcode == `LDA_zp  ||opcode == `LDX_zp  ||opcode == `TAY     ||opcode == `LDA_imm ||opcode == `TAX     ||
		opcode == `LDY_abs ||opcode == `LDA_abs ||opcode == `LDX_abs ||opcode == `LDY_zpx ||opcode == `LDA_zpx ||
		opcode == `LDX_zpy ||opcode == `CLV     ||opcode == `TSX     ||opcode == `CPY_imm ||opcode == `CMP_izx ||
		opcode == `CPY_zp  ||opcode == `CMP_zp  ||opcode == `DEC_zp  ||opcode == `INY     ||opcode == `CMP_imm ||
		opcode == `DEX     ||opcode == `CPY_abs ||opcode == `CMP_abs ||opcode == `DEC_abs ||opcode == `CMP_zpx ||
		opcode == `DEC_zpx ||opcode == `CLD     ||opcode == `DEC_abx ||opcode == `CPX_imm ||opcode == `SBC_izx ||
		opcode == `CPX_zp  ||opcode == `SBC_zp  ||opcode == `INC_zp  ||opcode == `INX     ||opcode == `SBC_imm ||
		opcode == `NOP     ||opcode == `CPX_abs ||opcode == `SBC_abs ||opcode == `INC_abs ||opcode == `SBC_zpx ||
		opcode == `INC_zpx ||opcode == `SED     ||opcode == `INC_abx)
		dummy_state = `execNorm;
	
	else if (
		opcode == `ORA_izy ||opcode == `ORA_aby ||opcode == `ORA_abx ||opcode == `AND_izy ||opcode == `AND_aby ||opcode == `AND_abx ||
		opcode == `EOR_izy ||opcode == `EOR_aby ||opcode == `EOR_abx ||opcode == `ADC_izy ||opcode == `ADC_aby ||
		opcode == `ADC_abx ||opcode == `LDA_izy ||opcode == `LDA_aby ||opcode == `LDY_abx ||opcode == `LDA_abx ||
		opcode == `LDX_aby ||opcode == `CMP_izy ||opcode == `CMP_aby ||opcode == `CMP_abx ||opcode == `SBC_izy ||
		opcode == `SBC_aby ||opcode == `SBC_abx)
		dummy_state = `execRMW;
		
	else if (
		opcode == `BPL_rel ||opcode == `BMI_rel ||opcode == `BVC_rel ||opcode == `BVS_rel ||opcode == `BCC_rel ||
		opcode == `BCS_rel ||opcode == `BNE_rel ||opcode == `BEQ_rel)
		dummy_state = `execBranch;
		
	else if (opcode == `BRK)
        dummy_state = `execBrk;
    
    else dummy_state = 3'bxxx;
	
	end
	
endtask

//handles the interrupts
task getControlsBrk;
                    				
	input phi1,phi2;
    input [2:0] active_interrupt;
	input [6:0] currT;
	output [6:0] dummy_T;
	output [79:0] dummy_control;
	
	reg [6:0] dummy_T;
	reg [79:0] dummy_control;
	
	begin
		dummy_control = 80'd0;
		dummy_T = 7'dx;
        BRK(currT,phi1,phi2,active_interrupt,dummy_control,dummy_T);
        
    end
        
endtask

// take charge of the control signals for normal instructions.
task getControlsNorm;
				
	input phi1,phi2,decMode,carry,statusC;
	input [7:0] opcode;
	input [6:0] currT;
	output [6:0] dummy_T;
	output [79:0] dummy_control;
	
    
	reg [6:0] dummy_T;
	reg [79:0] dummy_control;
	
	begin
		dummy_control = 80'd0;
		dummy_T = 7'dx;
		case (opcode)
		`ORA_izx: ORA_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`ORA_zp : ORA_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`ASL_zp : ASL_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`PHP    : PHP    (currT,phi1,phi2,dummy_control,dummy_T);
		`ORA_imm: ORA_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`ASL    : ASL    (currT,phi1,phi2,dummy_control,dummy_T);
		`ORA_abs: ORA_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`ASL_abs: ASL_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`ORA_zpx: ORA_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`ASL_zpx: ASL_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`CLC    : CLC    (currT,phi1,phi2,dummy_control,dummy_T);
		`ASL_abx: ASL_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`JSR_abs: JSR_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`AND_izx: AND_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`BIT_zp : BIT_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`AND_zp : AND_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`ROL_zp : ROL_zp (currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`PLP    : PLP    (currT,phi1,phi2,dummy_control,dummy_T);
		`AND_imm: AND_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`ROL    : ROL    (currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`BIT_abs: BIT_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`AND_abs: AND_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`ROL_abs: ROL_abs(currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`AND_zpx: AND_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`ROL_zpx: ROL_zpx(currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`SEC    : SEC    (currT,phi1,phi2,dummy_control,dummy_T);
		`ROL_abx: ROL_abx(currT,phi1,phi2,carry,statusC,dummy_control,dummy_T);
		`RTI    : RTI    (currT,phi1,phi2,dummy_control,dummy_T);
		`EOR_izx: EOR_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`EOR_zp : EOR_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`LSR_zp : LSR_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`PHA    : PHA    (currT,phi1,phi2,dummy_control,dummy_T);
		`EOR_imm: EOR_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`LSR    : LSR    (currT,phi1,phi2,dummy_control,dummy_T);
		`JMP_abs: JMP_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`EOR_abs: EOR_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`LSR_abs: LSR_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`EOR_zpx: EOR_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`LSR_zpx: LSR_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`CLI    : CLI    (currT,phi1,phi2,dummy_control,dummy_T);
		`LSR_abx: LSR_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`RTS    : RTS    (currT,phi1,phi2,dummy_control,dummy_T);
		`ADC_izx: ADC_izx(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`ADC_zp : ADC_zp (currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`ROR_zp : ROR_zp (currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`PLA    : PLA    (currT,phi1,phi2,dummy_control,dummy_T);
		`ADC_imm: ADC_imm(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`ROR    : ROR    (currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`JMP_zp : JMP_zp(currT,phi1,phi2,dummy_control,dummy_T);
		`ADC_abs: ADC_abs(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`ROR_abs: ROR_abs(currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`ADC_zpx: ADC_zpx(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`ROR_zpx: ROR_zpx(currT,phi1,phi2,statusC,dummy_control,dummy_T);
		`SEI    : SEI    (currT,phi1,phi2,dummy_control,dummy_T);
		`ROR_abx: ROR_abx(currT,phi1,phi2,carry,statusC,dummy_control,dummy_T);
		`STA_izx: STA_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`STY_zp : STY_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`STA_zp : STA_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`STX_zp : STX_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`DEY    : DEY    (currT,phi1,phi2,dummy_control,dummy_T);
		`TXA    : TXA    (currT,phi1,phi2,dummy_control,dummy_T);
		`STY_abs: STY_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`STA_abs: STA_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`STX_abs: STX_abs(currT,phi1,phi2,dummy_control,dummy_T);
        `STA_izy: STA_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`STY_zpx: STY_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`STA_zpx: STA_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`STX_zpy: STX_zpy(currT,phi1,phi2,dummy_control,dummy_T);
		`TYA    : TYA    (currT,phi1,phi2,dummy_control,dummy_T);
		`STA_aby: STA_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`TXS    : TXS    (currT,phi1,phi2,dummy_control,dummy_T);
		`STA_abx: STA_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`LDY_imm: LDY_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`LDA_izx: LDA_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`LDX_imm: LDX_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`LDY_zp : LDY_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`LDA_zp : LDA_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`LDX_zp : LDX_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`TAY    : TAY    (currT,phi1,phi2,dummy_control,dummy_T);
		`LDA_imm: LDA_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`TAX    : TAX    (currT,phi1,phi2,dummy_control,dummy_T);
		`LDY_abs: LDY_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`LDA_abs: LDA_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`LDX_abs: LDX_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`LDY_zpx: LDY_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`LDA_zpx: LDA_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`LDX_zpy: LDX_zpy(currT,phi1,phi2,dummy_control,dummy_T);
		`CLV    : CLV    (currT,phi1,phi2,dummy_control,dummy_T);
		`TSX    : TSX    (currT,phi1,phi2,dummy_control,dummy_T);
		`CPY_imm: CPY_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`CMP_izx: CMP_izx(currT,phi1,phi2,dummy_control,dummy_T);
		`CPY_zp : CPY_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`CMP_zp : CMP_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`DEC_zp : DEC_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`INY    : INY    (currT,phi1,phi2,dummy_control,dummy_T);
		`CMP_imm: CMP_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`DEX    : DEX    (currT,phi1,phi2,dummy_control,dummy_T);
		`CPY_abs: CPY_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`CMP_abs: CMP_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`DEC_abs: DEC_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`CMP_zpx: CMP_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`DEC_zpx: DEC_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`CLD    : CLD    (currT,phi1,phi2,dummy_control,dummy_T);
		`DEC_abx: DEC_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`CPX_imm: CPX_imm(currT,phi1,phi2,dummy_control,dummy_T);
		`SBC_izx: SBC_izx(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`CPX_zp : CPX_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`SBC_zp : SBC_zp (currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`INC_zp : INC_zp (currT,phi1,phi2,dummy_control,dummy_T);
		`INX    : INX    (currT,phi1,phi2,dummy_control,dummy_T);
		`SBC_imm: SBC_imm(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`NOP    : NOP    (currT,phi1,phi2,dummy_control,dummy_T);
		`CPX_abs: CPX_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`SBC_abs: SBC_abs(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`INC_abs: INC_abs(currT,phi1,phi2,dummy_control,dummy_T);
		`SBC_zpx: SBC_zpx(currT,phi1,phi2,statusC,decMode,dummy_control,dummy_T);
		`INC_zpx: INC_zpx(currT,phi1,phi2,dummy_control,dummy_T);
		`SED    : SED    (currT,phi1,phi2,dummy_control,dummy_T);
		`INC_abx: INC_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);

		endcase
	end
endtask
	
// take charge of the control signals for RMW instructions.
task getControlsRMW;

	input phi1,phi2,decMode,carry,statusC;
	input [7:0] opcode;
	input [6:0] currT;
	output [6:0] dummy_T;
	output [79:0] dummy_control;
	
	reg [6:0] dummy_T;
	reg [79:0] dummy_control;
	
	begin
		dummy_control = 80'd0;
		dummy_T = 7'dx;
		case (opcode)
		
		`ORA_izy: ORA_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`ORA_aby: ORA_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`ORA_abx: ORA_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`AND_izy: AND_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`AND_aby: AND_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`AND_abx: AND_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`EOR_izy: EOR_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`EOR_aby: EOR_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`EOR_abx: EOR_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`ADC_izy: ADC_izy(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);
		`ADC_aby: ADC_aby(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);
		`ADC_abx: ADC_abx(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);
		`LDA_izy: LDA_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`LDA_aby: LDA_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`LDY_abx: LDY_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`LDA_abx: LDA_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`LDX_aby: LDX_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`CMP_izy: CMP_izy(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`CMP_aby: CMP_aby(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`CMP_abx: CMP_abx(currT,phi1,phi2,carry,dummy_control,dummy_T);
		`SBC_izy: SBC_izy(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);
		`SBC_aby: SBC_aby(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);
		`SBC_abx: SBC_abx(currT,phi1,phi2,carry,statusC,decMode,dummy_control,dummy_T);

		endcase
	
	end
	
endtask

// take charge of the control signals for branch instructions.
task getControlsBranch;
	input phi1,phi2,carry;
	input [7:0] statusReg,opcode;
	input [6:0] currT;
	output [6:0] dummy_T;
	output [79:0] dummy_control;
	
	reg [6:0] dummy_T;
	reg [79:0] dummy_control;
	
	
	begin
		dummy_control = 80'd0;
		dummy_T = 7'dx;
		case (opcode)
			
			`BPL_rel: BPL_rel(currT,phi1,phi2,carry,~statusReg[`status_N],dummy_control,dummy_T);
			`BMI_rel: BMI_rel(currT,phi1,phi2,carry,statusReg[`status_N],dummy_control,dummy_T);
			`BVC_rel: BVC_rel(currT,phi1,phi2,carry,~statusReg[`status_V],dummy_control,dummy_T);
			`BVS_rel: BVS_rel(currT,phi1,phi2,carry,statusReg[`status_V],dummy_control,dummy_T);
			`BCC_rel: BCC_rel(currT,phi1,phi2,carry,~statusReg[`status_C],dummy_control,dummy_T);
			`BCS_rel: BCS_rel(currT,phi1,phi2,carry,statusReg[`status_C],dummy_control,dummy_T);
			`BNE_rel: BNE_rel(currT,phi1,phi2,carry,~statusReg[`status_Z],dummy_control,dummy_T);
			`BEQ_rel: BEQ_rel(currT,phi1,phi2,carry,statusReg[`status_Z],dummy_control,dummy_T);

		
		endcase
	end
endtask

task findLeftOverSig;
    input [7:0] opcode;
    output [7:0] leftOverSigNum;
    
    begin
    leftOverSigNum = 8'hxx;
    
        if  (opcode == `ADC_abs || opcode == `ADC_abx || opcode == `ADC_aby || opcode == `ADC_imm || 
             opcode == `ADC_izx || opcode == `ADC_izy || opcode == `ADC_zp  || opcode == `ADC_zpx ||
             opcode == `SBC_abs || opcode == `SBC_abx || opcode == `SBC_aby || opcode == `SBC_imm || 
             opcode == `SBC_izx || opcode == `SBC_izy || opcode == `SBC_zp  || opcode == `SBC_zpx ||
             opcode == `AND_imm || opcode == `AND_abs || opcode == `AND_abx || opcode == `AND_aby ||
             opcode == `AND_izx || opcode == `AND_izy || opcode == `AND_zp  || opcode == `AND_zpx ||
             opcode == `ORA_imm || opcode == `ORA_abs || opcode == `ORA_abx || opcode == `ORA_aby ||
             opcode == `ORA_izx || opcode == `ORA_izy || opcode == `ORA_zp  || opcode == `ORA_zpx ||
             opcode == `EOR_imm || opcode == `EOR_abs || opcode == `EOR_abx || opcode == `EOR_aby ||
             opcode == `EOR_izx || opcode == `EOR_izy || opcode == `EOR_zp  || opcode == `EOR_zpx ||
             opcode == `ASL     || opcode == `LSR     || opcode == `ROL     || opcode == `ROR     ) begin
                leftOverSigNum = `SB_AC;
             end
             
             
        else if (opcode == `INX || opcode == `DEX) leftOverSigNum = `SB_X;
        else if (opcode == `INY || opcode == `DEY) leftOverSigNum = `SB_Y;
        else leftOverSigNum = `NO_SIG;
             
    end
endtask

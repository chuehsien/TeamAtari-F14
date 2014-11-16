/*
`include "Control/controlDef.v"
`include "Control/TDef.v"
 */
`include "CPU/Control/opcodeDef.v"
`include "CPU/Control/opcodeTasks.v"
task getControls;
                
    input phi1,phi2,dir,carry,statusC,decMode;
    input [2:0] activeInt;
    input [7:0] opcode;
    input [6:0] currT;
    
    output [66:0] dummy_control;
    
    reg [6:0] dummy_T;
    
    begin
        dummy_control = 67'd0;
        dummy_T = `emptyT;
        case (opcode)
        `BRK    : BRK(currT,phi1,phi2,activeInt,dummy_control,dummy_T); 
        
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

        //now the RMW instructions
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
        
        //branch instructions //dont need flags because thats determined by Tcontrol
        `BPL_rel: BPL_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BMI_rel: BMI_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BVC_rel: BVC_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BVS_rel: BVS_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BCC_rel: BCC_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BCS_rel: BCS_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BNE_rel: BNE_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        `BEQ_rel: BEQ_rel(currT,phi1,phi2,dir,carry,1'b0,dummy_control,dummy_T);
        

        endcase
    end
    
endtask
    

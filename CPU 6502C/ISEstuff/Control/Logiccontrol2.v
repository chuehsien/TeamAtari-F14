

module randomLogic2(T,OP,prevOP,phi1,phi2,activeInt,ovf,carry,statusC,decMode,control);
    `include "Control/controlMods.v"
    input [6:0] T;
    input [7:0] OP,prevOP;
    input [2:0] activeInt;
    input phi1,phi2,ovf,carry,statusC,decMode;
    output reg [64:0] control = 65'd0;
    wire updateAC,updateX,updateY;
    
     assign updateAC = (T==`Ttwo) & (prevOP == `ADC_abs || prevOP == `ADC_abx || prevOP == `ADC_aby || prevOP == `ADC_imm || 
             prevOP == `ADC_izx || prevOP == `ADC_izy || prevOP == `ADC_zp  || prevOP == `ADC_zpx ||
             prevOP == `SBC_abs || prevOP == `SBC_abx || prevOP == `SBC_aby || prevOP == `SBC_imm || 
             prevOP == `SBC_izx || prevOP == `SBC_izy || prevOP == `SBC_zp  || prevOP == `SBC_zpx ||
             prevOP == `AND_imm || prevOP == `AND_abs || prevOP == `AND_abx || prevOP == `AND_aby ||
             prevOP == `AND_izx || prevOP == `AND_izy || prevOP == `AND_zp  || prevOP == `AND_zpx ||
             prevOP == `ORA_imm || prevOP == `ORA_abs || prevOP == `ORA_abx || prevOP == `ORA_aby ||
             prevOP == `ORA_izx || prevOP == `ORA_izy || prevOP == `ORA_zp  || prevOP == `ORA_zpx ||
             prevOP == `EOR_imm || prevOP == `EOR_abs || prevOP == `EOR_abx || prevOP == `EOR_aby ||
             prevOP == `EOR_izx || prevOP == `EOR_izy || prevOP == `EOR_zp  || prevOP == `EOR_zpx ||
             prevOP == `ASL     || prevOP == `LSR     || prevOP == `ROL     || prevOP == `ROR     );
             
        assign updateX = (T==`Ttwo) & (prevOP == `INX || prevOP == `DEX);
        assign updateY = (T==`Ttwo) & (prevOP == `INY || prevOP == `DEY);
        
        
    always @ (*) begin
        //getControls(T,OP,phi1,phi2,activeInt,carry,statusC,decMode,control);
        getControls(phi1,phi2,ovf,carry,statusC,decMode,activeInt,OP,T,control);
        //settle prevOP
        
       if (updateAC) control[`SB_AC] = 1'b1;
       else if (updateX) control[`SB_X] = 1'b1;
       else if (updateY) control[`SB_Y] = 1'b1;
        
    end
    
endmodule

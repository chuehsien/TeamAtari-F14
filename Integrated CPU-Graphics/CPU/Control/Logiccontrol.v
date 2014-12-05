module randomLogic(updateOthers,T,OP,prevOP,phi1,phi2,activeInt,dir,carry,statusC,decMode,control);
    `include "CPU/Control/controlMods.v"
    output updateOthers;
    input [6:0] T;
    input [7:0] OP,prevOP;
    input [2:0] activeInt;
    input phi1,phi2,dir,carry,statusC,decMode;
    output reg [66:0] control = 67'd0;
    wire updateAC,updateX,updateY,updateStoredDB,updateOthers,updateDBZ;
    
     assign updateAC = phi1 & (T==`Ttwo) & (prevOP == `ADC_abs || prevOP == `ADC_abx || prevOP == `ADC_aby || prevOP == `ADC_imm || 
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
             
        assign updateX = phi1 &  (T==`Ttwo) & (prevOP == `INX || prevOP == `DEX);
        assign updateY = phi1 & (T==`Ttwo) & (prevOP == `INY || prevOP == `DEY);
   /*      
        assign updateStoredDB =   phi1 & (T==`Ttwo) & (prevOP == `TAX || prevOP == `TAY || prevOP == `TSX || 
            prevOP == `TXA || prevOP == `TXS || prevOP == `TYA);        
        
        assign updateOthers = phi1 & (T==`Ttwo) & (prevOP == `CMP_abs || prevOP == `CMP_abx || prevOP == `CMP_aby || prevOP == `CMP_imm || 
             prevOP == `CMP_izx || prevOP == `CMP_izy || prevOP == `CMP_zp  || prevOP == `CMP_zpx);
  

         assign updateDBZ = phi1 & (T==`Ttwo) & (prevOP == `BIT_zp || prevOP == `BIT_abs); */

    always @ (*) begin
        control = 67'd0;
        //getControls(T,OP,phi1,phi2,activeInt,carry,statusC,decMode,control);
        getControls(phi1,phi2,dir,carry,statusC,decMode,activeInt,OP,T,control);
        //settle prevOP
        
      if (updateAC) begin
        control[`SB_AC] = 1'b1;
       // control[`FLAG_ALU] = 1'b1;
      end
      if (updateX) begin
          control[`SB_X] = 1'b1;
         // control[`FLAG_DB] = 1'b1;
      end
      if (updateY) begin
        control[`SB_Y] = 1'b1;
        //control[`FLAG_DB] = 1'b1;
      end
   //   if (updateStoredDB) control[`FLAG_DB] = 1'b1;
   //   if (updateOthers) control[`FLAG_ALU] = 1'b1;
   //   if (updateDBZ) control[`FLAG_DBZ] = 1'b1;
    end
    
endmodule


     //   randomLogicPredict     predictNext(.nextT(nextT),.nextOpcode(OPtoIR),.currOpcode(opcode),phi1,phi2,activeInt,aluAVR,aluACR,statusReg[`status_C],statusReg[`status_D],nextControlSigs);
        
        //if phi1: use opcode,currT,phi2,AVR,ACR (both latched)to make decisions, 
        // phi1 need to consider prevOpcode too. in this case uses opcode&(nextT == t2).
        
        //if phi2: use opcodeToIR, nextT,phi1,aluAVR,aluACR to make decisions
        
module randomLogicPredict(T,nextT,currOP,nextOP,phi1,phi2,activeInt,latchedAVR,latchedACR,aluholdAVR,aluholdACR,statusC,statusD,control);
    input [6:0] T, nextT;
    input [7:0] currOP,nextOP;
    input phi1,phi2;
    input [2:0] activeInt;
    input latchedAVR,latchedACR,aluholdAVR,aluholdACR,statusC,statusD;
    output reg [65:0] control;
    `include "CPU/Control/controlMods.v"
    
    wire updateAC,updateX,updateY,updateStoredDB,updateOthers,updateDBZ;
    
         assign updateAC = (nextT==`Ttwo) & (currOP == `ADC_abs || currOP == `ADC_abx || currOP == `ADC_aby || currOP == `ADC_imm || 
             currOP == `ADC_izx || currOP == `ADC_izy || currOP == `ADC_zp  || currOP == `ADC_zpx ||
             currOP == `SBC_abs || currOP == `SBC_abx || currOP == `SBC_aby || currOP == `SBC_imm || 
             currOP == `SBC_izx || currOP == `SBC_izy || currOP == `SBC_zp  || currOP == `SBC_zpx ||
             currOP == `AND_imm || currOP == `AND_abs || currOP == `AND_abx || currOP == `AND_aby ||
             currOP == `AND_izx || currOP == `AND_izy || currOP == `AND_zp  || currOP == `AND_zpx ||
             currOP == `ORA_imm || currOP == `ORA_abs || currOP == `ORA_abx || currOP == `ORA_aby ||
             currOP == `ORA_izx || currOP == `ORA_izy || currOP == `ORA_zp  || currOP == `ORA_zpx ||
             currOP == `EOR_imm || currOP == `EOR_abs || currOP == `EOR_abx || currOP == `EOR_aby ||
             currOP == `EOR_izx || currOP == `EOR_izy || currOP == `EOR_zp  || currOP == `EOR_zpx ||
             currOP == `ASL     || currOP == `LSR     || currOP == `ROL     || currOP == `ROR     );
             
        assign updateX = (nextT==`Ttwo) & (currOP == `INX || currOP == `DEX);
        assign updateY = (nextT==`Ttwo) & (currOP == `INY || currOP == `DEY);
        
        assign updateStoredDB = (nextT==`Ttwo) & (currOP == `TAX || currOP == `TAY || currOP == `TSX || 
            currOP == `TXA || currOP == `TXS || currOP == `TYA);        
        
        assign updateOthers = (nextT==`Ttwo) & (currOP == `CMP_abs || currOP == `CMP_abx || currOP == `CMP_aby || currOP == `CMP_imm || 
             currOP == `CMP_izx || currOP == `CMP_izy || currOP == `CMP_zp  || currOP == `CMP_zpx);
         assign updateDBZ = (nextT==`Ttwo) & (currOP == `BIT_zp || currOP == `BIT_abs);
    
    always @ (phi1 or phi2 or latchedAVR or latchedACR or statusC or statusD or activeInt or currOP or T or updateAC or updateX or updateY or updateStoredDB or updateOthers or updateDBZ) begin
        control = 66'd0;
        //get signals for the next phi2
        if (phi1) begin
            //phi1 case
            getControls(1'b0,1'b1,latchedAVR,latchedACR,statusC,statusD,activeInt,currOP,T,control);
                  
        end
        
        //get signals for the next phi1
        else if (phi2) begin
            getControls(1'b1,1'b0,aluholdAVR,aluholdACR,statusC,statusD,activeInt,nextOP,nextT,control);
                  if (updateAC) begin
                    control[`SB_AC] = 1'b1;
                    control[`FLAG_ALU] = 1'b1;
                  end
                  if (updateX) begin
                      control[`SB_X] = 1'b1;
                      control[`FLAG_DB] = 1'b1;
                  end
                  if (updateY) begin
                    control[`SB_Y] = 1'b1;
                    control[`FLAG_DB] = 1'b1;
                  end
                  if (updateStoredDB) control[`FLAG_DB] = 1'b1;
                  if (updateOthers) control[`FLAG_ALU] = 1'b1;
                  if (updateDBZ) control[`FLAG_DBZ] = 1'b1;
        end
        
    
    end
    
    
    
endmodule


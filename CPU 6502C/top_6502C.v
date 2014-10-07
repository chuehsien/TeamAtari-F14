// top module for the 6502C cpu.
// last updated: 09/30/2014 2140H

`include "Control/controlDef.v"
`include "Control/opcodeDef.v"

`include "left_components.v"
`include "right_components.v"
`include "Control/plaFSM.v"
`include "peripherals.v"

module top_6502C(RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in, extDB,	
                phi1_out, SYNC, extAB, phi2_out, RW);
			
			input RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
			inout [7:0] extDB;
            
			output phi1_out, SYNC, phi2_out,RW;
			output [15:0] extAB;
		
        
            wire RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
            wire [7:0] extDB;
            wire [15:0] extAB;
            wire phi1_out, SYNC, phi2_out, RW;
            
            //internal variables
            
            //bus lines
            trireg [7:0]  DB, ADL, ADH, SB;
            
            //control sigs
            wire [79:0] controlSigs;
            wire rstAll;
            
            //interrupt sigs
            wire nmiHandled, irqHandled, resHandled, nmiPending, irqPending, resPending;
            
            assign RW = ~controlSigs[`nRW];

            //clock
            wire phi1,phi2;
			clockGen clock(phi0_in,phi1,phi2,phi1_out,phi2_out);
            
			
            //datapath modules
            inputDataLatch dl(rstAll, phi1,phi2,controlSigs[`DL_DB], controlSigs[`DL_ADL], controlSigs[`DL_ADH],extDB,
                        DB,ADL,ADH);
            
            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(controlSigs[`PCL_PCL], controlSigs[`ADL_PCL], inFromPC_lo, ADL, 
                        outToIncre_lo);
            increment   lo_2(~controlSigs[`nI_PC],outToIncre_lo,PCLC,outToPCL);
            PC          lo_3(rstAll,phi2, controlSigs[`PCL_DB], controlSigs[`PCL_ADL],outToPCL,DB, ADL,inFromPC_lo);
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(controlSigs[`PCH_PCH], controlSigs[`ADH_PCH], inFromPC_hi, ADH, 
                        outToIncre_hi);           
            increment   hi_2(PCLC,outToIncre_hi, ,outToPCH);
            PC          hi_3(rstAll,phi2, controlSigs[`PCH_DB], controlSigs[`PCH_ADH],outToPCH,DB, ADH,inFromPC_hi);
               
            prechargeMos        pcMos1(rstAll,phi2,ADH); 
            prechargeMos        pcMos2(rstAll,phi2,ADL);
            prechargeMos        pcMos3(rstAll,phi2,DB);
            prechargeMos        pcMos4(rstAll,phi2,SB);
            opendrainMosADL     od_lo(rstAll,controlSigs[`O_ADL0],controlSigs[`O_ADL1],controlSigs[`O_ADL2],ADL);
            opendrainMosADH     od_hi(rstAll,controlSigs[`O_ADH0],controlSigs[`O_ADH1to7],ADH);
            tranif1             pass1[7:0](SB, ADH, controlSigs[`SB_ADH]);
            tranif1             pass2[7:0](SB, DB, controlSigs[`SB_DB]);
            
            wire [7:0] A, B, ALU_out;
            wire AVR,ACR,HC; //will be connected to status reg
            ALU     my_alu(A, B, ~controlSigs[`nDAA], controlSigs[`I_ADDC], controlSigs[`SUMS], 
                        controlSigs[`ANDS], controlSigs[`EORS], controlSigs[`ORS], 
                            controlSigs[`SRS], ALU_out, AVR, ACR, HC);
            
            
            //registers
            SPreg   sp(rstAll,phi2,controlSigs[`S_S], controlSigs[`SB_S], controlSigs[`S_ADL], 
                        controlSigs[`S_SB], SB, ADL, SB);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(rstAll,controlSigs[`DB_L_ADD], controlSigs[`DB_ADD], controlSigs[`ADL_ADD], DB,nDB,ADL,B);
            
            Areg    a_reg(rstAll,controlSigs[`O_ADD], controlSigs[`SB_ADD], SB, A);
            
   
            AdderHoldReg addHold(rstAll, phi2, controlSigs[`ADD_ADL], controlSigs[`ADD_SB0to6], controlSigs[`ADD_SB7], ALU_out,
                                ADL,SB);
            
            wire [7:0] inFromDecAdder;
            wire updateSR_accum, updateSR_x, updateSR_y;
            /*
            wire DAAmode, DSAmode;
            assign DAAmode = SR_contents[`status_D] & 
                                (activeOpcode == `ADC_imm ||
                                activeOpcode == `ADC_zp ||
                                activeOpcode == `ADC_zpx ||
                                activeOpcode == `ADC_ ||
                                activeOpcode == `ADC_imm ||
                                activeOpcode == `ADC_imm ||
                                activeOpcode == `ADC_imm ||
                                
            activeOpcode*/
            
            decimalAdjust   decAdj(rstAll,SB, ~controlSigs[`nDSA], ~controlSigs[`nDAA], ACR, HC, phi2,inFromDecAdder);
            accum           a(rstAll,phi2,inFromDecAdder, controlSigs[`SB_AC], controlSigs[`AC_DB], controlSigs[`AC_SB],
                            DB,SB,updateSR_accum);
                        

            //addressbusreg loads by default every phi1. only disable if controlSig is asserted.
            AddressBusReg   add_hi(rstAll,phi1,~controlSigs[`nADH_ABH], ADH, extAB[15:8]);

            AddressBusReg   add_lo(rstAll,phi1,~controlSigs[`nADL_ABL], ADL, extAB[7:0]);
            
            register        x_reg(rstAll,phi2,controlSigs[`SB_X],controlSigs[`X_SB],SB,updateSR_x);
            register        y_reg(rstAll,phi2,controlSigs[`SB_Y],controlSigs[`Y_SB],SB,updateSR_y);
            
            //unsure about the inputs...
            wire DBZ,DB_N;
            assign DBZ = ~(|(DB));
            assign DB_N = (DB[7]);

            
            wire updateSR;
            assign updateSR = updateSR_accum|updateSR_x|updateSR_y;
            //statusReg       status_reg(phi2,  controlSigs[`IR5_I], , ACR ,AVR, DB_N, 
            //                            DB, opcode,DB, statusReg);
            wire BRKins;
            wire [7:0] real_outToIR, effective_outToIR, real_opcode, effective_opcode;
            wire [7:0] activeOpcode;
            assign BRKins = (activeOpcode == `BRK || activeOpcode == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            wire [7:0] SR_contents;
            statusReg SR(rstAll,phi1,phi2,controlSigs[`DB_P],controlSigs[`FLAG_DBZ],controlSigs[`FLAG_ALU],controlSigs[`FLAG_DB],
                        controlSigs[`P_DB], DBZ, DB_N, ACR, AVR, ~controlSigs[`nDAA], BRKins,
                        controlSigs[`SET_C], controlSigs[`CLR_C],
                        controlSigs[`SET_I], controlSigs[`CLR_I],
                        controlSigs[`SET_V], controlSigs[`CLR_V],
                        controlSigs[`SET_D], controlSigs[`CLR_D],
                        DB,ALU_out,activeOpcode,DB,
                        SR_contents);
                    
                    
            wire [7:0] dataOutBuf;
            dataOutReg          dor(rstAll, phi2, controlSigs[`nRW] & phi2, DB, extDB);
            //dataBusTristate     dataBuf(, dataOutBuf,extDB);
            
            //moving on to left side...
            wire [7:0] predecodeOut, outToIR;
            wire interrupt;
            
            wire fsmNMI,fsmIRQ,fsmRES;
            assign interrupt = fsmRES | fsmNMI | fsmIRQ;
            predecodeRegister   pdr(phi2,extDB,predecodeOut);
            predecodeLogic      pdl(rstAll,predecodeOut,interrupt,real_opcode,effective_opcode,newOpcode);
            
            wire loadOpcode,T1now;
            
            and #2 andgate(loadOpcode,phi2,T1now);
            //wire loadIR, T1next;
            //assign loadIR = T1next & RDY;
            //instructionRegister ir_reg(phi1, loadIR, real_outToIR,effective_outToIR,real_opcode, effective_opcode);
            wire outNMI_L,outIRQ_L,outRES_L;
            interruptLatch   iHandlerLatch(rstAll,phi1,~(SR_contents[`status_I]),NMI_L,IRQ_L,RES_L,outNMI_L,outIRQ_L,outRES_L);
            interruptResetControl iHandler(rstAll,outNMI_L,outIRQ_L,outRES_L, nmiHandled, irqHandled, resHandled,
                            nmiPending,irqPending,resPending);
            
            wire RDYout; //this is the one which affects the FSM.
            readyControl rdy_control(phi2, RDY, nRW, RDYout);
            

            
            // finally, control logic
            inoutLatch3  fsmInterruptLatch(rstAll,phi1,nmiPending,irqPending,resPending,nmiHandled, irqHandled, resHandled,
                                fsmNMI,fsmIRQ,fsmRES);
            
            plaFSM      fsm(phi1,phi2,fsmNMI,fsmIRQ,fsmRES,RDYout,ACR,effective_opcode,SR_contents,loadOpcode,
                                controlSigs,SYNC,T1now,nmiHandled, irqHandled, resHandled,rstAll,activeOpcode);
                                
                      
            //busHold   holdDB(rstAll,phi1,phi2,DB,DB);
            //busHold  holdADH(rstAll,phi1,phi2,ADH,ADH);
            //busHold  holdADL(rstAll,phi1,phi2,ADL,ADL);
            //busHold   holdSB(rstAll,phi1,phi2,SB,SB);
            
endmodule













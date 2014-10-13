// top module for the 6502C cpu.
// last updated: 09/30/2014 2140H
`define syn


`include "Control/controlDef.v"
`include "Control/opcodeDef.v"
`include "Control/FSMstateDef.v"
`include "Control/TDef.v"

`include "left_components.v"
`include "right_components.v"
`include "peripherals.v" 

`include "Control/plaFSM.v"

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
`ifdef syn				
			(* PULLUP = "TRUE" *) wire [7:0]  DB, ADL, ADH, SB; 
`else
            trireg [7:0]  DB, ADL, ADH, SB;
`endif            
            //control sigs
            wire [64:0] controlSigs;
            wire rstAll;

            
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
`ifdef syn              
           /* PULLUP adhup[7:0]		(.O(ADH));
            PULLUP adlup[7:0]		(.O(ADL));
            PULLUP dbup[7:0]		(.O(DB));
            PULLUP sbup[7:0]		(.O(SB));
            */
           // wire drain; (* OPEN_DRAIN = "TRUE" *) //configure NET "drain" OPEN_DRAIN;
            reg drain = 1'b0;
            bufif1  buflo0(ADL[0],drain,controlSigs[`O_ADL0]);
            bufif1	buflo1(ADL[1],drain,controlSigs[`O_ADL1]);
            bufif1	buflo2(ADL[2],drain,controlSigs[`O_ADL2]);
            
           // wire [6:0] drain7; (* OPEN_DRAIN = "TRUE" *) //configure NET "drain7" OPEN_DRAIN;
            reg drain7 = 7'b0000000;
            bufif1	bufhi0(ADH[0],drain,controlSigs[`O_ADH0]);
            bufif1	bufhi17[6:0](ADH[7:1],drain7,controlSigs[`O_ADH1to7]);
			
            //how to model tranif?
            passBuffer SBtoDB(SB,controlSigs[`SB_DB],DB);
            passBuffer DBtoSB(DB,controlSigs[`SB_DB],SB);
            
            passBuffer SBtoADH(SB,controlSigs[`SB_ADH],ADH);
            passBuffer ADHtoSB(ADH,controlSigs[`SB_ADH],SB);
`else				
            prechargeMos        pcMos1(rstAll,phi2,ADH); 
            prechargeMos        pcMos2(rstAll,phi2,ADL);
            prechargeMos        pcMos3(rstAll,phi2,DB);
            prechargeMos        pcMos4(rstAll,phi2,SB);
            opendrainMosADL     od_lo(rstAll,controlSigs[`O_ADL0],controlSigs[`O_ADL1],controlSigs[`O_ADL2],ADL);
            opendrainMosADH     od_hi(rstAll,controlSigs[`O_ADH0],controlSigs[`O_ADH1to7],ADH);
            tranif1             pass1[7:0](SB, ADH, controlSigs[`SB_ADH]);
            tranif1             pass2[7:0](SB, DB, controlSigs[`SB_DB]);
            //passBuffer SBtoDB(SB,controlSigs[`SB_DB],DB);
            //passBuffer DBtoSB(DB,controlSigs[`SB_DB],SB);
            
            //passBuffer SBtoADH(SB,controlSigs[`SB_ADH],ADH);
            //passBuffer ADHtoSB(ADH,controlSigs[`SB_ADH],SB);
            //assign SB = (controlSigs[`SB_ADH]) ? ADH : 8'hzz;
            //assign SB = (controlSigs[`SB_DB]) ? DB : 8'hzz;
`endif            
            wire [7:0] A, B, ALU_out, ALUhold_out;
            wire tempAVR,tempACR,tempHC;
            ALU     my_alu(A, B, ~controlSigs[`nDAA], controlSigs[`I_ADDC], controlSigs[`SUMS], 
                        controlSigs[`ANDS], controlSigs[`EORS], controlSigs[`ORS], 
                            controlSigs[`SRS], ALU_out, tempAVR, tempACR, tempHC);
            
            
            //registers
            SPreg   sp(rstAll,phi2,controlSigs[`S_S], controlSigs[`SB_S], controlSigs[`S_ADL], 
                        controlSigs[`S_SB], SB, ADL, SB);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(controlSigs[`DB_L_ADD], controlSigs[`DB_ADD], controlSigs[`ADL_ADD], DB,nDB,ADL,B);
            
            Areg    a_reg(controlSigs[`O_ADD], controlSigs[`SB_ADD], SB, A);
            
            wire aluAVR,aluACR,aluHC;
            wire AVR,ACR,HC;
            AdderHoldReg addHold(rstAll, phi2, controlSigs[`ADD_ADL], controlSigs[`ADD_SB0to6], controlSigs[`ADD_SB7], 
                                ALU_out, tempAVR, tempACR, tempHC,
                                ADL,SB,ALUhold_out,aluAVR,aluACR,aluHC);
            
            ACRlatch    carryLatch(rstAll,phi1,aluAVR,aluACR,aluHC,AVR,ACR,HC);
            wire [7:0] inFromDecAdder;
           
            /*
            wire DAAmode, DSAmode;
            assign DAAmode = SR_contents[`status_D] & 
                                (opcode == `ADC_imm ||
                                opcode == `ADC_zp ||
                                opcode == `ADC_zpx ||
                                opcode == `ADC_ ||
                                opcode == `ADC_imm ||
                                opcode == `ADC_imm ||
                                opcode == `ADC_imm ||
                                
            opcode*/
            
            decimalAdjust   decAdj(SB, ~controlSigs[`nDSA], ~controlSigs[`nDAA], ACR, HC, phi2,inFromDecAdder);
            accum           a(rstAll,phi2,inFromDecAdder, controlSigs[`SB_AC], controlSigs[`AC_DB], controlSigs[`AC_SB],
                            DB,SB);
                        

            //addressbusreg loads by default every phi1. only disable if controlSig is asserted.
            AddressBusReg   add_hi(rstAll,phi1,~controlSigs[`nADH_ABH], ADH, extAB[15:8]);

            AddressBusReg   add_lo(rstAll,phi1,~controlSigs[`nADL_ABL], ADL, extAB[7:0]);
            
            register        x_reg(rstAll,phi2,controlSigs[`SB_X],controlSigs[`X_SB],SB);
            register        y_reg(rstAll,phi2,controlSigs[`SB_Y],controlSigs[`Y_SB],SB);
            
            //unsure about the inputs...
            wire DBZ;
            assign DBZ = ~(|(DB));
      
            //statusReg       status_reg(phi2,  controlSigs[`IR5_I], , ACR ,AVR, DB_N, 
            //                            DB, opcode,DB, statusReg);
            wire BRKins;
            wire [7:0] opcode;
            assign BRKins = (opcode == `BRK || opcode == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            wire [7:0] SR_contents;
            
            //latch SR signals.
            wire latchedACR,latchedAVR;
            plainLatch      latch[1:0](phi2,{tempACR, tempAVR},{latchedACR,latchedAVR});
            
            
            statusReg SR(rstAll,phi1,phi2,controlSigs[`DB_P],
                        controlSigs[`FLAG_DBZ],
                        controlSigs[`FLAG_ALU],
                        controlSigs[`FLAG_DB],
                        controlSigs[`P_DB], DBZ, latchedACR, latchedAVR, BRKins,
                        controlSigs[`SET_C], controlSigs[`CLR_C],
                        controlSigs[`SET_I], controlSigs[`CLR_I],
                        controlSigs[`CLR_V],
                        controlSigs[`SET_D], controlSigs[`CLR_D],
                        DB,ALUhold_out,opcode,DB,
                        SR_contents);
            

                    
                    
            dataOutReg          dor(rstAll, phi2, controlSigs[`nRW] & phi2, DB, extDB);
            //dataBusTristate     dataBuf(, dataOutBuf,extDB);
            
            //moving on to left side...
            wire [7:0] predecodeOut, opcodeToIR;
            wire interrupt;

            wire nmiPending, irqPending, resPending,intHandled;
            
            assign interrupt = nmiPending|resPending|irqPending;
            predecodeRegister   pdr(phi2,extDB,predecodeOut);
            predecodeLogic      pdl(predecodeOut,interrupt,opcodeToIR);
            wire brkNow;
            assign brkNow = (predecodeOut == `BRK || interrupt);
            wire loadOpcode,loadOpcodeBuf,T1now;
            
/*
            and andgate(loadOpcodeBuf,phi2,T1now);
`ifdef syn
            buf bufbuf(loadOpcode,loadOpcodeBuf);
`else
            buf #2 bufbuf(loadOpcode,loadOpcodeBuf);
`endif    
*/
            wire [7:0] prevOpcode;
            (* clock_signal = "yes" *)
            wire [6:0] currT;
            instructionRegister ir_reg(currT,RDY,phi1,phi2, opcodeToIR, opcode, prevOpcode);
            
            wire [64:0] nextControlSigs;
            wire [2:0] activeInt;
            wire [6:0] newT;
            logicControl   control(currT,opcode,prevOpcode,phi1,phi2,activeInt,aluACR,ACR,SR_contents,
                                    newT,controlSigs);
            //controlLatch    conLatch(phi1,phi2,nextControlSigs,controlSigs);
            
            wire outNMI_L,outIRQ_L,outRES_L;
            
            wire RDYout; //this is the one which affects the FSM.
            interruptLatch   iHandlerLatch(rstAll,phi1,~(SR_contents[`status_I]),NMI_L,IRQ_L,RES_L,outNMI_L,outIRQ_L,outRES_L); //latches signals from outside world
            interruptControl iHandler(rstAll,outNMI_L,outIRQ_L,outRES_L,nmiPending,irqPending,resPending); //handles edge triggered stuff
            PLAinterruptControl  plaInt(phi1,rstAll,nmiPending,resPending,irqPending,intHandled,activeInt); //latches incoming interrupts and keeps track of current interrupt.
            plaFSM      fsm(phi1,phi2,RDYout,newT, resPending,brkNow,currT,intHandled, rstAll);          
            
            
            readyControl rdy_control(phi2, RDY, controlSigs[`nRW], RDYout);
endmodule













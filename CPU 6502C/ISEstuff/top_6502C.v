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

module top_6502C(prevOpcode,extAB_b1,SR_contents,holdAB,SRflags,opcode,opcodeToIR,second_first_int,nmiPending,resPending,irqPending,currState,accumVal,outToPCL,outToPCH,A,B,idlContents,rstAll,ALUhold_out,activeInt,currT,DB,SB,ADH,ADL,
                HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk,extDB,	
                RDY,phi1_out, SYNC, extABL, extABH, phi2_out, RW,
                Accum,Xreg,Yreg);
            output [7:0] extAB_b1,SR_contents;
            output [7:0] holdAB;
            output [7:0] SRflags;
            output [7:0] opcode,opcodeToIR,prevOpcode;
            output [7:0] second_first_int;
            output nmiPending,resPending,irqPending;
            output [1:0] currState;
            output [7:0] accumVal;
            output [7:0] outToPCL,outToPCH,A,B;
            output [7:0] idlContents;
            output rstAll;
            output [7:0] ALUhold_out;
            //output phi1;
            //output [2:0] dbDrivers,sbDrivers,adlDrivers,adhDrivers;
            output [2:0] activeInt;
            output [6:0] currT;          
            output [7:0] DB,SB,ADH,ADL;
            
			input HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk;
			inout [7:0] extDB;
            
			output RDY,phi1_out, SYNC, phi2_out,RW;
			output [7:0] extABH,extABL;
            output [7:0] Accum,Xreg,Yreg;
        
            wire RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
            wire [7:0] extDB;
            wire [7:0] extABH,extABL;
            wire phi1_out, SYNC, phi2_out, RW;
            
            
            //internal variables
            
            //bus lines
`ifdef syn				
			wire [7:0]  DB, ADL, ADH, SB; 
`else
            trireg [7:0]  DB, ADL, ADH, SB;
`endif            
            //control sigs
            wire [65:0] controlSigs;
            wire rstAll;
            
            wire [2:0] adhDrivers,sbDrivers,dbDrivers;
            /*assign adlDrivers = controlSigs[`ADD_ADL]+
                                controlSigs[`S_ADL] +
                                controlSigs[`PCL_ADL] +
                                controlSigs[`DL_ADL]+
                                (controlSigs[`O_ADL0]|controlSigs[`O_ADL1]|controlSigs[`O_ADL2]);*/
            assign adhDrivers = controlSigs[`DL_ADH] +
                                controlSigs[`PCH_ADH] +
                                controlSigs[`SB_ADH]+
                                (controlSigs[`O_ADH0] | controlSigs[`O_ADH1to7]);
            assign sbDrivers =  controlSigs[`SB_ADH] +
                                controlSigs[`SB_DB] +
                                controlSigs[`S_SB] +
                                (controlSigs[`ADD_SB0to6] | controlSigs[`ADD_SB7]) +
                                controlSigs[`X_SB] +
                                controlSigs[`Y_SB] +
                                controlSigs[`AC_SB];
                                
            assign dbDrivers = controlSigs[`DL_DB] +
                               controlSigs[`PCL_DB] +
                               controlSigs[`PCH_DB] +
                               controlSigs[`SB_DB] +
                               controlSigs[`AC_DB] +
                               controlSigs[`P_DB];
            wire DBZ,ALUZ;
            assign RW = ~controlSigs[`nRW];
            wire updateOthers;
            
          
            //clock
            wire phi1,phi2;
            wire haltAll;
			clockGen clock(HALT,phi0_in,haltAll,RDY,phi1,phi2,phi1_out,phi2_out);
            
            //datapath modules
            wire [7:0] DB_b0,ADL_b0,ADH_b0;
           // triState idl_b0[7:0](DB,DB_b0,controlSigs[`DL_DB]);
            //triState idl_b1[7:0](ADL,ADL_b0,controlSigs[`DL_ADL]);
            //triState idl_b2[7:0](ADH,ADH_b0,controlSigs[`DL_ADH]);
            inputDataLatch dl(haltAll,idlContents,rstAll,phi2,controlSigs[`DL_DB], controlSigs[`DL_ADL], controlSigs[`DL_ADH],extDB,
                        DB,ADL,ADH);
            
            // internal signal latcher - used to latch signals across the phi1 uptick transition.
            wire nADH_ABH, nADL_ABL, DB_P, FLAG_DBZ, FLAG_ALU, FLAG_DB, P_DB, SET_C, CLR_C, SET_I, CLR_I, CLR_V, SET_D, CLR_D;
            assign holdAB = {nADH_ABH,FLAG_ALU,ALUZ,updateOthers,1'd0,FLAG_DB,DBZ,nADL_ABL};
            
            sigLatch l1(fastClk,controlSigs[`nADH_ABH],nADH_ABH);
            sigLatch l2(fastClk,controlSigs[`nADL_ABL],nADL_ABL);
            sigLatch l3(fastClk,controlSigs[`DB_P],DB_P);
            sigLatch l4(fastClk,controlSigs[`FLAG_DBZ],FLAG_DBZ);
            sigLatch l5(fastClk,controlSigs[`FLAG_ALU],FLAG_ALU);
            sigLatch l6(fastClk,controlSigs[`FLAG_DB],FLAG_DB);
           // sigLatch l7(fastClk,controlSigs[`P_DB],P_DB);
            sigLatch l8(fastClk,controlSigs[`SET_C],SET_C);
            sigLatch l9(fastClk,controlSigs[`CLR_C],CLR_C);
            sigLatch l10(fastClk,controlSigs[`SET_I],SET_I);
            sigLatch l11(fastClk,controlSigs[`CLR_I],CLR_I);
            sigLatch l12(fastClk,controlSigs[`CLR_V],CLR_V);
            sigLatch l13(fastClk,controlSigs[`SET_D],SET_D);
            sigLatch l14(fastClk,controlSigs[`CLR_D],CLR_D);
            
            //phi2 uptick latcher:
            //nRW,STORE_DB, SB_X, SB_Y, SB_AC, SB_S
            sigLatch l15(fastClk,controlSigs[`nRW],nRW);
            sigLatch l16(fastClk,controlSigs[`STORE_DB],STORE_DB);
            sigLatch l17(fastClk,controlSigs[`SB_X],SB_X);
            sigLatch l18(fastClk,controlSigs[`SB_Y],SB_Y);
            sigLatch l19(fastClk,controlSigs[`SB_AC],SB_AC);
            sigLatch l20(fastClk,controlSigs[`SB_S],SB_S);
            
            //last ones
            wire O_ADL0, O_ADL1, O_ADL2, O_ADH0, O_ADH1to7;
            
            sigLatch l21(fastClk,controlSigs[`O_ADL0],O_ADL0);
            sigLatch l22(fastClk,controlSigs[`O_ADL1],O_ADL1);
            sigLatch l23(fastClk,controlSigs[`O_ADL2],O_ADL2);
            sigLatch l24(fastClk,controlSigs[`O_ADH0],O_ADH0);
            sigLatch l25(fastClk,controlSigs[`O_ADH1to7],O_ADH1to7);

            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(controlSigs[`PCL_PCL], controlSigs[`ADL_PCL], inFromPC_lo, ADL, 
                        outToIncre_lo);
            increment   lo_2(~controlSigs[`nI_PC],outToIncre_lo,PCLC,outToPCL);
            wire [7:0] DB_b1,ADL_b1;
            //triState PClo_b0[7:0](DB,DB_b1,controlSigs[`PCL_DB]);
            //triState PClo_b1[7:0](ADL,ADL_b1,controlSigs[`PCL_ADL]);
            PC          lo_3(haltAll,rstAll,phi2, controlSigs[`PCL_DB], controlSigs[`PCL_ADL],outToPCL,DB, ADL,inFromPC_lo);
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(controlSigs[`PCH_PCH], controlSigs[`ADH_PCH], inFromPC_hi, ADH, 
                        outToIncre_hi);           
            increment   hi_2(PCLC,outToIncre_hi, ,outToPCH);
            wire [7:0] DB_b2,ADH_b2;
            //triState PChi_b0[7:0](DB,DB_b2,controlSigs[`PCH_DB]);
            //triState PChi_b1[7:0](ADH,ADH_b2,controlSigs[`PCH_ADH]);
            PC          hi_3(haltAll,rstAll,phi2, controlSigs[`PCH_DB], controlSigs[`PCH_ADH],outToPCH,DB, ADH,inFromPC_hi);
`ifdef syn              
           wire ground = 1'b0;
            PULLUP pcMos1[7:0](.O(ADH));
            PULLUP pcMos2[7:0](.O(ADL));
            PULLUP pcMos3[7:0](.O(DB));
            PULLUP pcMos4[7:0](.O(SB));
           
            triState od_lo0(ADL[0],ground,controlSigs[`O_ADL0]);
            triState od_lo1(ADL[1],ground,controlSigs[`O_ADL1]);
            triState od_lo2(ADL[2],ground,controlSigs[`O_ADL2]);
            
            triState od_hi0(ADH[0],ground,controlSigs[`O_ADH0]);
            triState od_hi1[6:0](ADH[7:1],ground,controlSigs[`O_ADH1to7]);
            
            /* 
            prechargeMos        pcMos1(rstAll,phi2,ADH); 
            prechargeMos        pcMos2(rstAll,phi2,ADL);
            prechargeMos        pcMos3(rstAll,phi2,DB);
            prechargeMos        pcMos4(rstAll,phi2,SB); */
            /*
            opendrainMosADL     od_lo(rstAll,controlSigs[`O_ADL0],controlSigs[`O_ADL1],controlSigs[`O_ADL2],ADL);
            opendrainMosADH     od_hi(rstAll,controlSigs[`O_ADH0],controlSigs[`O_ADH1to7],ADH);
            */

            transBuf ta(controlSigs[`SB_DB], sbDrivers, dbDrivers, SB, DB);
            transBuf tb(controlSigs[`SB_ADH], sbDrivers,adhDrivers, SB, ADH);

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
            wire tempAVR,tempACR,tempHC,tempRel;
            ALU     my_alu(A, B, ~controlSigs[`nDAA], controlSigs[`I_ADDC], controlSigs[`SUMS], 
                        controlSigs[`ANDS], controlSigs[`EORS], controlSigs[`ORS], 
                            controlSigs[`SRS], ALU_out, tempAVR, tempACR, tempHC,tempRel);
        
            //registers
            wire [7:0]  ADL_b3,SB_b3;
            //triState sp_b0[7:0](ADL,ADL_b3,controlSigs[`S_ADL]);
            //triState sp_b1[7:0](SB,SB_b3,controlSigs[`S_SB]);
            SPreg   sp(haltAll,rstAll,phi2,controlSigs[`S_S], SB_S, controlSigs[`S_ADL], 
                        controlSigs[`S_SB], SB, ADL, SB);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(controlSigs[`DB_L_ADD], controlSigs[`DB_ADD], controlSigs[`ADL_ADD], DB,nDB,ADL,B);
            
            Areg    a_reg(controlSigs[`O_ADD], controlSigs[`SB_ADD], SB, A);
            
            wire aluAVR,aluACR,aluHC,aluRel;
            wire AVR,ACR,HC;
            wire [7:0] ADL_b4,SB_b4;
            //triState addhold_b0[7:0](ADL,ADL_b4,controlSigs[`ADD_ADL]);
            //triState addhold_b1[6:0](SB[6:0],SB_b4[6:0],controlSigs[`ADD_SB0to6]);
            //triState addhold_b2(SB[7],SB_b4[7],controlSigs[`ADD_SB7]);
            AdderHoldReg addHold(haltAll,phi2, controlSigs[`ADD_ADL], controlSigs[`ADD_SB0to6], controlSigs[`ADD_SB7], 
                                ALU_out, tempAVR, tempACR, tempHC,tempRel,
                                ADL,SB,ALUhold_out,aluAVR,aluACR,aluHC,aluRel);
            
            ACRlatch    carryLatch(haltAll,rstAll,phi1,aluAVR,aluACR,aluHC,AVR,ACR,HC);
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
            
            decimalAdjust   decAdj(haltAll,SB, ~controlSigs[`nDSA], ~controlSigs[`nDAA], ACR, HC, phi2,inFromDecAdder);
            wire [7:0] DB_b5,SB_b5;
           // triState accum_b0[7:0](DB,DB_b5,controlSigs[`AC_DB]);
           // triState accum_b1[7:0](SB,SB_b5,controlSigs[`AC_SB]);
            accum           a(haltAll,accumVal,rstAll,phi2,inFromDecAdder, SB_AC, controlSigs[`AC_DB], controlSigs[`AC_SB],
                            DB,SB);
            assign Accum = accumVal;           

            //addressbusreg loads by default every phi1. only disable if controlSig is asserted.
            wire [7:0] extAB_b0,extAB_b1;
            
            //triState ABR_b0[7:0](extABH,extAB_b0,~controlSigs[`nADH_ABH]);
            //triState ABR_b1[7:0](extABL,extAB_b1,~controlSigs[`nADL_ABL]);
            triState ABR_b0[7:0](extABH,extAB_b0,~haltAll);
            triState ABR_b1[7:0](extABL,extAB_b1,~haltAll);

            AddressBusReg   add_hi(haltAll,phi1,nADH_ABH, ADH, extAB_b0);
            AddressBusReg   add_lo(haltAll,phi1,nADL_ABL, ADL, extAB_b1);
                
            wire [7:0] SB_b6, SB_b7;
            //triState x_b0[7:0](SB,SB_b6,controlSigs[`X_SB]);
            //triState y_b0[7:0](SB,SB_b7,controlSigs[`Y_SB]);
            register        x_reg(haltAll,Xreg,rstAll,phi2,SB_X,controlSigs[`X_SB],SB,SB);
            register        y_reg(haltAll,Yreg,rstAll,phi2,SB_Y,controlSigs[`Y_SB],SB,SB);
            
            //unsure about the inputs...
            
            assign DBZ = ~(|(DB));
            assign ALUZ = ~(|(ALUhold_out));
            //statusReg       status_reg(phi2,  controlSigs[`IR5_I], , ACR ,AVR, DB_N, 
            //                            DB, opcode,DB, statusReg);
            wire BRKins;
            wire [7:0] opcode;
            assign BRKins = (opcode == `BRK || opcode == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            wire [7:0] SR_contents;
            
            //latch SR signals.
            //wire latchedACR,latchedAVR;
            //plainLatch      latch[1:0](phi2,{tempACR, tempAVR},{latchedACR,latchedAVR});
            
            
            //store db/alu status during phi2, and update SR in phi1. applicable for TAY,TYA etc. only.
            wire [7:0] storedDB;
            FlipFlop8   store_db(phi2,DB,STORE_DB,storedDB);
            
            wire [7:0] DB_b8;
           // triState SR_b0[7:0](DB,DB_b8,controlSigs[`P_DB]);
            statusReg SR(haltAll,rstAll,phi1,DB_P,
                        FLAG_DBZ,
                        FLAG_ALU,
                        FLAG_DB,
                        controlSigs[`P_DB], DBZ,ALUZ, aluACR, aluAVR, BRKins,
                        SET_C, CLR_C,
                        SET_I, CLR_I,
                        CLR_V,
                        SET_D, CLR_D,
                        DB,ALUhold_out,storedDB,opcode,DB,
                        SR_contents);
           
                    
            wire [7:0] extDB_b0;
            triState8 dor_b(extDB,extDB_b0,(~haltAll) & (controlSigs[`nRW]));
            dataOutReg          dor(haltAll,phi2,nRW, DB, extDB_b0);
            
            //moving on to left side...
            wire [7:0] predecodeOut, opcodeToIR;
            wire interrupt;
            
            wire FSMnmi,FSMirq,FSMres;
            assign interrupt = FSMnmi|FSMirq|FSMres;
            predecodeRegister   pdr(haltAll,phi2,extDB,predecodeOut);
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
            wire [6:0] currT;
            wire en;
            instructionRegister ir_reg(haltAll,rstAll,currT,phi1,phi2, opcodeToIR, opcode, prevOpcode);
            
            assign SRflags = {1'd0,activeInt,1'd0,controlSigs[`O_ADL2],controlSigs[`O_ADL1],controlSigs[`O_ADL0]};

            //wire [64:0] nextControlSigs;
         
            wire [2:0] activeInt;
            wire [6:0] newT;
        
                          
            logicControl   control(.updateOthers(updateOthers),
                                  .currT(currT),.opcode(opcode),.prevOpcode(prevOpcode),.phi1(phi1),.phi2(phi2),
                                  .activeInt(activeInt),.aluRel(aluRel),.tempCarry(aluACR),.ovf(AVR),.carry(ACR),.statusReg(SR_contents),
                                    .nextT(newT),.nextControlSigs(controlSigs));    
/* 
          logicControl(updateOthers,currT,opcode,prevOpcode,phi1,phi2,activeInt,aluRel,tempCarry,ovf,carry,statusReg,
                                    nextT,nextControlSigs);      */
                                    
           // controlLatch    conLatch(fastClk,controlSigs_b,controlSigs);
            
            wire outNMI_L,outIRQ_L,outRES_L;
            wire nmiPending,irqPending,resPending,nmiDone,intHandled;
            wire [1:0] currState;
            //wire RDYout; //this is the one which affects the FSM.
            wire IRQ_Lfiltered;
            assign IRQ_Lfiltered = IRQ_L | SR_contents[`status_I];
            interruptLatch   iHandlerLatch(haltAll,phi1,NMI_L,IRQ_Lfiltered,RES_L,outNMI_L,outIRQ_L,outRES_L);
            interruptControl iHandler(rstAll,outNMI_L,outIRQ_L,outRES_L,nmiDone,
                        nmiPending,irqPending,resPending);

            assign nmiDone = intHandled & (activeInt == `NMI_i);
            
            PLAinterruptControl  plaInt(haltAll,phi1,nmiPending,resPending,irqPending,intHandled,activeInt,FSMnmi,FSMirq,FSMres);
                                        
            plaFSM      fsm(haltAll,currState,phi1,phi2,1'b1,newT, FSMres,brkNow,currT,intHandled, rstAll);          
            
            
            //readyControl rdy_control(phi2, RDY, controlSigs[`nRW], RDYout);
            assign second_first_int = {FSMnmi,FSMirq,FSMres,intHandled,1'd0,nmiPending,irqPending,resPending};
endmodule













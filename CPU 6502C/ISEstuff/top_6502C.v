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

module top_6502C(extAB_b1,phi1,phi2,SRflags,opcode,opcodeToIR,second_first_int,nmiPending,resPending,irqPending,currState,accumVal,outToPCL,outToPCH,A,B,idlContents,rstAll,ALUhold_out,activeInt,currT,DB,SB,ADH,ADL,
                HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk,extDB,	
                RDY,phi1_out, SYNC, extABL, extABH, phi2_out, RW,
                Accum,Xreg,Yreg);
            output [7:0] extAB_b1;
            output phi1,phi2;
            output [7:0] SRflags;
            output [7:0] opcode,opcodeToIR;
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
            wire [64:0] controlSigs;
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
            
            assign RW = ~controlSigs[`nRW];
            //assign holdHi = controlSigs[`nADH_ABH];
            //assign holdLo = controlSigs[`nADL_ABL];
            //clock
            wire phi1,phi2;
            wire haltAll;
			clockGen clock(HALT,phi0_in,haltAll,RDY,phi1,phi2,phi1_out,phi2_out);
            
            //datapath modules
            wire [7:0] DB_b0,ADL_b0,ADH_b0;
            triState idl_b0[7:0](DB,DB_b0,controlSigs[`DL_DB]);
            triState idl_b1[7:0](ADL,ADL_b0,controlSigs[`DL_ADL]);
            triState idl_b2[7:0](ADH,ADH_b0,controlSigs[`DL_ADH]);
            inputDataLatch dl(haltAll,idlContents,rstAll,phi2,controlSigs[`DL_DB], controlSigs[`DL_ADL], controlSigs[`DL_ADH],extDB,
                        DB_b0,ADL_b0,ADH_b0);
            
            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(controlSigs[`PCL_PCL], controlSigs[`ADL_PCL], inFromPC_lo, ADL, 
                        outToIncre_lo);
            increment   lo_2(~controlSigs[`nI_PC],outToIncre_lo,PCLC,outToPCL);
            wire [7:0] DB_b1,ADL_b1;
            triState PClo_b0[7:0](DB,DB_b1,controlSigs[`PCL_DB]);
            triState PClo_b1[7:0](ADL,ADL_b1,controlSigs[`PCL_ADL]);
            PC          lo_3(haltAll,rstAll,phi2, controlSigs[`PCL_DB], controlSigs[`PCL_ADL],outToPCL,DB_b1, ADL_b1,inFromPC_lo);
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(controlSigs[`PCH_PCH], controlSigs[`ADH_PCH], inFromPC_hi, ADH, 
                        outToIncre_hi);           
            increment   hi_2(PCLC,outToIncre_hi, ,outToPCH);
            wire [7:0] DB_b2,ADH_b2;
            triState PChi_b0[7:0](DB,DB_b2,controlSigs[`PCH_DB]);
            triState PChi_b1[7:0](ADH,ADH_b2,controlSigs[`PCH_ADH]);
            PC          hi_3(haltAll,rstAll,phi2, controlSigs[`PCH_DB], controlSigs[`PCH_ADH],outToPCH,DB_b2, ADH_b2,inFromPC_hi);
`ifdef syn              
           wire ground;
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
            prechargeMos        pcMos4(rstAll,phi2,SB);
            opendrainMosADL     od_lo(rstAll,controlSigs[`O_ADL0],controlSigs[`O_ADL1],controlSigs[`O_ADL2],ADL);
            opendrainMosADH     od_hi(rstAll,controlSigs[`O_ADH0],controlSigs[`O_ADH1to7],ADH);
            */
            //how to model tranif?
            //passBuffer SBtoDB(SB,controlSigs[`SB_DB],DB);
            //passBuffer DBtoSB(DB,controlSigs[`SB_DB],SB);
            transBuf ta(controlSigs[`SB_DB], sbDrivers, dbDrivers, SB, DB);
            transBuf tb(controlSigs[`SB_ADH], sbDrivers,adhDrivers, SB, ADH);
            //passBuffer SBtoADH(SB,controlSigs[`SB_ADH],ADH);
            //passBuffer ADHtoSB(ADH,controlSigs[`SB_ADH],SB);
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
            wire tempAVR,tempACR,tempHC,tempRel_forward; //rel_forward identifies if it a rel jump is backward or forward
            ALU     my_alu(A, B, ~controlSigs[`nDAA], controlSigs[`I_ADDC], controlSigs[`SUMS], 
                        controlSigs[`ANDS], controlSigs[`EORS], controlSigs[`ORS], 
                            controlSigs[`SRS], ALU_out, tempAVR, tempACR, tempHC,tempRel_forward);
        
            //registers
            wire [7:0]  ADL_b3,SB_b3;
            triState sp_b0[7:0](ADL,ADL_b3,controlSigs[`S_ADL]);
            triState sp_b1[7:0](SB,SB_b3,controlSigs[`S_SB]);
            SPreg   sp(haltAll,rstAll,phi2,controlSigs[`S_S], controlSigs[`SB_S], controlSigs[`S_ADL], 
                        controlSigs[`S_SB], SB, ADL_b3, SB_b3);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(controlSigs[`DB_L_ADD], controlSigs[`DB_ADD], controlSigs[`ADL_ADD], DB,nDB,ADL,B);
            
            Areg    a_reg(controlSigs[`O_ADD], controlSigs[`SB_ADD], SB, A);
            
            wire aluAVR,aluACR,aluHC,rel_forward;
            wire AVR,ACR,HC;
            wire [7:0] ADL_b4,SB_b4;
            triState addhold_b0[7:0](ADL,ADL_b4,controlSigs[`ADD_ADL]);
            triState addhold_b1[6:0](SB[6:0],SB_b4[6:0],controlSigs[`ADD_SB0to6]);
            triState addhold_b2(SB[7],SB_b4[7],controlSigs[`ADD_SB7]);
            AdderHoldReg addHold(haltAll,phi2, controlSigs[`ADD_ADL], controlSigs[`ADD_SB0to6], controlSigs[`ADD_SB7], 
                                ALU_out, tempAVR, tempACR, tempHC,tempRel_forward,
                                ADL_b4,SB_b4,ALUhold_out,aluAVR,aluACR,aluHC,rel_forward);
            
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
            triState accum_b0[7:0](DB,DB_b5,controlSigs[`AC_DB]);
            triState accum_b1[7:0](SB,SB_b5,controlSigs[`AC_SB]);
            accum           a(haltAll,accumVal,rstAll,phi2,inFromDecAdder, controlSigs[`SB_AC], controlSigs[`AC_DB], controlSigs[`AC_SB],
                            DB_b5,SB_b5);
            assign Accum = accumVal;           

            //addressbusreg loads by default every phi1. only disable if controlSig is asserted.
            wire [7:0] extAB_b0,extAB_b1;
            //triState ABR_b0[7:0](extABH,extAB_b0,~controlSigs[`nADH_ABH]);
            //triState ABR_b1[7:0](extABL,extAB_b1,~controlSigs[`nADL_ABL]);
           // triState ABR_b0[7:0](extABH,extAB_b0,~haltAll);
           // triState ABR_b1[7:0](extABL,extAB_b1,~haltAll);

            AddressBusReg   add_hi(haltAll,phi1,controlSigs[`nADH_ABH], ADH, extABH);
            AddressBusReg   add_lo(haltAll,phi1,controlSigs[`nADL_ABL], ADL, extABL);
            
            //assign holdHiLo = {controlSigs[`nADH_ABH],6'd0,controlSigs[`nADL_ABL]};
            wire [7:0] SB_b6, SB_b7;
            triState x_b0[7:0](SB,SB_b6,controlSigs[`X_SB]);
            triState y_b0[7:0](SB,SB_b7,controlSigs[`Y_SB]);
            register        x_reg(haltAll,Xreg,rstAll,phi2,controlSigs[`SB_X],controlSigs[`X_SB],SB,SB_b6);
            register        y_reg(haltAll,Yreg,rstAll,phi2,controlSigs[`SB_Y],controlSigs[`Y_SB],SB,SB_b7);
            
            //unsure about the inputs...
            wire DBZ,ALUZ;
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
            
            wire [7:0] DB_b8;
            triState SR_b0[7:0](DB,DB_b8,controlSigs[`P_DB]);
            statusReg SR(haltAll,phi1_1,phi2_1,rstAll,fastClk,controlSigs[`DB_P],
                        controlSigs[`FLAG_DBZ],
                        controlSigs[`FLAG_ALU],
                        controlSigs[`FLAG_DB],
                        controlSigs[`P_DB], DBZ,ALUZ, aluACR, aluAVR, BRKins,
                        controlSigs[`SET_C], controlSigs[`CLR_C],
                        controlSigs[`SET_I], controlSigs[`CLR_I],
                        controlSigs[`CLR_V],
                        controlSigs[`SET_D], controlSigs[`CLR_D],
                        DB,ALUhold_out,opcode,DB_b8,
                        SR_contents);
           
                    
            wire [7:0] extDB_b0;
            triState dor_b[7:0](extDB,extDB_b0,controlSigs[`nRW]&~haltAll);
            dataOutReg          dor(haltAll,phi2, controlSigs[`nRW], DB, extDB_b0);
            //dataBusTristate     dataBuf(, dataOutBuf,extDB);
            
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

            wire [64:0] nextControlSigs;
            wire [2:0] activeInt;
            wire [6:0] newT;
            logicControl   control(currT,opcode,prevOpcode,phi1,phi2,activeInt,rel_forward,aluACR,ACR,SR_contents,
                                    newT,controlSigs);
            //controlLatch    conLatch(phi1,phi2,nextControlSigs,controlSigs);
            
            wire outNMI_L,outIRQ_L,outRES_L;
            wire nmiPending,irqPending,resPending,nmiDone,intHandled;
            wire [1:0] currState;
            //wire RDYout; //this is the one which affects the FSM.
            wire IRQ_Lfiltered;
            assign IRQ_Lfiltered = IRQ_L | SR_contents[`status_I];
            interruptLatch   iHandlerLatch(haltAll,phi1,NMI_L,IRQ_Lfiltered,RES_L,outNMI_L,outIRQ_L,outRES_L);
            interruptControl iHandler(outNMI_L,outIRQ_L,outRES_L,nmiDone,
                        nmiPending,irqPending,resPending);

            assign nmiDone = intHandled & (activeInt == `NMI_i);
            
            PLAinterruptControl  plaInt(haltAll,phi1,nmiPending,resPending,irqPending,intHandled,activeInt,FSMnmi,FSMirq,FSMres);
                                        
            plaFSM      fsm(haltAll,currState,phi1,phi2,1'b1,newT, FSMres,brkNow,currT,intHandled, rstAll);          
            
            
            //readyControl rdy_control(phi2, RDY, controlSigs[`nRW], RDYout);
            assign second_first_int = {FSMnmi,FSMirq,FSMres,intHandled,1'd0,nmiPending,irqPending,resPending};
endmodule













// top module for the 6502C cpu.
// last updated: 09/30/2014 2140H
`define syn


`include "CPU/Control/controlDef.v"
`include "CPU/Control/opcodeDef.v"
`include "CPU/Control/FSMstateDef.v"
`include "CPU/Control/TDef.v"

`include "CPU/left_components.v"
`include "CPU/right_components.v"
`include "CPU/peripherals.v" 

`include "CPU/Control/plaFSM.v"

module top_6502C(DBforSR,prevOpcode,extAB_b1,SR_contents,holdAB,SRflags,opcode,opcodeToIR,second_first_int,nmiPending,resPending,irqPending,currState,accumVal,outToPCL,outToPCH,A,B,idlContents,rstAll,ALUhold_out,activeInt,currT,DB,SB,ADH,ADL,
                HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk,extDB,	
                RDY,phi1_out, SYNC, extABL, extABH, phi2_out, RW,
                Accum,Xreg,Yreg);
            
            output [7:0] DBforSR,extAB_b1,SR_contents;
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
            wire [79:0] controlSigs;
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
			clockGen clock(HALT,phi0_in,fastClk,haltAll,RDY,phi1,phi2,phi1_out,phi2_out);
            
            wire phi1_1,phi1_7;
             wire DBZ_latch;
            // internal signal latcher - used to latch signals across the phi1 uptick transition.
            wire nADH_ABH, nADL_ABL, DB_P, FLAG_DBZ, FLAG_ALU, FLAG_DB, P_DB, SET_C, CLR_C, SET_I, CLR_I, CLR_V, SET_D, CLR_D;
            assign holdAB = {nADH_ABH,FLAG_ALU,ALUZ,1'd0,1'd0,FLAG_DB,DBZ_latch,nADL_ABL};
            
            sigLatchWclk l1(~phi1,fastClk,controlSigs[`nADH_ABH],nADH_ABH);
            sigLatchWclk l2(~phi1,fastClk,controlSigs[`nADL_ABL],nADL_ABL);
            sigLatchWclk l3(~phi1,fastClk,controlSigs[`DB_P],DB_P);
            sigLatchWclk l4(~phi1,fastClk,controlSigs[`FLAG_DBZ],FLAG_DBZ);
            sigLatchWclk l5(~phi1,fastClk,controlSigs[`FLAG_ALU],FLAG_ALU);
            sigLatchWclk l6(~phi1,fastClk,controlSigs[`FLAG_DB],FLAG_DB);
            sigLatchWclk l7(~phi1,fastClk,controlSigs[`P_DB],P_DB);
            sigLatchWclk l8(~phi1,fastClk,controlSigs[`SET_C],SET_C);
            sigLatchWclk l9(~phi1,fastClk,controlSigs[`CLR_C],CLR_C);
            sigLatchWclk l10(~phi1,fastClk,controlSigs[`SET_I],SET_I);
            sigLatchWclk l11(~phi1,fastClk,controlSigs[`CLR_I],CLR_I);
            sigLatchWclk l12(~phi1,fastClk,controlSigs[`CLR_V],CLR_V);
            sigLatchWclk l13(~phi1,fastClk,controlSigs[`SET_D],SET_D);
            sigLatchWclk l14(~phi1,fastClk,controlSigs[`CLR_D],CLR_D);
            
            //phi2 uptick latcher:
            //nRW,STORE_DB, SB_X, SB_Y, SB_AC, SB_S
            sigLatchWclk l15(phi1,fastClk,controlSigs[`nRW],nRW);
            sigLatchWclk l16(phi1,fastClk,controlSigs[`STORE_DB],STORE_DB);
            sigLatchWclk l17(phi1,fastClk,controlSigs[`SB_X],SB_X);
            sigLatchWclk l18(phi1,fastClk,controlSigs[`SB_Y],SB_Y);
            sigLatchWclk l19(phi1,fastClk,controlSigs[`SB_AC],SB_AC);
            sigLatchWclk l20(phi1,fastClk,controlSigs[`SB_S],SB_S);
            
            //last ones
            wire O_ADL0, O_ADL1, O_ADL2, O_ADH0, O_ADH1to7;
            
            sigLatchWclk l21(~phi1,fastClk,controlSigs[`O_ADL0],O_ADL0);
            sigLatchWclk l22(~phi1,fastClk,controlSigs[`O_ADL1],O_ADL1);
            sigLatchWclk l23(~phi1,fastClk,controlSigs[`O_ADL2],O_ADL2);
            sigLatchWclk l24(~phi1,fastClk,controlSigs[`O_ADH0],O_ADH0);
            sigLatchWclk l25(~phi1,fastClk,controlSigs[`O_ADH1to7],O_ADH1to7);


            wire PCH_ADH,PCL_ADL,ADD_ADL,S_ADL,DL_ADL,DL_ADH;
            sigLatchWclk l26(~phi1,fastClk,controlSigs[`PCL_ADL],PCL_ADL);
            sigLatchWclk l27(~phi1,fastClk,controlSigs[`PCH_ADH],PCH_ADH);
            sigLatchWclk l28(~phi1,fastClk,controlSigs[`ADD_ADL],ADD_ADL);
            sigLatchWclk l29(~phi1,fastClk,controlSigs[`S_ADL],S_ADL);
            sigLatchWclk l30(~phi1,fastClk,controlSigs[`DL_ADL],DL_ADL);
            sigLatchWclk l31(~phi1,fastClk,controlSigs[`DL_ADH],DL_ADH);

          
            wire [7:0] DBforSR;
          
            
            sigLatchWclk8 db4sr1(~phi1,fastClk,DB,DBforSR); 
            sigLatchWclk db4sr2(~phi1,fastClk,DBZ,DBZ_latch);
            
            wire [7:0] opcode,OPforSR;
            sigLatchWclk op4sr1(~phi1,fastClk,opcode[0],OPforSR[0]); 
            sigLatchWclk op4sr2(~phi1,fastClk,opcode[1],OPforSR[1]);
            sigLatchWclk op4sr3(~phi1,fastClk,opcode[2],OPforSR[2]);
            sigLatchWclk op4sr4(~phi1,fastClk,opcode[3],OPforSR[3]);
            sigLatchWclk op4sr5(~phi1,fastClk,opcode[4],OPforSR[4]);
            sigLatchWclk op4sr6(~phi1,fastClk,opcode[5],OPforSR[5]);
            sigLatchWclk op4sr7(~phi1,fastClk,opcode[6],OPforSR[6]);
            sigLatchWclk op4sr8(~phi1,fastClk,opcode[7],OPforSR[7]);
            

                            
            wire  I_ADDC,SUMS,ANDS,EORS,ORS,SRS;
            //sigLatchWclk l32(phi1,fastClk,controlSigs[`nDAA],nDAA);    
            sigLatchWclk l33(phi1,fastClk,controlSigs[`I_ADDC],I_ADDC); 
            sigLatchWclk l34(phi1,fastClk,controlSigs[`SUMS],SUMS); 
            sigLatchWclk l35(phi1,fastClk,controlSigs[`ANDS],ANDS); 
            sigLatchWclk l36(phi1,fastClk,controlSigs[`EORS],EORS); 
            sigLatchWclk l37(phi1,fastClk,controlSigs[`ORS],ORS); 
            sigLatchWclk l38(phi1,fastClk,controlSigs[`SRS],SRS); 
                            
            wire DB_L_ADD, DB_ADD, ADL_ADD, O_ADD, SB_ADD;
            sigLatchWclk l39(phi1,fastClk,controlSigs[`DB_L_ADD],DB_L_ADD);    
            sigLatchWclk l40(phi1,fastClk,controlSigs[`DB_ADD],DB_ADD); 
            sigLatchWclk l41(phi1,fastClk,controlSigs[`ADL_ADD],ADL_ADD); 
            sigLatchWclk l42(phi1,fastClk,controlSigs[`O_ADD],O_ADD); 
            sigLatchWclk l43(phi1,fastClk,controlSigs[`SB_ADD],SB_ADD); 
                         
            wire S_S, S_SB, X_SB, Y_SB;
            //sigLatchWclk l44(phi1,fastClk,controlSigs[`S_S],S_S); 
            //sigLatchWclk l45(phi1,fastClk,controlSigs[`S_SB],S_SB); 
            //sigLatchWclk l46(phi1,fastClk,controlSigs[`X_SB],X_SB); 
            //sigLatchWclk l47(phi1,fastClk,controlSigs[`Y_SB],Y_SB); 
            
            wire ADD_SB0to6, ADD_SB7;
            sigLatchWclk l48(~phi1,fastClk,controlSigs[`ADD_SB0to6],ADD_SB0to6); 
            sigLatchWclk l49(~phi1,fastClk,controlSigs[`ADD_SB7],ADD_SB7);            
             
             
            wire DL_DB,PCL_DB,PCH_DB;
            sigLatchWclk l50(~phi1,fastClk,controlSigs[`DL_DB],DL_DB);
            sigLatchWclk l51(~phi1,fastClk,controlSigs[`PCL_DB],PCL_DB);
            sigLatchWclk l52(~phi1,fastClk,controlSigs[`PCH_DB],PCH_DB);
            
            
            wire nDSA,nDAA;
            sigLatchWclk l53(phi1,fastClk,controlSigs[`nDSA],nDSA);
            sigLatchWclk l54(phi1,fastClk,controlSigs[`nDAA],nDAA);
            
            
            wire SB_DB, SB_ADH;
            sigLatchWclk l55(1'b1,fastClk,controlSigs[`SB_DB],SB_DB);
            sigLatchWclk l56(1'b1,fastClk,controlSigs[`SB_ADH],SB_ADH);

            wire nI_PC,DEC_PC;
            sigLatchWclk l57(phi1,fastClk,controlSigs[`nI_PC],nI_PC);
            sigLatchWclk l58(phi1,fastClk,controlSigs[`DEC_PC],DEC_PC);
            
            wire ADL_PCL,ADH_PCH,PCL_PCL,PCH_PCH;
            sigLatchWclk l59(phi1,fastClk,controlSigs[`ADL_PCL],ADL_PCL);
            sigLatchWclk l60(phi1,fastClk,controlSigs[`ADH_PCH],ADH_PCH);
            sigLatchWclk l61(phi1,fastClk,controlSigs[`PCL_PCL],PCL_PCL);
            sigLatchWclk l62(phi1,fastClk,controlSigs[`PCH_PCH],PCH_PCH);
            
            /*
            wire [7:0] OPforDOR;
            sigLatchWclk op4dor1(phi1,fastClk,opcode[0],OPforDOR[0]);
            sigLatchWclk op4dor2(phi1,fastClk,opcode[1],OPforDOR[1]);
            sigLatchWclk op4dor3(phi1,fastClk,opcode[2],OPforDOR[2]);
            sigLatchWclk op4dor4(phi1,fastClk,opcode[3],OPforDOR[3]);
            sigLatchWclk op4dor5(phi1,fastClk,opcode[4],OPforDOR[4]);
            sigLatchWclk op4dor6(phi1,fastClk,opcode[5],OPforDOR[5]);
            sigLatchWclk op4dor7(phi1,fastClk,opcode[6],OPforDOR[6]);
            sigLatchWclk op4dor8(phi1,fastClk,opcode[7],OPforDOR[7]);
            */
            //datapath modules
            wire [7:0] DB_b0,ADL_b0,ADH_b0;
           // triState idl_b0[7:0](DB,DB_b0,controlSigs[`DL_DB]);
            //triState idl_b1[7:0](ADL,ADL_b0,controlSigs[`DL_ADL]);
            //triState idl_b2[7:0](ADH,ADH_b0,controlSigs[`DL_ADH]);
         
            
            wire latchRdy;
            wire [7:0] eDB_latch;
            eDBlatch save_extDB(phi2, haltAll, extDB, latchRdy,eDB_latch);
            wire [7:0] DBsource;
            assign DBsource = (latchRdy) ? eDB_latch : extDB;
            inputDataLatch dl(haltAll,idlContents,rstAll,phi2,DL_DB, DL_ADL, DL_ADH,DBsource,
                        DB,ADL,ADH);
                        
                        
            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(PCL_PCL, ADL_PCL, inFromPC_lo, ADL, 
                        outToIncre_lo);
            decOrAddADL lo_2(~nI_PC,DEC_PC,outToIncre_lo,PCLC,outToPCL);
            wire [7:0] DB_b1,ADL_b1;
            //triState PClo_b0[7:0](DB,DB_b1,controlSigs[`PCL_DB]);
            //triState PClo_b1[7:0](ADL,ADL_b1,controlSigs[`PCL_ADL]);
            PC          lo_3(haltAll,rstAll,phi2, PCL_DB, PCL_ADL,outToPCL,DB, ADL,inFromPC_lo);
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(PCH_PCH, ADH_PCH, inFromPC_hi, ADH, 
                        outToIncre_hi);    
            decOrAddADH hi_2(~nI_PC,DEC_PC,PCLC,outToIncre_hi,outToPCH);                      
            wire [7:0] DB_b2,ADH_b2;
            //triState PChi_b0[7:0](DB,DB_b2,controlSigs[`PCH_DB]);
            //triState PChi_b1[7:0](ADH,ADH_b2,controlSigs[`PCH_ADH]);
            PC          hi_3(haltAll,rstAll,phi2, PCH_DB, PCH_ADH,outToPCH,DB, ADH,inFromPC_hi);
             
           wire ground = 1'b0;
            PULLUP pcMos1[7:0](.O(ADH));
            PULLUP pcMos2[7:0](.O(ADL));
            PULLUP pcMos3[7:0](.O(DB));
            PULLUP pcMos4[7:0](.O(SB));
           
            triState od_lo0(ADL[0],ground,O_ADL0);
            triState od_lo1(ADL[1],ground,O_ADL1);
            triState od_lo2(ADL[2],ground,O_ADL2);
            
            triState od_hi0(ADH[0],ground,O_ADH0);
            triState od_hi1[6:0](ADH[7:1],ground,O_ADH1to7);

            transBuf ta(SB_DB, sbDrivers, dbDrivers, SB, DB);
            transBuf tb(SB_ADH, sbDrivers,adhDrivers, SB, ADH);

        
            wire [7:0] A, B, ALU_out, ALUhold_out;
            wire tempAVR,tempACR,tempHC,tempRel;
            ALU     my_alu(A, B, ~nDAA, I_ADDC, SUMS, 
                        ANDS, EORS, ORS, SRS, ALU_out, tempAVR, tempACR, tempHC,tempRel);
        
            //registers
            wire [7:0]  ADL_b3,SB_b3;           //triState sp_b0[7:0](ADL,ADL_b3,controlSigs[`S_ADL]);
            //triState sp_b1[7:0](SB,SB_b3,controlSigs[`S_SB]);
            SPreg   sp(haltAll,rstAll,phi2,controlSigs[`S_S], SB_S, S_ADL, 
                        controlSigs[`S_SB], SB, ADL, SB);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(DB_L_ADD, DB_ADD, ADL_ADD, DB,nDB,ADL,B);
            
            Areg    a_reg(O_ADD, SB_ADD, SB, A);
            
            wire alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel;
            wire nDSA_latch,nDAA_latch,AVR,ACR,HC,dir;
            wire [7:0] ADL_b4,SB_b4;
            //triState addhold_b0[7:0](ADL,ADL_b4,controlSigs[`ADD_ADL]);
            //triState addhold_b1[6:0](SB[6:0],SB_b4[6:0],controlSigs[`ADD_SB0to6]);
            //triState addhold_b2(SB[7],SB_b4[7],controlSigs[`ADD_SB7]);
            AdderHoldReg addHold(haltAll,phi2, ADD_ADL, ADD_SB0to6, ADD_SB7, 
                                ALU_out, nDSA, nDAA, tempAVR, tempACR, tempHC,tempRel,
                                ADL,SB,ALUhold_out,alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel);
            
            ACRlatch    carryLatch(haltAll,phi1,alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel,
                                                       nDSA_latch,nDAA_latch,AVR,ACR,HC,dir);
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
            
            decimalAdjust   decAdj(haltAll,SB, ~nDSA_latch, ~nDAA_latch, ACR, HC, phi2,inFromDecAdder);
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
            triState ABR_b0[7:0](extABH,extAB_b0,~RDY);
            triState ABR_b1[7:0](extABL,extAB_b1,~RDY);

            AddressBusReg   add_hi(haltAll,phi1,nADH_ABH, ADH, extAB_b0);
            AddressBusReg   add_lo(haltAll,phi1,nADL_ABL, ADL, extAB_b1);
                
            wire [7:0] SB_b6, SB_b7;
            //triState x_b0[7:0](SB,SB_b6,controlSigs[`X_SB]);
            //triState y_b0[7:0](SB,SB_b7,controlSigs[`Y_SB]);
            register        x_reg(haltAll,Xreg,rstAll,phi2,SB_X,controlSigs[`X_SB],SB,SB);
            register        y_reg(haltAll,Yreg,rstAll,phi2,SB_Y,controlSigs[`Y_SB],SB,SB);
            
            //unsure about the inputs...
            
            
            //statusReg       status_reg(phi2,  controlSigs[`IR5_I], , ACR ,AVR, DB_N, 
            //                            DB, opcode,DB, statusReg);
            wire BRKins;

            assign BRKins = (OPforSR == `BRK || OPforSR == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            wire [7:0] SR_contents;
            
            //latch SR signals.
            //wire latchedACR,latchedAVR;
            //plainLatch      latch[1:0](phi2,{tempACR, tempAVR},{latchedACR,latchedAVR});
            
            
            //store db/alu status during phi2, and update SR in phi1. applicable for TAY,TYA etc. only.
            wire [7:0] storedDB;
            FlipFlop8   store_db(phi2,DB,STORE_DB,storedDB);
            
            
            assign DBZ  = ~(|DBforSR);
            assign ALUZ = ~(|ALUhold_out);
            
            
            wire [7:0] DB_b8;
           // triState SR_b0[7:0](DB,DB_b8,controlSigs[`P_DB]);
       /*     statusReg SR(haltAll,rstAll,phi1,DB_P,
                        FLAG_DBZ,
                        FLAG_ALU,
                        FLAG_DB,
                        P_DB, DBZ,ALUZ, aluACR, aluAVR, BRKins,
                        SET_C, CLR_C,
                        SET_I, CLR_I,
                        CLR_V,
                        SET_D, CLR_D,
                        DBforSR,ALUhold_out,storedDB,opcode,DB,
                        SR_contents);
         */               
           statusReg SR(.phi1_1(phi1_1),.phi1_7(phi1_7),.haltAll(haltAll),.rstAll(rstAll),.phi1(phi1),.DB_P(DB_P),
           .loadDBZ(FLAG_DBZ),.flagsALU(FLAG_ALU),.flagsDB(FLAG_DB),
                        .P_DB(P_DB), .DBZ(DBZ), .ALUZ(ALUZ), .ACR(aluACR), .AVR(aluAVR), .B(BRKins),
                        .C_set(SET_C), .C_clr(CLR_C),
                        .I_set(SET_I), .I_clr(CLR_I), 
                        .V_clr(CLR_V),
                        .D_set(SET_D), .D_clr(CLR_D),
                        .DB(DBforSR),.ALU(ALUhold_out),.storedDB(storedDB),.opcode(OPforSR),.DBout(DB),
                        .status(SR_contents));
                        
                        
            /*            
            wire [7:0] PCLforDOR;
            sigLatchWclk pcl4dor1(phi1,fastClk,inFromPC_lo[0],PCLforDOR[0]);
            sigLatchWclk pcl4dor2(phi1,fastClk,inFromPC_lo[1],PCLforDOR[1]);
            sigLatchWclk pcl4dor3(phi1,fastClk,inFromPC_lo[2],PCLforDOR[2]);
            sigLatchWclk pcl4dor4(phi1,fastClk,inFromPC_lo[3],PCLforDOR[3]);
            sigLatchWclk pcl4dor5(phi1,fastClk,inFromPC_lo[4],PCLforDOR[4]);
            sigLatchWclk pcl4dor6(phi1,fastClk,inFromPC_lo[5],PCLforDOR[5]);
            sigLatchWclk pcl4dor7(phi1,fastClk,inFromPC_lo[6],PCLforDOR[6]);
            sigLatchWclk pcl4dor8(phi1,fastClk,inFromPC_lo[7],PCLforDOR[7]);
            
            wire [6:0] currT;  
            wire [6:0] TforDOR;
            sigLatchWclk t4dor1(phi1,fastClk,currT[0],TforDOR[0]);
            sigLatchWclk t4dor2(phi1,fastClk,currT[1],TforDOR[1]);
            sigLatchWclk t4dor3(phi1,fastClk,currT[2],TforDOR[2]);
            sigLatchWclk t4dor4(phi1,fastClk,currT[3],TforDOR[3]);
            sigLatchWclk t4dor5(phi1,fastClk,currT[4],TforDOR[4]);
            sigLatchWclk t4dor6(phi1,fastClk,currT[5],TforDOR[5]);
            sigLatchWclk t4dor7(phi1,fastClk,currT[6],TforDOR[6]);

            
                  
            
            wire jsrHi,jsrLo;
            assign jsrHi = (OPforDOR == `JSR_abs) & (TforDOR == `Tfour);
            assign jsrLo = (OPforDOR == `JSR_abs) & (TforDOR == `Tfive);
            */
            wire [6:0] currT;  
            wire [7:0] extDB_b0;
            triState8 dor_b(extDB,extDB_b0,(~haltAll) & (controlSigs[`nRW]));
            
            //dataOutReg          dor(haltAll,phi2,nRW,PCLforDOR,jsrHi,jsrLo, DB, extDB_b0);
            dataOutReg            dor(haltAll,phi2,nRW,DB,extDB_b0);
                    
            //moving on to left side...
            wire [7:0] predecodeOut, opcodeToIR;
            wire interrupt;
            
            wire FSMnmi,FSMirq,FSMres;
            assign interrupt = FSMnmi|FSMirq|FSMres;
            predecodeRegister   pdr(haltAll,phi2,DBsource,predecodeOut);
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
            
            wire en;
            instructionRegister ir_reg(haltAll,rstAll,currT,phi1,phi2, opcodeToIR, opcode, prevOpcode);
            
            assign SRflags = {1'd0,activeInt,1'd0,controlSigs[`O_ADL2],controlSigs[`O_ADL1],controlSigs[`O_ADL0]};
         
            wire [2:0] activeInt;
            wire [6:0] newT;
        
                          
            logicControl   control(.updateOthers(updateOthers),
                                  .currT(currT),.opcode(opcode),.prevOpcode(prevOpcode),.phi1(phi1),.phi2(phi2),
                                  .activeInt(activeInt),.aluRel(aluRel),.tempCarry(aluACR),.dir(dir),.carry(ACR),.statusReg(SR_contents),
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









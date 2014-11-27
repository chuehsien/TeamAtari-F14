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
                HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk,latchClk,extDB,	
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
            
			input HALT, IRQ_L, NMI_L, RES_L, SO, phi0_in,fastClk,latchClk;
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
            wire [66:0] controlSigs;
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
            wire ALUZ;
                        //clock
            wire phi1,phi2;
            wire haltAll,stop;
            clockGen clock(.HALT(HALT),.phi0_in(phi0_in),.fclk(fastClk),.stop(stop),.haltAll(haltAll),.RDY(RDY),
                                   .phi1_out(phi1),.phi2_out(phi2),.phi1_extout(phi1_out),.phi2_extout(phi2_out));
            
            assign RW = ~((controlSigs[`nRW])&(~RDY)&(~phi1));
            wire updateOthers;
            
          

            wire phi1_1,phi1_7;
             wire DBZ_latch;
            // internal signal latcher - used to latch signals across the phi1 uptick transition.
            wire nADH_ABH, nADL_ABL, DB_P, FLAG_DBZ, FLAG_ALU, FLAG_DB, P_DB, SET_C, CLR_C, SET_I, CLR_I, CLR_V, SET_D, CLR_D;
            assign holdAB = {nADH_ABH,FLAG_ALU,ALUZ,1'd0,1'd0,FLAG_DB,DBZ_latch,nADL_ABL};
            
            sigLatchWclk l1(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`nADH_ABH]),.out(nADH_ABH));
            sigLatchWclk l2(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`nADL_ABL]),.out(nADL_ABL));
            sigLatchWclk l3(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`DB_P]),.out(DB_P));
            sigLatchWclk l4(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`FLAG_DBZ]),.out(FLAG_DBZ));
            sigLatchWclk l5(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`FLAG_ALU]),.out(FLAG_ALU));
            sigLatchWclk l6(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`FLAG_DB]),.out(FLAG_DB));
            sigLatchWclk l7(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`P_DB]),.out(P_DB));
            sigLatchWclk l8(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`SET_C]),.out(SET_C));
            sigLatchWclk l9(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`CLR_C]),.out(CLR_C));
            sigLatchWclk l10(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`SET_I]),.out(SET_I));
            sigLatchWclk l11(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`CLR_I]),.out(CLR_I));
            sigLatchWclk l12(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`CLR_V]),.out(CLR_V));
            sigLatchWclk l13(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`SET_D]),.out(SET_D));
            sigLatchWclk l14(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`CLR_D]),.out(CLR_D));
            
            //phi2 uptick latcher:
            //nRW,STORE_DB, SB_X, SB_Y, SB_AC, SB_S
            sigLatchWclk l15(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`nRW]),.out(nRW));
            sigLatchWclk l16(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`STORE_DB]),.out(STORE_DB));
            sigLatchWclk l17(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SB_X]),.out(SB_X));
            sigLatchWclk l18(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SB_Y]),.out(SB_Y));
            sigLatchWclk l19(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SB_AC]),.out(SB_AC));
            sigLatchWclk l20(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SB_S]),.out(SB_S));
            
            //last ones
            wire O_ADL0, O_ADL1, O_ADL2, O_ADH0, O_ADH1to7;
            
            sigLatchWclk l21(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`O_ADL0]),.out(O_ADL0));
            sigLatchWclk l22(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`O_ADL1]),.out(O_ADL1));
            sigLatchWclk l23(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`O_ADL2]),.out(O_ADL2));
            sigLatchWclk l24(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`O_ADH0]),.out(O_ADH0));
            sigLatchWclk l25(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`O_ADH1to7]),.out(O_ADH1to7));


            wire PCH_ADH,PCL_ADL,ADD_ADL,S_ADL,DL_ADL,DL_ADH;
            sigLatchWclk l26(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`PCL_ADL]),.out(PCL_ADL));
            sigLatchWclk l27(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`PCH_ADH]),.out(PCH_ADH));
            sigLatchWclk l28(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`ADD_ADL]),.out(ADD_ADL));
            sigLatchWclk l29(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`S_ADL]),.out(S_ADL));
            sigLatchWclk l30(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`DL_ADL]),.out(DL_ADL));
            sigLatchWclk l31(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`DL_ADH]),.out(DL_ADH));

          
            wire [7:0] DBforSR;
            wire DBZ;
				wire [7:0] DBforDOR,ADLforABL,ADHforABH;
				
            sigLatchWclk8_2 db4dor(.refclk(phi1),.clk(latchClk),.in(DB),.out(DBforDOR)); 
		    sigLatchWclk8_2 adl4abl(.refclk(~phi1),.clk(latchClk),.in(ADL),.out(ADLforABL)); 
		    sigLatchWclk8_2 adh4abh(.refclk(~phi1),.clk(latchClk),.in(ADH),.out(ADHforABH)); 
				
            sigLatchWclk8_2 db4sr1(.refclk(~phi1),.clk(latchClk),.in(DB),.out(DBforSR)); 
            //sigLatchWclk db4sr2(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(DBZ),.out(DBZ_latch));
            
            wire [7:0] opcode,OPforSR;
				
           sigLatchWclk8_2 op4sr(.refclk(~phi1),.clk(latchClk),.in(opcode),.out(OPforSR)); 

                            
            wire  I_ADDC,SUMS,ANDS,EORS,ORS,SRS;
            //sigLatchWclk l32(phi1,latchClk,.in(controlSigs[`nDAA],.out(nDAA));    
            sigLatchWclk l33(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`I_ADDC]),.out(I_ADDC)); 
            sigLatchWclk l34(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SUMS]),.out(SUMS)); 
            sigLatchWclk l35(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`ANDS]),.out(ANDS)); 
            sigLatchWclk l36(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`EORS]),.out(EORS)); 
            sigLatchWclk l37(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`ORS]),.out(ORS)); 
            sigLatchWclk l38(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SRS]),.out(SRS)); 
                            
            wire DB_L_ADD, DB_ADD, ADL_ADD, O_ADD, SB_ADD;
            sigLatchWclk l39(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`DB_L_ADD]),.out(DB_L_ADD));    
            sigLatchWclk l40(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`DB_ADD]),.out(DB_ADD)); 
            sigLatchWclk l41(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`ADL_ADD]),.out(ADL_ADD)); 
            sigLatchWclk l42(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`O_ADD]),.out(O_ADD)); 
            sigLatchWclk l43(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`SB_ADD]),.out(SB_ADD)); 
                         
            wire S_S, S_SB, X_SB, Y_SB;
            //sigLatchWclk l44(phi1,latchClk,.in(controlSigs[`S_S],.out(S_S)); 
            //sigLatchWclk l45(phi1,latchClk,.in(controlSigs[`S_SB],.out(S_SB)); 
            //sigLatchWclk l46(phi1,latchClk,.in(controlSigs[`X_SB],.out(X_SB)); 
            //sigLatchWclk l47(phi1,latchClk,.in(controlSigs[`Y_SB],.out(Y_SB)); 
            
            wire ADD_SB0to6, ADD_SB7;
            sigLatchWclk l48(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`ADD_SB0to6]),.out(ADD_SB0to6)); 
            sigLatchWclk l49(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`ADD_SB7]),.out(ADD_SB7));            
             
             
            wire DL_DB,PCL_DB,PCH_DB;
            sigLatchWclk l50(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`DL_DB]),.out(DL_DB));
            sigLatchWclk l51(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`PCL_DB]),.out(PCL_DB));
            sigLatchWclk l52(.haltAll(stop),.refclk(~phi1),.clk(latchClk),.in(controlSigs[`PCH_DB]),.out(PCH_DB));
            
            
            wire nDSA,nDAA;
            sigLatchWclk l53(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`nDSA]),.out(nDSA));
            sigLatchWclk l54(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`nDAA]),.out(nDAA));
            
            
            wire SB_DB, SB_ADH;

            sigLatchWclkDual l55(.haltAll(stop),.clk(latchClk),.in(controlSigs[`SB_DB]),.out(SB_DB));
            sigLatchWclkDual l56(.haltAll(stop),.clk(latchClk),.in(controlSigs[`SB_ADH]),.out(SB_ADH));

            wire nI_PC,DEC_PC;
            sigLatchWclk l57(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`nI_PC]),.out(nI_PC));
            sigLatchWclk l58(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`DEC_PC]),.out(DEC_PC));
            
            wire ADL_PCL,ADH_PCH,PCL_PCL,PCH_PCH;
            sigLatchWclk l59(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`ADL_PCL]),.out(ADL_PCL));
            sigLatchWclk l60(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`ADH_PCH]),.out(ADH_PCH));
            sigLatchWclk l61(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`PCL_PCL]),.out(PCL_PCL));
            sigLatchWclk l62(.haltAll(stop),.refclk(phi1),.clk(latchClk),.in(controlSigs[`PCH_PCH]),.out(PCH_PCH));
            
        
            //datapath modules
            wire [7:0] DB_b0,ADL_b0,ADH_b0;
            
            wire latchRdy;
            wire [7:0] eDB_latch;
            eDBlatch save_extDB(.phi2(phi2), .haltAll(haltAll), .extDB(extDB),.latchRdy(latchRdy),.eDB_latch(eDB_latch));
            wire [7:0] DBsource;
            assign DBsource = (latchRdy) ? eDB_latch : extDB;
            inputDataLatch dl(.haltAll(haltAll),.data(idlContents),.rstAll(rstAll),.phi2(phi2),
                                        .DL_DB(DL_DB), .DL_ADL(DL_ADL), .DL_ADH(DL_ADH),.extDataBus(DBsource),
                        .DB(DB),.ADL(ADL),.ADH(ADH));
                        
                        
            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(.PCL_PCL(PCL_PCL), .ADL_PCL(ADL_PCL), .inFromPCL(inFromPC_lo), .ADL(ADL), 
                        .outToIncre(outToIncre_lo));
            decOrAddADL lo_2(.inc(~nI_PC),.dec(DEC_PC),.inAdd(outToIncre_lo),.carry(PCLC),.outAdd(outToPCL));
            wire [7:0] DB_b1,ADL_b1;
          
            PC          lo_3(.haltAll(haltAll),.rstAll(rstAll),.phi2(phi2), .PCL_DB(PCL_DB), .PCL_ADL(PCL_ADL),
                                  .inFromIncre(outToPCL),.DB(DB), .ADL(ADL),.PCout(inFromPC_lo));
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(.PCL_PCL(PCH_PCH), .ADL_PCL(ADH_PCH), .inFromPCL(inFromPC_hi), .ADL(ADH), 
                        .outToIncre(outToIncre_hi));    
            decOrAddADH hi_2(.inc(~nI_PC),.dec(DEC_PC),.inCarry(PCLC),.inAdd(outToIncre_hi),.outAdd(outToPCH));                      
            wire [7:0] DB_b2,ADH_b2;

            PC          hi_3(.haltAll(haltAll),.rstAll(rstAll),.phi2(phi2), .PCL_DB(PCH_DB), .PCL_ADL(PCH_ADH),
                                  .inFromIncre(outToPCH),.DB(DB), .ADL(ADH),.PCout(inFromPC_hi));
             
           wire ground = 1'b0;
            PULLUP pcMos1[7:0](.O(ADH));
            PULLUP pcMos2[7:0](.O(ADL));
            PULLUP pcMos3[7:0](.O(DB));
            PULLUP pcMos4[7:0](.O(SB));
           
            triState od_lo0(.out(ADL[0]),.in(ground),.en(O_ADL0));
            triState od_lo1(.out(ADL[1]),.in(ground),.en(O_ADL1));
            triState od_lo2(.out(ADL[2]),.in(ground),.en(O_ADL2));
            
            triState od_hi0(.out(ADH[0]),.in(ground),.en(O_ADH0));
            triState od_hi1[6:0](ADH[7:1],ground,O_ADH1to7);

            transBuf ta(.en(SB_DB), .leftDriver(sbDrivers), .rightDriver(dbDrivers), .left(SB), .right(DB));
            transBuf tb(.en(SB_ADH), .leftDriver(sbDrivers),.rightDriver(adhDrivers), .left(SB), .right(ADH));

        
            wire [7:0] A, B, ALU_out, ALUhold_out;
            wire tempAVR,tempACR,tempHC,tempRel;
            ALU     my_alu(.A(A), .B(B), .DAA(~nDAA), .I_ADDC(I_ADDC),.SUMS(SUMS), 
                        .ANDS(ANDS), .EORS(EORS), .ORS(ORS), .SRS(SRS), .ALU_out(ALU_out),
                        .AVR(tempAVR), .ACR(tempACR), .HC(tempHC),.relDirection(tempRel));
        
            //registers
            wire [7:0]  ADL_b3,SB_b3;           //triState sp_b0[7:0](ADL,ADL_b3,controlSigs[`S_ADL]);
            //triState sp_b1[7:0](SB,SB_b3,controlSigs[`S_SB]);
            SPreg   sp(.haltAll(haltAll),.rstAll(rstAll),.phi2(phi2),.S_S(controlSigs[`S_S]), .SB_S(SB_S), .S_ADL(S_ADL), 
                        .S_SB(controlSigs[`S_SB]), .SBin(SB), .ADL(ADL), .SB(SB));
                        
            wire [7:0] nDB;
            inverter inv(.DB(DB),.dataOut(nDB));
            Breg    b_reg(.DB_L_ADD(DB_L_ADD), .DB_ADD(DB_ADD), .ADL_ADD(ADL_ADD), .dataIn(DB),.INVdataIn(nDB),.ADL(ADL),.outToALU(B));
            
            Areg    a_reg(.O_ADD(O_ADD), .SB_ADD(SB_ADD), .SB(SB), .outToALU(A));
            
            wire alu_nDSA,alu_nDAA,aluAVR,aluACR,aluHC,aluRel;
            wire nDSA_latch,nDAA_latch,AVR,ACR,HC,dir;
            wire [7:0] ADL_b4,SB_b4;
            //triState addhold_b0[7:0](ADL,ADL_b4,controlSigs[`ADD_ADL]);
            //triState addhold_b1[6:0](SB[6:0],SB_b4[6:0],controlSigs[`ADD_SB0to6]);
            //triState addhold_b2(SB[7],SB_b4[7],controlSigs[`ADD_SB7]);
            AdderHoldReg addHold(.haltAll(haltAll),.phi2(phi2), .ADD_ADL(ADD_ADL), .ADD_SB0to6(ADD_SB0to6), .ADD_SB7(ADD_SB7), 
                                .addRes(ALU_out), .temp_nDSA(nDSA), .temp_nDAA(nDAA), .tempAVR(tempAVR), 
                                .tempACR(tempACR), .tempHC(tempHC),.tempRel(tempRel),
                                .ADL(ADL),.SB(SB),.adderReg(ALUhold_out),
                                .alu_nDSA(alu_nDSA),.alu_nDAA(alu_nDAA),.aluAVR(aluAVR),.aluACR(aluACR),.aluHC(aluHC),.aluRel(aluRel));
            
            ACRlatch    carryLatch(.haltAll(haltAll),.phi1(phi1),.in_nDSA(alu_nDSA),.in_nDAA(alu_nDAA),
                                              .inAVR(aluAVR),.inACR(aluACR),.inHC(aluHC),.inDir(aluRel),
                                                       .nDSA(nDSA_latch),.nDAA(nDAA_latch),.AVR(AVR),.ACR(ACR),.HC(HC),.dir(dir));
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
            
            decimalAdjust   decAdj(.haltAll(haltAll),.SBin(SB), .DSA(~nDSA_latch), .DAA(~nDAA_latch), .ACR(ACR), .HC(HC), .data(inFromDecAdder));
            wire [7:0] DB_b5,SB_b5;
           // triState accum_b0[7:0](DB,DB_b5,controlSigs[`AC_DB]);
           // triState accum_b1[7:0](SB,SB_b5,controlSigs[`AC_SB]);
            accum           a(.haltAll(haltAll),.accumVal(accumVal),.rstAll(rstAll),.phi2(phi2),.inFromDecAdder(inFromDecAdder), 
                                    .SB_AC(SB_AC), .AC_DB(controlSigs[`AC_DB]), .AC_SB(controlSigs[`AC_SB]), .DB(DB), .SB(SB));
            assign Accum = accumVal;           

            //addressbusreg loads by default every phi1. only disable if controlSig is asserted.
            wire [7:0] extAB_b0,extAB_b1;
            
            //triState ABR_b0[7:0](extABH,extAB_b0,~controlSigs[`nADH_ABH]);
            //triState ABR_b1[7:0](extABL,extAB_b1,~controlSigs[`nADL_ABL]);
            triState ABR_b0[7:0](extABH,extAB_b0,~RDY);
            triState ABR_b1[7:0](extABL,extAB_b1,~RDY);

            AddressBusReg   add_hi(.haltAll(haltAll),.phi1(phi1),.hold(nADH_ABH), .dataIn(ADHforABH), .dataOut(extAB_b0));
            AddressBusReg   add_lo(.haltAll(haltAll),.phi1(phi1),.hold(nADL_ABL), .dataIn(ADLforABL), .dataOut(extAB_b1));
                
            wire [7:0] SB_b6, SB_b7;
  
            register        x_reg(.haltAll(haltAll),.currVal(Xreg),.rstAll(rstAll),.phi2(phi2),.load(SB_X),.bus_en(controlSigs[`X_SB]),.SBin(SB),.SB(SB));
            register        y_reg(.haltAll(haltAll),.currVal(Yreg),.rstAll(rstAll),.phi2(phi2),.load(SB_Y),.bus_en(controlSigs[`Y_SB]),.SBin(SB),.SB(SB));
            
       
            
         
            wire BRKins;

            assign BRKins = (OPforSR == `BRK || OPforSR == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            wire [7:0] SR_contents;
            
       

            //store db/alu status during phi2, and update SR in phi1. applicable for TAY,TYA etc. only.
            reg [7:0] storedDB;
//            FlipFlop8   store_db(phi2,DB,(STORE_DB&~haltAll),storedDB);
            always @ (posedge phi2) begin
                if (haltAll) storedDB <= storedDB;
                else if (STORE_DB) storedDB <= DB;
                else storedDB <= storedDB;
            end
            
            assign DBZ  = ~(|DB);
            assign ALUZ = ~(|ALUhold_out);
            
            
            wire [7:0] DB_b8;

            
           statusReg SR(.haltAll(haltAll),.rstAll(rstAll),.phi1(phi1),.DB_P(DB_P),
           .loadDBZ(FLAG_DBZ),.flagsALU(FLAG_ALU),.flagsDB(FLAG_DB),
                        .P_DB(P_DB), .ACR(aluACR), .AVR(aluAVR), .B(BRKins),
                        .C_set(SET_C), .C_clr(CLR_C),
                        .I_set(SET_I), .I_clr(CLR_I), 
                        .V_clr(CLR_V),
                        .D_set(SET_D), .D_clr(CLR_D),
                        .DB(DBforSR),.ALU(ALUhold_out),.storedDB(storedDB),.opcode(OPforSR),.DBout(DB),
                        .status(SR_contents));
                        
                        

            wire [6:0] currT;  
            wire [7:0] extDB_b0;
            triState8 dor_b(extDB,extDB_b0,(~RDY) & (controlSigs[`nRW]));
            
            //dataOutReg          dor(haltAll,phi2,nRW,PCLforDOR,jsrHi,jsrLo, DB, extDB_b0);
            dataOutReg            dor(.haltAll(haltAll),.phi2(phi2),.en(nRW),.dataIn(DBforDOR),.dataOut(extDB_b0));
                    
            //moving on to left side...
            wire [7:0] predecodeOut, opcodeToIR;
            wire interrupt;
            
            wire FSMnmi,FSMirq,FSMres;
            assign interrupt = FSMnmi|FSMirq|FSMres;
            predecodeRegister   pdr(.haltAll(haltAll),.phi2(phi2),.extDataBus(DBsource),.outToIR(predecodeOut));
            predecodeLogic      pdl(.irIn(predecodeOut),.interrupt(interrupt),.OPout(opcodeToIR));
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
            instructionRegister ir_reg(.haltAll(haltAll),.rstAll(rstAll),.currT(currT),
                                                  .phi1(phi1),.phi2(phi2), .OPin(opcodeToIR), .OPout(opcode), .prevOP(prevOpcode));
            
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
                                    
          
            wire outNMI_L,outIRQ_L,outRES_L;
            wire nmiPending,irqPending,resPending,nmiDone,intHandled;
            wire [1:0] currState;
            //wire RDYout; //this is the one which affects the FSM.
            wire IRQ_Lfiltered;
            assign IRQ_Lfiltered = IRQ_L | SR_contents[`status_I];
            interruptLatch   iHandlerLatch(.haltAll(haltAll),.phi1(phi1),.NMI_L(NMI_L),.IRQ_Lfiltered(IRQ_Lfiltered),.RES_L(RES_L),
                                                         .outNMI_L(outNMI_L),.outIRQ_L(outIRQ_L),.outRES_L(outRES_L));
            interruptControl iHandler(.rstAll(rstAll),.NMI_L(outNMI_L),.IRQ_L(outIRQ_L),.RES_L(outRES_L),.nmiDone(nmiDone),
                        .nmiPending(nmiPending),.irqPending(irqPending),.resPending(resPending));

            assign nmiDone = intHandled & (activeInt == `NMI_i);
            
            PLAinterruptControl  plaInt(.haltAll(haltAll),.phi1(phi1),.nmiPending(nmiPending),.resPending(resPending),.irqPending(irqPending),
                                                    .intHandled(intHandled),.activeInt(activeInt),.nmi(FSMnmi),.irq(FSMirq),.res(FSMres));
                                        
            plaFSM      fsm(.haltAll(haltAll),.currState(currState),.phi1(phi1),.phi2(phi2),.RDY(1'b1),.nextT(newT), .rst(FSMres),
                                   .brkNow(brkNow),.currT(currT),.intHandled(intHandled), .rstAll(rstAll));          
            
            
            
            assign second_first_int = {FSMnmi,FSMirq,FSMres,intHandled,1'd0,nmiPending,irqPending,resPending};
endmodule









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
            wire [7:0] DB, ADL, ADH, SB;
            
            //control sigs
            wire [62:0] controlSigs;
            
            //interrupt sigs
            wire nmiHandled, irqHandled, resHandled, nmiPending, irqPending, resPending;
            

            //clock
            wire phi1,phi2;
			clockGen clock(phi0_in,phi1,phi2,phi1_out,phi2_out);
            
			
            //datapath modules
            inputDataLatch dl(phi1,phi2,controlSigs[`DL_DB], controlSigs[`DL_ADL], controlSigs[`DL_ADH],extDB,
                        DB,ADL,ADH);
            
            wire [7:0] inFromPC_lo, outToIncre_lo, outToPCL;
            wire PCLC;
            PcSelectReg lo_1(controlSigs[`PCL_PCL], controlSigs[`ADL_PCL], inFromPC_lo, ADL, 
                        outToIncre_lo);
            increment   lo_2(~controlSigs[`nI_PC],outToIncre_lo,PCLC,outToPCL);
            PC          lo_3(phi2, controlSigs[`PCL_DB], controlSigs[`PCL_ADL],outToPCL,DB, ADL,inFromPC_lo);
            
            
            wire [7:0] inFromPC_hi, outToIncre_hi, outToPCH;
            PcSelectReg hi_1(controlSigs[`PCH_PCH], controlSigs[`ADH_PCH], inFromPC_hi, ADL, 
                        outToIncre_hi);           
            increment   hi_2(PCLC,outToIncre_hi, ,outToPCH);
            PC          hi_3(phi2, controlSigs[`PCH_DB], controlSigs[`PCH_ADH],outToPCH,DB, ADL,inFromPC_hi);
               
            prechargeMos        pcMos1(phi2,ADH); 
            prechargeMos        pcMos2(phi2,ADL);
            prechargeMos        pcMos3(phi2,DB);
            prechargeMos        pcMos4(phi2,SB);
            opendrainMosADL     od_lo(controlSigs[`O_ADL0],controlSigs[`O_ADL1],controlSigs[`O_ADL2],ADL);
            opendrainMosADH     od_hi(controlSigs[`O_ADH0],controlSigs[`O_ADH1to7],ADH);
            tranif1             pass1[7:0](SB, ADH, controlSigs[`SB_ADH]);
            tranif1             pass2[7:0](SB, DB, controlSigs[`SB_DB]);
            
            wire [7:0] A, B, ALU_out;
            wire decMode,AVR,ACR,HC; //will be connected to status reg
            ALU     alu(A, B, decMode, controlSigs[`I_ADDC], controlSigs[`SUMS], 
                        controlSigs[`ANDS], controlSigs[`EORS], controlSigs[`ORS], 
                            controlSigs[`SRS], ALU_out, AVR, ACR, HC);
            
            
            //registers
            SPreg   sp(controlSigs[`S_S], controlSigs[`SB_S], controlSigs[`S_ADL], 
                        controlSigs[`S_SB], SB, ADL, SB);
                        
            wire [7:0] nDB;
            inverter inv(DB,nDB);
            Breg    b_reg(controlSigs[`DB_L_ADD], controlSigs[`DB_ADD], controlSigs[`ADL_ADD], DB,nDB,ADL,B);
            
            Areg    a_reg(controlSigs[`O_ADD], controlSigs[`SB_ADD], SB, A);
            
   
            AdderHoldReg addHold(phi2, controlSigs[`ADD_ADL], controlSigs[`ADD_SB0to6], controlSigs[`ADD_SB7], ALU_out,
                                ADL,SB);
            
            wire [7:0] inFromDecAdder;
            wire updateSR_accum, updateSR_x, updateSR_y;
            decimalAdjust   decAdj(SB, ~controlSigs[`nDSA], ~controlSigs[`nDAA], ACR, HC, phi2,inFromDecAdder);
            accum           a(inFromDecAdder, controlSigs[`SB_AC], controlSigs[`AC_DB], controlSigs[`AC_SB],
                            DB,SB,updateSR_accum);
                        
            AddressBusReg   add_hi(phi1&controlSigs[`ADH_ABH], ADH, extAB[15:8]);
            AddressBusReg   add_lo(phi1&controlSigs[`ADL_ABL], ADL, extAB[7:0]);
            
            register        x_reg(controlSigs[`SB_X],controlSigs[`X_SB],SB,updateSR_x);
            register        y_reg(controlSigs[`SB_Y],controlSigs[`Y_SB],SB,updateSR_y);
            
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
            assign BRKins = (real_opcode == `BRK || real_opcode == `PHP);
            //need to assert B in SR when performing BRK/PHP.
            statusReg(phi2,updateSR, controlSigs[`P_DB], DBZ, ACR, AVR, ~controlSigs[`nDAA], BRKins,
                        controlSigs[`SET_C], controlSigs[`CLR_C],
                        controlSigs[`SET_I], controlSigs[`CLR_I],
                        controlSigs[`SET_V], controlSigs[`CLR_V],
                        controlSigs[`SET_D], controlSigs[`CLR_D],
                        DB_N, 
                        DB,
                    DB,decMode,statusReg);
                    
                    
            wire [7:0] dataOutBuf;
            dataOutReg          dor(phi1, phi2, DB, dataOutBuf);
            dataBusTristate     dataBuf(controlSigs[`nRW] & phi2, dataOutBuf,extDB);
            
            //moving on to left side...
            wire [7:0] precodeOut, outToIR;
            wire interrupt;
            
            assign interrupt = resPending | nmiPending | irqPending;
            predecodeRegister   pdr(phi2,extDB,precodeOut);
            predecodeLogic      pdl(precodeOut,interrupt,real_outToIR,effective_outToIR);
            
            wire loadIR, T1now;
            assign loadIR = T1now & phi1 & RDY;
            instructionRegister ir_reg(loadIR, real_outToIR,effective_outToIR,real_opcode, effective_opcode);

            interruptResetControl iHandler(phi2,NMI_L, IRQ_L, RES_L, nmiHandled, irqHandled, resHandled,
                            nmiPending,irqPending,resPending);
            
            wire RDYout; //this is the one which affects the FSM.
            readyControl rdy_control(phi2, RDY, nRW, RDYout);
            
            // finally, control logic
            plaFSM      myFSM(phi1,phi2,nmiPending,irqPending,resPending,RDYout,effective_opcode,statusReg,
                                controlSigs,SYNC,T1now,nmiHandled, irqHandled, resHandled);
                                
                        
endmodule













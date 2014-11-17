// this module contains all contains that are driven by clocks and the left side of the block diagram
`include "CPU/Control/Tcontrol.v"
`include "CPU/Control/Logiccontrol2.v"

module clockGen(HALT,phi0_in,fclk,
                haltAll,RDY,phi1_out,phi2_out,phi1_extout,phi2_extout);
                
    input HALT,phi0_in,fclk;
    output reg haltAll, RDY = 1'b0;
    
     (* clock_signal = "yes" *) output phi1_out,phi2_out,phi1_extout,phi2_extout;
    
    reg stop = 1'b0;
    
    
    //latch on phi1 ticks
    always @ (negedge phi0_in) begin
        stop <= HALT;
    end
    
    always @ (posedge fclk) begin
      haltAll <= stop;
    end
    
    always @ (posedge phi0_in) begin
        RDY <= haltAll;
        
    end
    
    BUFG a(phi1_out,~phi0_in);
    BUFG b(phi2_out,phi0_in);
    
    BUFG c(phi1_extout,phi1_out);
    BUFG d(phi2_extout,phi2_out);
    
endmodule

module predecodeRegister(haltAll,phi2,extDataBus,
                        outToIR);
                        
    input haltAll,phi2;
    input [7:0] extDataBus;
    output [7:0] outToIR;

    wire phi2;
    wire [7:0] extDataBus;
    reg [7:0] outToIR = `BRK;

    always @ (posedge phi2) begin
        if (haltAll) outToIR <= outToIR;
        else outToIR <= extDataBus;      
    end

endmodule

module predecodeLogic(irIn, interrupt,
                        OPout);  

    input [7:0] irIn;
    input interrupt;
    output [7:0] OPout;

    wire [7:0] irIn;
    wire interrupt;
    wire [7:0] OPout;

    assign OPout = (~interrupt) ? irIn : 8'd00;

endmodule
                 
/*
module inoutLatch3(rstAll, phi1,data1,data2,data3,done1,done2,done3,
                    out1,out2,out3);
    input rstAll, phi1,data1,data2,data3,done1,done2,done3;
    output out1,out2,out3;
    
    reg out1,out2,out3 = 1'b0;
    
    wire done;
    assign done = done1|done2|done3;
    
    wire rstOrDone;
    assign rstOrDone = rstAll | done;
    always @ (posedge phi1 or posedge rstOrDone) begin
            
        out1 <= (rstOrDone) ? 1'b0 : data1;
        out2 <= (rstOrDone) ? 1'b0 : data2;
        out3 <= (rstOrDone) ? 1'b0 : data3;

    end

endmodule
*/

module interruptLatch(haltAll,phi1,NMI_L,IRQ_Lfiltered,RES_L,outNMI_L,outIRQ_L,outRES_L);
    input haltAll,phi1,NMI_L,IRQ_Lfiltered,RES_L;
    output outNMI_L,outIRQ_L,outRES_L;
    
    wire phi1,NMI_L,IRQ_Lfiltered,RES_L;
    reg outNMI_L,outIRQ_L,outRES_L = 1'b1;

    always @ (posedge phi1) begin
        if (~RES_L) begin 
            outIRQ_L <= 1'b1;
            outNMI_L <= 1'b1;
        end

        else begin
            outIRQ_L <= IRQ_Lfiltered;  
            outNMI_L <= NMI_L;
        end
        
        outRES_L <= RES_L;

    end

    
endmodule




//captures the edge.
module interruptControl(rstAll,NMI_L, IRQ_L, RES_L,nmiDone,
                        nmiPending,irqPending,resPending);
                           
    input rstAll,NMI_L,IRQ_L,RES_L,nmiDone;
    output nmiPending,irqPending,resPending;
   
   FDCPE_1 #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_inst (
      .Q(nmiPending),      // 1-bit Data output
      .C(NMI_L),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .CLR(nmiDone|rstAll),  // 1-bit Asynchronous clear input
      .D(1'b1),     // 1-bit Data input
      .PRE(1'b0)
   );
   
    assign irqPending = ~IRQ_L;
    assign resPending = ~RES_L;
endmodule

//interprets, prioritize interrupts and send to logic
//only tick in new stuff when activeint is none.
module PLAinterruptControl(haltAll,phi1, nmiPending,resPending,irqPending,intHandled,
        activeInt,nmi,irq,res);
        
    input haltAll,phi1, nmiPending,resPending,irqPending,intHandled;
    output reg [2:0] activeInt = 3'd0;
    output nmi,irq,res;
    
    //internal
    reg nmi_latch = 1'b0; 
    reg res_latch = 1'b0; 
    reg irq_latch = 1'b0; 

    always @ (negedge phi1) begin
       if (haltAll) begin
            nmi_latch <= nmi_latch;    
            irq_latch <= irq_latch;
            res_latch <= res_latch;
      
       end
       
       else begin
           nmi_latch <= nmiPending;    
           irq_latch <= irqPending;
           res_latch <= resPending;
        end
    end
    
    wire intg;
    assign intg = nmi_latch & irq_latch;
    
    assign nmi = intg | nmi_latch;
    assign irq = ~intg & irq_latch;
    assign res = res_latch;

    always @ (posedge phi1) begin
        if (res) activeInt <= `RST_i;
        else if (intHandled) activeInt <= `NONE;
        else if (activeInt!=`NONE) activeInt <= activeInt;
        else if (nmi) activeInt <= `NMI_i;
        else if (irq) activeInt <= `IRQ_i;
        else activeInt <= `NONE;
    end


endmodule

//nRW - reading, ~nRW - writing
module readyControl(phi2, RDY,nRW,
                    RDYout);
    input phi2;
    input RDY, nRW;
    output RDYout;
    
    wire phi2;
    wire RDY,nRW;
    reg RDYout = 1'b1;
    
    always @ (posedge phi2) begin
        RDYout = ~nRW | RDY; //processor is RDY (running) when writing, or when RDY assert.
    end
endmodule



                                    /*
module logicControl(updateOthers,currT,opcode,opcodeToIR,prevOpcode,phi1,phi2,activeInt,aluRel,tempOvf,tempCarry,ovf,carry,statusReg,
                                    nextT,nextControlSigs);                                  
                                    
        output updateOthers;              
        input [6:0] currT;
        input [7:0] opcode,opcodeToIR,prevOpcode;
        input phi1,phi2;
        input [2:0] activeInt;
        input aluRel,tempOvf,tempCarry,ovf,carry;
        input [7:0] statusReg;
        output [6:0] nextT;
        output [65:0] nextControlSigs;
        */
module logicControl(updateOthers,currT,opcode,prevOpcode,phi1,phi2,activeInt,aluRel,tempCarry,dir,carry,statusReg,
                                    nextT,nextControlSigs);                                  
                                    
        output updateOthers;              
        input [6:0] currT;
        input [7:0] opcode,prevOpcode;
        input phi1,phi2;
        input [2:0] activeInt;
        input aluRel,tempCarry,dir,carry;
        input [7:0] statusReg;
        output [6:0] nextT;
        output [66:0] nextControlSigs;        
        
        
        wire relOpcode; //opcode which do rel jumps. (branch)
        assign relOpcode = (opcode == `BPL_rel ||opcode == `BMI_rel ||opcode == `BVC_rel ||opcode == `BVS_rel ||opcode == `BCC_rel ||
		opcode == `BCS_rel ||opcode == `BNE_rel ||opcode == `BEQ_rel);
        //next T depends on immediate ACR.
        wire effCarry;
        //page cross occur when jumping forward and C = 1, OR jumping backward, and c=0.
        assign effCarry = relOpcode ? ((tempCarry & aluRel) | (~tempCarry & ~aluRel)) : tempCarry;
        
        
        Tcontrol    tCon(currT,opcode,effCarry,statusReg,nextT);
        wire updateOthers;
        // the logic depends on the ticked in ACR in the ACRlatch, and AVR in the AVRlatch
        randomLogic2     randomLog(updateOthers,currT,opcode,prevOpcode,phi1,phi2,activeInt,dir,carry,statusReg[`status_C],statusReg[`status_D],nextControlSigs);
     /*
        randomLogicPredict   randLog(.T(currT),.nextT(nextT),.currOP(opcode),.nextOP(opcodeToIR),
                                    .phi1(phi1),.phi2(phi2),.activeInt(activeInt),
                                    .latchedAVR(ovf),.latchedACR(carry),
                                    .aluholdAVR(tempOvf),.aluholdACR(tempCarry),
                                    .statusC(statusReg[`status_C]),.statusD(statusReg[`status_D]),
                                    .control(nextControlSigs)); 
        //if phi1: use opcode,currT,phi2,AVR,ACR (both latched)to make decisions, 
        // phi1 need to consider prevOpcode too. in this case uses opcode&(nextT == t2).
       */ 
        //if phi2: use opcodeToIR, nextT,phi1,aluAVR,aluACR to make decisions
endmodule


module controlLatch(fastClk,inControl,outControl);
    input fastClk;
    input [65:0] inControl;
    output [65:0] outControl;
    
    reg [65:0] outControl_b = `emptyControl;
    always @ (posedge fastClk) begin
        outControl_b <= inControl;
        
    end
    
    buf t[65:0](outControl,outControl_b);
endmodule

module instructionRegister(haltAll,rstAll,currT,phi1,phi2,OPin,OPout,prevOP);

    input haltAll,rstAll;
    input [6:0] currT;
    input phi1,phi2;
    input [7:0] OPin;
    output reg [7:0] OPout = `BRK;
    output reg [7:0] prevOP = `BRK;
    
    wire en, readyForNext;

    assign readyForNext = (currT == `Tone || currT == `T1NoBranch ||
                        currT == `T1BranchNoCross || currT == `T1BranchCross) & ~phi1;
    buf tickB(en,readyForNext);
  
    //wait for (currT==`Tone & phi2) to enable.
    always @ (posedge phi1) begin
            if (haltAll) begin
                OPout <= OPout;
                prevOP <= prevOP;
            
            end
            
			else  begin
                OPout <= rstAll ? 8'h00 : ((en) ? OPin : OPout);
                prevOP <= rstAll ? 8'h00 : ((en) ? OPout : prevOP);
            end
			
        
    end

endmodule




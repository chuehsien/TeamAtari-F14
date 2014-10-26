// this module contains all contains that are driven by clocks and the left side of the block diagram
`include "Control/Tcontrol.v"
`include "Control/Logiccontrol2.v"

module clockGen(HALT,phi0_in,
                haltAll,RDY,phi1_out,phi2_out,phi1_extout,phi2_extout);
                
    input HALT,phi0_in;
    output haltAll,RDY;
    reg haltAll;
     (* clock_signal = "yes" *) output phi1_out,phi2_out,phi1_extout,phi2_extout;

    /*
    //when disabled, phi0 is stuck at 0. which coincidentally is when phi1 stuck at 1.
    //when enabled again, input should be already at 0 (phi1 tick just occurred), which merges nicely with the stuck at 0 phi.
    //BUFGCE clockBuf(.O(phi0_buf),.I(phi0_in),.CE(~haltEn));
    
    BUFGCTRL #(
       .INIT_OUT(0),           // Initial value of BUFGCTRL output ($VALUES;)
       .PRESELECT_I0("TRUE"), // BUFGCTRL output uses I0 input ($VALUES;)
       .PRESELECT_I1("FALSE")  // BUFGCTRL output uses I1 input ($VALUES;)
    )
    BUFGCTRL_inst (
       .O(phi0_buf),             // 1-bit output: Clock output
       .CE0(1'b1),         // 1-bit input: Clock enable input for I0
       .CE1(1'b0),         // 1-bit input: Clock enable input for I1
       .I0(phi0_in),           // 1-bit input: Primary clock
       .I1(1'b0),           // 1-bit input: Secondary clock
       .IGNORE0(1'b1), // 1-bit input: Clock ignore input for I0
       .IGNORE1(1'b1), // 1-bit input: Clock ignore input for I1
       .S0(~haltEn),           // 1-bit input: Clock select for I0
       .S1(haltEn)            // 1-bit input: Clock select for I1
    );
   
   
    //LDCPE #(.INIT(1'b0)) clockLatch(.CLR(1'b0),.PRE(1'b0),.G(~haltEn),.GE(1'b1),.D(phi0_in),.Q(phi0_latch));
    */
    
    
    //latch on phi1 ticks
    always @ (negedge phi0_in) begin
        haltAll <= HALT;
    end
    assign RDY = haltAll;
    
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

            outIRQ_L <= IRQ_Lfiltered;  
            outNMI_L <= NMI_L;
            outRES_L <= RES_L;

    end

    
endmodule




//captures the edge.
module interruptControl(NMI_L, IRQ_L, RES_L,nmiDone,
                        nmiPending,irqPending,resPending);
                           
    input NMI_L,IRQ_L,RES_L,nmiDone;
    output nmiPending,irqPending,resPending;
   
    (* clock_signal = "yes" *)wire NMI_L;
   
   FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_inst (
      .Q(nmiPending),      // 1-bit Data output
      .C(~NMI_L),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .CLR(nmiDone),  // 1-bit Asynchronous clear input
      .D(1'b1)       // 1-bit Data input
   );
   
    assign irqPending = ~IRQ_L;
    assign resPending = ~RES_L;
endmodule

//interprets, prioritize interrupts and send to logic
//only tick in new stuff when activeint is none.
module PLAinterruptControl(haltAll,phi1, nmiPending,resPending,irqPending,intHandled,
        activeInt,nmi,irq,res);
        
    input haltAll,phi1, nmiPending,resPending,irqPending,intHandled;
    output [2:0] activeInt;
    output nmi,irq,res;
    
    //internal
    reg nmi_latch,res_latch,irq_latch = 1'b0;

    always @ (posedge phi1) begin
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
    
    wire [2:0] activeIntNext;
    assign activeIntNext = res ? `RST_i : 
                            ((activeInt!=`NONE) ? activeInt :
                            (nmi ? `NMI_i :
                            (irq ? `IRQ_i : `NONE)));

   FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst0(
      .Q(activeInt[0]),      // 1-bit Data output
      .C(phi1),      // 1-bit Clock input
      .CE(~haltAll),    // 1-bit Clock enable input
      .R(intHandled),  // 1-bit Asynchronous clear input
      .D(activeIntNext[0])       // 1-bit Data input
   );

   FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst1(
      .Q(activeInt[1]),      // 1-bit Data output
      .C(phi1),      // 1-bit Clock input
      .CE(~haltAll),    // 1-bit Clock enable input
      .R(intHandled),  // 1-bit Asynchronous clear input
      .D(activeIntNext[1])       // 1-bit Data input
   );
   
   FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_inst2(
      .Q(activeInt[2]),      // 1-bit Data output
      .C(phi1),      // 1-bit Clock input
      .CE(~haltAll),    // 1-bit Clock enable input
      .R(intHandled),  // 1-bit Asynchronous clear input
      .D(activeIntNext[2])       // 1-bit Data input
   );
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


module logicControl(currT,opcode,prevOpcode,phi1,phi2,activeInt,tempCarry,carry,statusReg,
                                    nextT,nextControlSigs);
                                    
        input [6:0] currT;
        input [7:0] opcode,prevOpcode;
        input phi1,phi2;
        input [2:0] activeInt;
        input tempCarry,carry;
        input [7:0] statusReg;
        output [6:0] nextT;
        output wire [64:0] nextControlSigs;
        
        //next T depends on immediate ACR.
        Tcontrol    tCon(currT,opcode,tempCarry,statusReg,nextT);
        
        // the logic depends on the ticked in ACR in the ACRlatch.
        randomLogic2     randomLog(currT,opcode,prevOpcode,phi1,phi2,activeInt,carry,statusReg[`status_C],statusReg[`status_D],nextControlSigs);

endmodule


module controlLatch(phi1,phi2,inControl,outControl);
    input phi1,phi2;
    input [64:0] inControl;
    output reg [64:0] outControl = `emptyControl;
    
    always @ (posedge phi1 or posedge phi2) 
        outControl <= inControl;
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
                        currT == `T1BranchNoCross || currT == `T1BranchCross) & phi2;
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



// this module contains all contains that are driven by clocks and the left side of the block diagram
`include "Control/Tcontrol.v"
`include "Control/Logiccontrol.v"

module clockGen(phi0_in,
                phi1_out,phi2_out,phi1_extout,phi2_extout);
                
    input phi0_in;
    output phi1_out,phi2_out,phi1_extout,phi2_extout;

    wire phi0_in;
    wire phi1_out,phi2_out,phi1_extout,phi2_extout;
    
    buf a(phi1_out,phi0_in);
    not b(phi2_out,phi1_out);
    
    assign phi1_extout = phi1_out;
    assign phi2_extout = phi2_out;
    
endmodule

module predecodeRegister(phi2,extDataBus,
                        outToIR);
                        
    input phi2;
    input [7:0] extDataBus;
    output [7:0] outToIR;

    wire phi2;
    wire [7:0] extDataBus;
    reg [7:0] outToIR = `BRK;

    
    always @ (posedge phi2) begin
        outToIR <= extDataBus;      
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

module interruptLatch(rstAll,phi1,en,NMI_L,IRQ_L,RES_L,outNMI_L,outIRQ_L,outRES_L);
    input rstAll,phi1,en,NMI_L,IRQ_L,RES_L;
    output outNMI_L,outIRQ_L,outRES_L;
    
    wire rstAll,phi1,en,NMI_L,IRQ_L,RES_L;
    reg outNMI_L,outIRQ_L,outRES_L = 1'b1;
    
    always @ (posedge phi1 or posedge rstAll) begin
        outIRQ_L <= (rstAll) ? 1'b1 :
                    ((en) ? IRQ_L : outIRQ_L);
        
        outNMI_L <= (rstAll) ? 1'b1 : NMI_L;
        outRES_L <= (rstAll) ? 1'b1 : RES_L;
       
    end
    
endmodule


module interruptControl(rstAll,NMI_L, IRQ_L, RES_L, 
                           nmi,irq,res);
    input rstAll, NMI_L,IRQ_L,RES_L;
    output nmi,irq,res;
    
    wire rstAll, NMI_L,IRQ_L,RES_L;
    wire nmi,irq,res;
 
    reg nmiPending, irqPending, resPending = 1'b0;

    always @ (negedge NMI_L or posedge rstAll) begin
        if (rstAll) nmiPending <= 1'b0;
        else nmiPending <= 1'b1;
    end
    
    always @ (IRQ_L or rstAll) begin
        if (rstAll) irqPending <= 1'b0;
        else irqPending <= ~IRQ_L;
    end
    
    always @ (RES_L or rstAll) begin
        if (rstAll) resPending <= 1'b0;
        else resPending <= ~RES_L;
    end
    
    wire intg;
    assign intg = nmiPending & irqPending;
    assign nmi = intg | nmiPending;
    assign irq = ~intg & irqPending;
    assign res = resPending;
    
endmodule

module PLAinterruptControl(phi1, rstAll,nmiPending,rstPending,irqPending,intHandled,activeInt);
    input phi1,rstAll,nmiPending,rstPending,irqPending,intHandled;
	output [2:0] activeInt;
    
	reg [2:0] activeInt = `NONE;
    
    always @ (nmiPending or rstPending or irqPending or intHandled) begin
    
        if (intHandled & (activeInt!=`NONE)) activeInt = `NONE;
        else if (rstPending) activeInt = `RST_i;
        else if (nmiPending) activeInt = `NMI_i;
        else if (irqPending) activeInt = `IRQ_i;
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
        randomLogic     randomLog(currT,opcode,prevOpcode,phi1,phi2,activeInt,carry,statusReg[`status_C],statusReg[`status_D],nextControlSigs);

endmodule


module controlLatch(phi1,phi2,inControl,outControl);
    input phi1,phi2;
    input [64:0] inControl;
    output reg [64:0] outControl = `emptyControl;
    
    always @ (posedge phi1 or posedge phi2) 
        outControl <= inControl;
endmodule


module instructionRegister(currT,RDY,phi1,phi2,OPin,OPout,prevOP);
    input [6:0] currT;
    input RDY,phi1,phi2;
    input [7:0] OPin;
    output reg [7:0] OPout = `BRK;
    output reg [7:0] prevOP = `BRK;
    
    reg en = 1'b0;
    
    (* clock_signal = "yes" *)
    wire tick,tock;
    
    
    assign tick = (currT == `Tone || currT == `T1NoBranch ||
                        currT == `T1BranchNoCross || currT == `T1BranchCross) & phi2 & RDY;
    always @ (tick) begin
        if (tick) en = 1'b1;
        else en = 1'b0;
    end
    
    assign tock = phi1 | en;
    //wait for (currT==`Tone & phi2) to enable.
    always @ (posedge tock) begin
			OPout <= (en) ? OPin : OPout;
			prevOP <= (en) ? OPout : prevOP;
			
        
    end

endmodule



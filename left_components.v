// this module contains all contains that are driven by clocks and the left side of the block diagram

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
    reg [7:0] outToIR;

    
    always @ (posedge phi2) begin
        outToIR <= extDataBus;      
    end

endmodule

module predecodeLogic(rstAll,irIn, interrupt,
                        realOpcode, irOut,loadOpcode);
    
    input rstAll;
    input [7:0] irIn;
    input interrupt;
    output [7:0] realOpcode,irOut;
    output loadOpcode;
    
    wire rstAll;
    wire [7:0] irIn;
    wire interrupt;
    wire [7:0] realOpcode, irOut;
    reg loadOpcode;
    
    assign irOut = (~interrupt) ? irIn : 8'd00;
    assign realOpcode = irIn;
    
    always @ (irOut) begin
        loadOpcode = ~loadOpcode;
    end
    
    always @ (posedge rstAll) begin
        loadOpcode = 1'b0;
    end
endmodule
                 

module inoutLatch3(rstAll, phi1,data1,data2,data3,done1,done2,done3,
                    out1,out2,out3);
    input rstAll, phi1,data1,data2,data3,done1,done2,done3;
    output out1,out2,out3;
    
    reg out1,out2,out3;
    
    always @ (posedge phi1) begin
        out1 <= data1;
        out2 <= data2;
        out3 <= data3;
    end
    always @ (posedge rstAll) begin
        out1 <= 1'b0;
        out2 <= 1'b0;
        out3 <= 1'b0;
    end
    
    always @ (posedge done1) begin
        out1 <= 1'b0;
    end
    
    always @ (posedge done2) begin
        out2 <= 1'b0;
    end
    
    always @ (posedge done3) begin
        out3 <= 1'b0;
    end
endmodule

module interruptLatch(rstAll,phi1,en,NMI_L,IRQ_L,RES_L,outNMI_L,outIRQ_L,outRES_L);
    input rstAll,phi1,en,NMI_L,IRQ_L,RES_L;
    output outNMI_L,outIRQ_L,outRES_L;
    
    wire rstAll,phi1,en,NMI_L,IRQ_L,RES_L;
    reg outNMI_L,outIRQ_L,outRES_L;
    
    always @ (posedge phi1) begin
        if (en) begin
            outIRQ_L <= IRQ_L;
        end
        outNMI_L <= NMI_L;
        outRES_L <= RES_L;
        
    end
    
    always @ (posedge rstAll) begin
        outIRQ_L <= 1'b1;
        outNMI_L <= 1'b1;
        outRES_L <= 1'b1;
    end
endmodule


module interruptResetControl(rstAll,NMI_L, IRQ_L, RES_L, nmiHandled, irqHandled, resHandled,
                            nmi,irq,res);
    input rstAll,NMI_L,IRQ_L,RES_L;
    input nmiHandled, irqHandled, resHandled;
    output nmi,irq,res;
    
    wire rstAll,NMI_L,IRQ_L,RES_L;
    wire nmiHandled, irqHandled, resHandled;
    reg nmi,irq,res;
    
    reg intg;
    reg nmiPending, irqPending, resPending;
    
    //take in signals...
    always @ (negedge NMI_L) begin //NMI is captured on negedge.
        nmiPending <= ~NMI_L;
    end
    always @(IRQ_L or RES_L) begin
        irqPending = ~IRQ_L;
        resPending = ~RES_L;
    end
    
    always @ (posedge rstAll) begin
        nmiPending <= 1'b0;
        irqPending <= 1'b0;
        resPending <= 1'b0;
    end
    
    // process and send to FSM
    always @(nmiPending or irqPending or resPending) begin
        
        intg = nmiPending & irqPending; //if nmi and irq both asserted, nmi takes priority.
        nmi = intg | nmiPending;
        irq = ~intg & irqPending;
        res = resPending;
        
    end
    
    always @ (posedge nmiHandled) begin
        if (nmiHandled) nmiPending = 1'b0;
	end
	always @ (posedge irqHandled) begin
        if (irqHandled) irqPending = 1'b0;
	end
	always @ (posedge resHandled) begin
        if (resHandled) resPending = 1'b0;
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
    wire RDYout;
    
    assign RDYout = ~nRW | RDY; //processor is RDY (running) when writing, and when RDY assert.
    
endmodule

/* module randomControl(clock, decoded, interrupt, rdyControl, SV,
                    clock_out, RW, controlSig_t);
                    
    input clock, decoded, interrupt, rdyControl, SV;
    output clock_out, RW;
    output controlSig_t;

endmodule
 */

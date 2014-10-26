`include "peripherals.v"

module lcd_top(USER_CLK,GPIO_SW_C);
    input USER_CLK,GPIO_SW_C;
    
    wire out,clk1;
    wire memClk_b0,memClk_b1,memClk_b2;

    clockone2048 test1(USER_CLK,memClk_b0);
    clockone1024 test2(memClk_b0,memClk_b1);
    clockHalf    test3(memClk_b1,memClk_b2);
    clockHalf    test4(memClk_b2,clk1);
    
    
    
    clockGen test(.HALT(GPIO_SW_C),.phi0_in(clk1),
                .phi1_out(out));
                
    

// clockBuf(.CE0(GPIO_SW_DIP1),.CE1(1'B0),out,clk1,GPIO_SW_DIP1);
    
    
    wire chipClk_b0,chipClk;
    clockone2048 test11(USER_CLK,chipClk_b0);
    clockone256  test12(chipClk_b0,chipClk);

    
    wire [7:0] TRIG0,TRIG1;
    wire[7:0] TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    wire [35 : 0] CONTROL0,CONTROL1;
    
    chipscope_icon icon(
    .CONTROL0(CONTROL0));
               
    
    chipscope_ila ila0(
    .CONTROL(CONTROL0),
    .CLK(chipClk),
    .TRIG0({7'd0,out}),
    .TRIG1({7'd0,~clk1}),
    .TRIG2(8'd0),
    .TRIG3(8'd0),
    .TRIG4(8'd0),
    .TRIG5(8'd0),
    .TRIG6(8'd0),
    .TRIG7(8'd0),
    .TRIG8(8'd0),
    .TRIG9(8'd0),
    .TRIG10(8'd0),
    .TRIG11(8'd0),
    .TRIG12(8'd0),
    .TRIG13(8'd0),
    .TRIG14(8'd0),
    .TRIG15(8'd0));
    
endmodule

module clockGen(HALT,phi0_in,
                RDY,phi1_out,phi2_out,phi1_extout,phi2_extout);
                
    input HALT,phi0_in;
    output RDY;
     (* clock_signal = "yes" *) output phi1_out,phi2_out,phi1_extout,phi2_extout;

    wire phi0_buf;
    reg haltEn;
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
    
    //latch on phi1 ticks
    always @ (negedge phi0_in) begin
        haltEn <= HALT;
    end
    
    BUFG a(phi1_out,~phi0_buf);
    BUFG b(phi2_out,phi0_buf);
    
    BUFG c(phi1_extout,phi1_out);
    BUFG d(phi2_extout,phi2_out);
    
endmodule
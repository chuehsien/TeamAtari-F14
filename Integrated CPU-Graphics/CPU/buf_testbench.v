

module lcd_top(CLK_27MHZ_FPGA,GPIO_SW_C,HDR1_2,HDR1_4,HDR1_6,HDR1_8,GPIO_LED_C);
    input CLK_27MHZ_FPGA,GPIO_SW_C;
    output HDR1_2,HDR1_4,HDR1_6,HDR1_8,GPIO_LED_C;
    
    wire fphi0,phi0,phi1,phi2,locked;
   
    //clockGen179     clockdiv(1'b0,CLK_27MHZ_FPGA,phi0,,);
    
   //clockGen179(.RST(GPIO_SW_C),.clk100(CLK_27MHZ_FPGA),.fphi0(fphi0),.phi0(phi0),.phi1(phi1),.phi2(phi2),.locked(locked));
                     
    assign HDR1_2 = fphi0;
    assign HDR1_4 = phi0;
    assign HDR1_6 = phi1;
    assign HDR1_8 = phi2;
    assign GPIO_LED_C = locked;
    
    
    wire [7:0] TRIG0,TRIG1;
    wire[7:0] TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    wire [35 : 0] CONTROL0,CONTROL1;
    
    chipscope_icon icon(
    .CONTROL0(CONTROL0));
               
    
    chipscope_ila ila0(
    .CONTROL(CONTROL0),
    .CLK(CLK_27MHZ_FPGA),
    .TRIG0({7'd0,fphi0}),
    .TRIG1({7'd0,phi0}),
    .TRIG2({7'd0,phi1}),
    .TRIG3({7'd0,phi2}),
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

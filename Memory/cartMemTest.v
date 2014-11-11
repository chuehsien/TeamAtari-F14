

module cart_top(CLK_27MHZ_FPGA,HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48,
                HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32,
                GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_SW_C,
                GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,
                GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,GPIO_LED_6,GPIO_LED_7,HDR1_34);
                

    input CLK_27MHZ_FPGA,HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_SW_C;
    input GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8;
    output HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32;
    output GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,GPIO_LED_6,GPIO_LED_7;


   
    wire     mainClock;
    clockone4    step(CLK_27MHZ_FPGA,mainClock0);
    clockone1024    step1(mainClock0,mainClock1);
    wire tick,rst;

    
    DeBounce #(.N(14)) rdyA(CLK_27MHZ_FPGA,1'b1,GPIO_SW_C,tick);
    DeBounce #(.N(14)) rdyB(CLK_27MHZ_FPGA,1'b1,GPIO_DIP_SW1,rst);
 
    reg[7:0] addrH = 8'h98;
    
    always @ (posedge mainClock1) begin
       if (rst) addrH <= 0;
       else if (tick) addrH <= addrH+8'h01;
        
    end

    wire [7:0] addrL;
    
    assign addrL = {2'd0,GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8};
    
    assign {HDR1_28,HDR1_26,HDR1_24,HDR1_22,HDR1_20,HDR1_18,HDR1_16,HDR1_14,HDR1_12,HDR1_10,HDR1_8,HDR1_6,HDR1_4,HDR1_2} = {addrH[5:0],addrL};
  
    wire [7:0] data;
    assign data = {HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48};
    //assign {HDR1_28,HDR1_26,HDR1_24,HDR1_22,HDR1_20,HDR1_18,HDR1_16,HDR1_14,HDR1_12,HDR1_10,HDR1_8,HDR1_6,HDR1_4,HDR1_2} = memAdd_b[13:0];
   
    //assign HDR1_30 = ((16'h4000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'h8000)) ? 1'b1 : 1'b0;
    //assign HDR1_32 = ((16'h8000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'hC000)) ? 1'b1 : 1'b0;
   
   
   
    //assign {HDR1_2,HDR1_4} = sel;
    assign HDR1_30 = (GPIO_DIP_SW2 == 1'b0);
    assign HDR1_32 = (GPIO_DIP_SW2 == 1'b1);
    
  
    assign {GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,GPIO_LED_6,GPIO_LED_7} = data;


    
    wire [7:0] TRIG0,TRIG1;
    wire[7:0] TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    wire [35 : 0] CONTROL0,CONTROL1;
    
    chipscope_icon icon(
    .CONTROL0(CONTROL0));
               
    //clockone256 chpclk(mainClock0,chipClk);    

    chipscope_ila ila0(
    .CONTROL(CONTROL0),
    .CLK(mainClock0),
    .TRIG0({7'd0,1'b0}),
    .TRIG1(addrH),
    .TRIG2({addrL}),
    .TRIG3({2'd0,sel}),
    .TRIG4(data),
    .TRIG5({7'd0,mainClock1}),
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
module counter (clk,tick);
    input clk;
    output tick;

    reg [7:0] count=8'd0;
    always @ (posedge clk) begin
        count <= count +1;
    end

    assign tick = (count == 0);


endmodule

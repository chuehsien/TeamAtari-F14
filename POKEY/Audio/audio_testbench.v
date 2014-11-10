`include "peripherals.v"
`include "pokeyaudio.v"
module pokey_top(USER_CLK,GPIO_SW_C,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,
                GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,GPIO_SW_S,
                HDR2_2_SM_8_N,HDR2_4_SM_8_P,GPIO_LED_7,
               HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,
               GPIO_LED_0,GPIO_LED_1);
    input USER_CLK,GPIO_SW_C,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,
            HDR2_2_SM_8_N,HDR2_4_SM_8_P,
                GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,GPIO_SW_S;
    output HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,GPIO_LED_0,GPIO_LED_1,GPIO_LED_7;

    (* clock_signal = "yes" *) wire clk179,clk64,clk16,clk2;
    clockDivider #(28) out179(USER_CLK,clk179);
    clockDivider #(422) out64(FPGA_CLK_27,clk64);
    clockDivider #(4) out16(clk64,clk16);
    clockDivider #(2) out2(USER_CLK,clk2);
 
    wire init_L;
    wire [7:0] AUDF1,AUDF2,AUDF3,AUDF4;
    wire [7:0] AUDC1,AUDC2,AUDC3,AUDC4,AUDCTL;

    assign init_L = ~GPIO_SW_C;
    assign AUDF1 = 8'h213; //to create 300Hz tone
    assign AUDF2 = 8'd32; //to create 2kHz
    assign AUDF3 = 8'd11; // to create 6khz
    assign AUDF4 = 8'd5; //to create 12khz
    
    wire [2:0] distort;
    wire volO;
    wire [3:0] vol;
    assign AUDC1 = {distort,volO,vol};
    assign AUDC2 = {distort,volO,vol};
    assign AUDC3 = {distort,volO,vol};
    assign AUDC4 = {distort,volO,vol};
    
    assign AUDCTL = 8'd0;
    
    assign vol = ~{GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4};
    assign distort = {GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8};
    assign volO = GPIO_DIP_SW5;

    
    wire audio1,audio2,audio3,audio4;
    wire [3:0] vol1,vol2,vol3,vol4;

    pokeyaudio test(init_L,clk179,clk64,clk16,AUDF1,AUDF2,AUDF3,AUDF4,
                    AUDC1,AUDC2,AUDC3,AUDC4,AUDCTL,
                    audio1,audio2,audio3,audio4,vol1,vol2,vol3,vol4);
                    
    reg [1:0] sel = 2'b0;
    wire nextChn;
    DeBounce selDB(clk179, init_L, GPIO_SW_S, nextChn);
    assign {GPIO_LED_0,GPIO_LED_1} = sel;
    
    always @ (posedge nextChn) begin
        sel <= sel + 1;
    end
    //assign HDR2_2_SM_8_N = 1'b0;
    //assign HDR2_4_SM_8_P = 1'b1;
    
    assign GPIO_LED_7 = HDR2_4_SM_8_P;
    assign HDR1_2 = (sel==2'd0) ? audio1 :
                    ((sel==2'd1) ? audio2 :
                    ((sel==2'd2) ? audio3 :
                    ((sel==2'd3) ? audio4 : 1'b0)));
    assign {HDR1_4,HDR1_6,HDR1_8,HDR1_10} = (sel==2'd0) ? vol1 :
                                            ((sel==2'd1) ? vol2 :
                                            ((sel==2'd2) ? vol3 :
                                            ((sel==2'd3) ? vol4 : 1'b0)));
    
//=======================ILA/ICON stuff=======================//
    
    /*
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
    .CLK(USER_CLK),
    .TRIG0({7'd0,USER_CLK}),
    .TRIG1({7'd0,clk2}),
    .TRIG2({7'd0,~clk179}),
    .TRIG3({7'd0,~clk64}),
    .TRIG4({7'd0,~clk16}),
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
    */
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

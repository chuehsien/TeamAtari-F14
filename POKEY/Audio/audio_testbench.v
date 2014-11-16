`include "peripherals.v"
`include "pokeyaudio.v"
module pokey_top(CLK_27MHZ_FPGA,USER_CLK,GPIO_SW_C,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,
                GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,GPIO_SW_S,


               
               HDR1_50,HDR1_52,HDR1_54,HDR1_56,
               
               HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P,
               HDR2_42_SM_14_N, HDR2_44_SM_14_P, HDR2_46_SM_12_N, HDR2_48_SM_12_P,
               HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P,
               HDR2_58_SM_4_N, HDR2_60_SM_4_P, HDR2_62_SM_9_N, HDR2_64_SM_9_P
               
               );
    input CLK_27MHZ_FPGA,USER_CLK,GPIO_SW_C,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,            
                GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,GPIO_SW_S;
                
    output HDR1_50,HDR1_52,HDR1_54,HDR1_56,
               
               HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P,
               HDR2_42_SM_14_N, HDR2_44_SM_14_P, HDR2_46_SM_12_N, HDR2_48_SM_12_P,
               HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P,
               HDR2_58_SM_4_N, HDR2_60_SM_4_P, HDR2_62_SM_9_N, HDR2_64_SM_9_P;


    (* clock_signal = "yes" *) wire clk179,clk64,clk16,clk358,locked;
    clockGen179_single out179(1'b0,CLK_27MHZ_FPGA,clk179,locked);
    clockDivider #(422) out64(CLK_27MHZ_FPGA,clk64);
    clockDivider #(1688) out16(CLK_27MHZ_FPGA,clk16);

 
    wire init_L;
    wire [7:0] AUDF1,AUDF2,AUDF3,AUDF4;
    wire [7:0] AUDC1,AUDC2,AUDC3,AUDC4,AUDCTL;
    wire [3:0] vol1,vol2,vol3,vol4;
    
    
    assign init_L = ~GPIO_SW_C;
    assign AUDF1 = 8'h0; //to create 300Hz tone
    assign AUDF2 = 8'h0; //to create 2kHz
    assign AUDF3 = 8'h0; // to create 250hz
    assign AUDF4 = 8'hfe; //to create 252hz
    

    DeBounce t(clk16,1'b1,GPIO_SW_S,voltick);

    reg [3:0] vol = 4'hf; 
    always @ (posedge voltick) begin
        vol <= vol - 4'd1;
    end
    
    
    assign AUDC1 = {4'h0,vol};
    assign AUDC2 = {4'h0,vol};
    assign AUDC3 = {4'ha,vol};
    assign AUDC4 = {4'ha,vol};
    
    assign AUDCTL = 8'd0;
    
    wire audio1,audio2,audio3,audio4;


    wire mainClock,chn4base8bit;
    
    pokeyaudio test(.mainClock(mainClock),.chn4base8bit(chn4base8bit),.init_L(init_L),
                    .clk179(clk179),.clk64(clk64),.clk16(clk16),.AUDF1(AUDF1),.AUDF2(AUDF2),.AUDF3(AUDF3),.AUDF4(AUDF4),
                    .AUDC1(AUDC1),.AUDC2(AUDC2),.AUDC3(AUDC3),.AUDC4(AUDC4),.AUDCTL(AUDCTL),
                    .audio1(audio1),.audio2(audio2),.audio3(audio3),.audio4(audio4),.vol1(vol1),.vol2(vol2),.vol3(vol3),.vol4(vol4));
                 
    assign HDR1_50 = audio1;
    assign HDR1_52 = audio2;
    assign HDR1_54 = audio3;
    assign HDR1_56 = audio4;
    
    assign {HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P} = vol1;
    assign {HDR2_48_SM_12_P,HDR2_46_SM_12_N,HDR2_44_SM_14_P,HDR2_42_SM_14_N} = vol2;
    assign {HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P} = vol3;
    assign {HDR2_64_SM_9_P,HDR2_62_SM_9_N,HDR2_60_SM_4_P,HDR2_58_SM_4_N} = vol4;
    
//=======================ILA/ICON stuff=======================//
    
    
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
    .CLK(CLK_27MHZ_FPGA),
    .TRIG0({7'd0,1'b0}),
    .TRIG1({7'd0,out1}),
    .TRIG2({7'd0,out2}),
    .TRIG3({4'd0,vol}),
    .TRIG4({7'd0,audio4}),
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

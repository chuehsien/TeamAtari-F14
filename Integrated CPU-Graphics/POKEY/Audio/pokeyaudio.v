module pokeyaudio (mainClock,chn4base8bit,init_L,clk179,clk64,clk16,AUDF1,AUDF2,AUDF3,AUDF4,
                    AUDC1,AUDC2,AUDC3,AUDC4,AUDCTL,
                    audio1,audio2,audio3,audio4,vol1,vol2,vol3,vol4,RANDOM);
    output mainClock,chn4base8bit;
    input init_L, clk179,clk64,clk16;
    input [7:0] AUDF1,AUDF2,AUDF3,AUDF4,
                    AUDC1,AUDC2,AUDC3,AUDC4,AUDCTL;
    output audio1,audio2,audio3,audio4;
    output [3:0] vol1,vol2,vol3,vol4;
    output [7:0] RANDOM;

    wire mainClock;
    assign mainClock = (AUDCTL[0]) ? clk16 : clk64;
    
    //generate poly channels
    wire poly4out,poly5out,poly17_9out;
    poly4bit poly4(.clk(mainClock),.init_L(init_L),.out(poly4out));
    poly5bit poly5(.clk(mainClock),.init_L(init_L),.out(poly5out));
    poly17or9bit poly17_9(.clk(mainClock),.sel9(AUDCTL[7]),.init_L(init_L),.out(poly17_9out),.randNum(RANDOM)); 

    wire [2:0] distort1,distort2,distort3,distort4;
    wire volOnly1,volOnly2,volOnly3,volOnly4;
    wire [3:0] vol1,vol2,vol3,vol4;
    
    assign distort1 = AUDC1[7:5];
    assign distort2 = AUDC2[7:5];
    assign distort3 = AUDC3[7:5];
    assign distort4 = AUDC4[7:5];
    assign volOnly1 = AUDC1[4];
    assign volOnly2 = AUDC2[4];
    assign volOnly3 = AUDC3[4];
    assign volOnly4 = AUDC4[4];
    assign vol1     = (AUDF1 == 8'd0) ? 4'b1111 : ~AUDC1[3:0];
    assign vol2     = (AUDF2 == 8'd0) ? 4'b1111 : ~AUDC2[3:0];
    assign vol3     = (AUDF3 == 8'd0) ? 4'b1111 : ~AUDC3[3:0];
    assign vol4     = (AUDF4 == 8'd0) ? 4'b1111 : ~AUDC4[3:0];
    
    //move all channels to correct frequency first!
    wire chn1baseA,chn1baseB,chn1base,chn2base,chn3base,chn4base;
    
    
    //wire chn1baseT;
    //clockDivider #(213) out213(mainClock,chn1baseT);
    
    wire chn1base_unfiltered,chn1base_filtered;
    divideByN chn1divideA(AUDF1,mainClock,chn1baseA);
    divideByN chn1divideB(AUDF1,clk179,chn1baseB);
    assign chn1base_unfiltered = AUDCTL[4] ? 1'b0 : (AUDCTL[6] ? chn1baseB:chn1baseA);
    highpass    chn1passfilter(chn1base_unfiltered,chn3base,chn1base_filtered);
    assign chn1base = AUDCTL[2] ? chn1base_filtered : chn1base_unfiltered;
    
    wire chn2base8bit,chn2base16bit,chn2base_unfiltered,chn2base_filtered;
    divideByN chn2divide8bit(AUDF2,mainClock,chn2base8bit);
    divideByN16bit chn2divide16bit({AUDF2,AUDF1},mainClock,chn2base16bit);
    assign chn2base_unfiltered = AUDCTL[4] ? chn2base16bit : chn2base8bit;
    highpass    chn2passfilter(chn2base_unfiltered,chn4base,chn2base_filtered);
    assign chn2base = AUDCTL[1] ? chn2base_filtered : chn2base_unfiltered;
    
    wire chn3baseA,chn3baseB;
    divideByN chn3divideA(AUDF3,mainClock,chn3baseA);
    divideByN chn3divideB(AUDF3,clk179,chn3baseB);
    assign chn3base = AUDCTL[3] ? 1'b0 : (AUDCTL[5] ? chn3baseB:chn3baseA);   
    
    wire chn4base8bit,chn4base16bit;
    divideByN chn4divide8bit(AUDF4,mainClock,chn4base8bit);
    divideByN16bit chn4divide16bit({AUDF4,AUDF3},mainClock,chn4base16bit);
    assign chn4base = AUDCTL[3] ? chn4base16bit : chn4base8bit;
    
    
    wire chn1out,chn2out,chn3out,chn4out; //output before inter-channel mixing
    
    distortChn chn1d(.chnIn(chn1base),.poly4(poly4out),.poly5(poly5out),.poly17_9(poly17_9out),
                     .distort(distort1),.chnOut_distort(chn1out));
  
    distortChn chn2d(.chnIn(chn2base),.poly4(poly4out),.poly5(poly5out),.poly17_9(poly17_9out),
                     .distort(distort2),.chnOut_distort(chn2out));
                     
    distortChn chn3d(.chnIn(chn3base),.poly4(poly4out),.poly5(poly5out),.poly17_9(poly17_9out),
                     .distort(distort3),.chnOut_distort(chn3out));
                     
    distortChn chn4d(.chnIn(chn4base),.poly4(poly4out),.poly5(poly5out),.poly17_9(poly17_9out),
                     .distort(distort4),.chnOut_distort(chn4out));                 
   //need to add vol only mode
   assign audio1 = ~(volOnly1 | chn1out);
   assign audio2 = ~(volOnly2 | chn2out);
   assign audio3 = ~(volOnly3 | chn3out);
   assign audio4 = ~(volOnly4 | chn4out);
    
endmodule

  //all channels divided by freq before entering distortion
module distortChn(chnIn,poly4,poly5,poly17_9,distort,chnOut_distort);
    input chnIn,poly4,poly5,poly17_9;
    input [2:0] distort;
    output chnOut_distort;
    

    wire chn_sel5_17_div2,chn_sel5_div2,chn_sel5_4_div2,chn_sel17_div2,chn_div2,chn_sel4_div2;
    
    wire out1a,out1b;
    distortion case1(.in(chnIn),.filter(poly5),.out(out1a));
    distortion case1a(.in(out1a),.filter(poly17_9),.out(out1b));
    clockHalf case1b(.inClk(out1b),.outClk(chn_sel5_17_div2));
    
    wire out2a;
    distortion case2(.in(chnIn),.filter(poly5),.out(out2a));
    clockHalf case2a(.inClk(out2a),.outClk(chn_sel5_div2));
    
    wire out3a,out3b;
    distortion case3(.in(chnIn),.filter(poly5),.out(out3a));
    distortion case3a(.in(out3a),.filter(poly4),.out(out3b));
    clockHalf case3b(.inClk(out3b),.outClk(chn_sel5_4_div2));
    
    
    distortion case4(.in(chnIn),.filter(poly17_9),.out(out4a));
    clockHalf case4a(.inClk(out4a),.outClk(chn_sel17_div2));   
    
    clockHalf case5(.inClk(chnIn),.outClk(chn_div2));  

    distortion case6(.in(chnIn),.filter(poly4),.out(out6a));
    clockHalf case6a(.inClk(out6a),.outClk(chn_sel4_div2));       
    
    assign chnOut_distort = (~distort[2]&~distort[1]&~distort[0]) ? chn_sel5_17_div2:
                     ((~distort[2]&distort[0]) ? chn_sel5_div2:
                     ((~distort[2]&distort[1]&~distort[0]) ? chn_sel5_4_div2:
                     ((distort[2]&~distort[1]&~distort[0]) ? chn_sel17_div2:
                     ((distort[2]&distort[0]) ? chn_div2:
                     ((distort[2]&distort[1]&~distort[0]) ? chn_sel4_div2:
                     chnIn)))));

endmodule

module distortion(in,filter,out);
    input in,filter;
    output out;
    
    assign out = in&filter;

endmodule


//does this work for N = 0?
//up to max of divide by 65536.
module divideByN(N,in,out);

    input [7:0] N;
    input in;
    (* clock_signal = "yes" *)output out;
    
    reg [8:0] counter = 0;

    always @ (posedge in) begin
        counter <= counter + 1;
        if (counter == N>>1) counter <= 0;
    end
    
    wire en;
    assign en = (counter == 0);

    reg outClk = 1'b0;
    
    always @ (negedge in) begin
            if (en) outClk <= ~outClk;
            else outClk <= outClk;
    end

    BUFG c(out,outClk);
    
    
    
    
    
/*
    reg [8:0] counter = 0;
    
    wire allow,allow_b;
    wire outDiv;
    BUFGCTRL #(
       .INIT_OUT(0),           // Initial value of BUFGCTRL output ($VALUES;)
       .PRESELECT_I0("TRUE"), // BUFGCTRL output uses I0 input ($VALUES;)
       .PRESELECT_I1("FALSE")  // BUFGCTRL output uses I1 input ($VALUES;)
    )
    BUFGCTRL_inst (
       .O(outDiv),             // 1-bit output: Clock output
       .CE0(1'b1),         // 1-bit input: Clock enable input for I0
       .CE1(1'b0),         // 1-bit input: Clock enable input for I1
       .I0(in),           // 1-bit input: Primary clock
       .I1(1'b0),           // 1-bit input: Secondary clock
       .IGNORE0(1'b1), // 1-bit input: Clock ignore input for I0
       .IGNORE1(1'b1), // 1-bit input: Clock ignore input for I1
       .S0(allow),           // 1-bit input: Clock select for I0
       .S1(~allow)            // 1-bit input: Clock select for I1
    );
   assign out = (N==0) ? in : outDiv;
    //BUFGCE clockBuf(.O(out),.I(in),.CE(allow_b));
    assign allow = (counter == 0) & (in);
   
    always @ (posedge in) begin
        if (counter == N-1) counter <= 0;
        else counter <= counter + 1;
    end
    */
    
    
    
  
endmodule

module divideByN16bit(N,in,out);

    input [15:0] N;
    input in;
    (* clock_signal = "yes" *)output out;
    
    reg [16:0] counter = 0;

    always @ (posedge in) begin
        counter <= counter + 1;
        if (counter == N>>1) counter <= 0;
    end
    
    wire en;
    assign en = (counter == 0);

    reg outClk = 1'b0;
    
    always @ (negedge in) begin
            if (en) outClk <= ~outClk;
            else outClk <= outClk;
    end

    BUFG c(out,outClk);
    
    
    /*
    reg [16:0] counter = 0;
    
    wire allow,allow_b;
    wire outDiv;
    BUFGCTRL #(
       .INIT_OUT(0),           // Initial value of BUFGCTRL output ($VALUES;)
       .PRESELECT_I0("TRUE"), // BUFGCTRL output uses I0 input ($VALUES;)
       .PRESELECT_I1("FALSE")  // BUFGCTRL output uses I1 input ($VALUES;)
    )
    BUFGCTRL_inst (
       .O(outDiv),             // 1-bit output: Clock output
       .CE0(1'b1),         // 1-bit input: Clock enable input for I0
       .CE1(1'b0),         // 1-bit input: Clock enable input for I1
       .I0(in),           // 1-bit input: Primary clock
       .I1(1'b0),           // 1-bit input: Secondary clock
       .IGNORE0(1'b1), // 1-bit input: Clock ignore input for I0
       .IGNORE1(1'b1), // 1-bit input: Clock ignore input for I1
       .S0(allow),           // 1-bit input: Clock select for I0
       .S1(~allow)            // 1-bit input: Clock select for I1
    );
    assign out = (N==0) ? in : outDiv;
    //BUFGCE clockBuf(.O(out),.I(in),.CE(allow_b));
    assign allow = (counter == 0) & (in);
   
    always @ (posedge in) begin
        if (counter == N-1) counter <= 0;
        else counter <= counter + 1;
    end
    */
endmodule

module highpass(orig,filter,out);
    input orig,filter;
    output out;
    
    //coded following atari hardware manual's crude high pass filter
    reg fReg = 1'b0;
    
    always @ (posedge filter) begin
        fReg <= orig;
    end
    
    xor b(out,fReg,orig);
    

endmodule


module poly4bit(clk,init_L,out);
    input clk, init_L;
    output out;
    
    wire reset;
    FDCPE inst3(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(in),.Q(three_two));
    FDCPE inst2(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(three_two),.Q(two_one));
    FDCPE inst1(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(two_one),.Q(one_zero));
    FDCPE inst0(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(one_zero),.Q(out));
    
    assign reset = three_two & two_one & one_zero & out;
    assign in = ~(one_zero ^ out); 
    
endmodule

module poly5bit(clk,init_L,out);
    input clk, init_L;
    output out;
    wire reset;
    FDCPE inst4(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(in),.Q(four_three));
    FDCPE inst3(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(four_three),.Q(three_two));
    FDCPE inst2(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(three_two),.Q(two_one));
    FDCPE inst1(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(two_one),.Q(one_zero));
    FDCPE inst0(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(one_zero),.Q(nOut));
    
    assign reset = four_three & three_two & two_one & one_zero & nOut;
    assign out = nOut;
    assign in = ~(three_two ^ out); 
    
endmodule

module poly17or9bit(clk,sel9,init_L,out,randNum);
    input clk,sel9,init_L;
    output out;
    output [7:0] randNum;
    
    //first 8
    wire reset1;
    FDCPE inst7(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(first8_in),.Q(seven_six));
    FDCPE inst6(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(seven_six),.Q(six_five));
    FDCPE inst5(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(six_five),.Q(five_four));
    FDCPE inst4(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(five_four),.Q(four_three));
    FDCPE inst3(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(four_three),.Q(three_two));
    FDCPE inst2(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(three_two),.Q(two_one));
    FDCPE inst1(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(two_one),.Q(one_zero));
    FDCPE inst0(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(one_zero),.Q(first8_out));
    assign reset = seven_six & six_five & five_four & four_three & three_two & two_one & one_zero & first8_out;

    
    assign random = ~(~first8_out ^ ~five_four);
    assign randNum = {seven_six,six_five,five_four,four_three,three_two,two_one,one_zero,first8_out};
    //last 8
    wire reset2;
    FDCPE inst16(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(last8_in),.Q(Lseven_six));
    FDCPE inst15(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lseven_six),.Q(Lsix_five));
    FDCPE inst14(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lsix_five),.Q(Lfive_four));
    FDCPE inst13(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lfive_four),.Q(Lfour_three));
    FDCPE inst12(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lfour_three),.Q(Lthree_two));
    FDCPE inst11(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lthree_two),.Q(Ltwo_one));
    FDCPE inst10(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Ltwo_one),.Q(Lone_zero));
    FDCPE inst9(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(Lone_zero),.Q(last8_out));
    assign reset2 = Lseven_six & Lsix_five & Lfive_four & Lfour_three & Lthree_two & Ltwo_one & Lone_zero & last8_out;
    assign last8_in = random;
    
    
    wire nor1,nor2,nor3;
    FDCPE inst8(.PRE(1'b0),.CLR(~init_L),.C(clk),.CE(1'b1),.D(sel9),.Q(reg8out));
    
    assign nor1 = ~(last8_out | sel9);
    
    assign nor2 = ~(reg8out | ~sel9);
    
    assign nor3 = ~(~sel9 | random);
    
    assign first8_in = ~(~init_L|nor1|nor2|nor3);
    assign out = first8_out; //this will be output for both 9 and 17 mode.
    
endmodule





















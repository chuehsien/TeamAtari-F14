module clockGen179(RST,clk27,phi0_lag,fphi0,phi0,locked);
    input RST,clk27;
    (* clock_signal = "yes" *)output phi0_lag,fphi0,phi0;
    output locked;

    wire clk27_b,clk576,clk576_b;
   // BUFG b(clk27_b,clk27);
   // BUFG b1(clk576,clk576_b);
    //clock100_to_2864 try0(.RST(RST),.clock100(clk100_b),.clock2864(clk2864),.locked(locked));
    
   //produces 57.6MHz
    clockDiv try0(.CLKIN1_IN(clk27), .RST_IN(RST), .CLK0_OUT(clk576),.LOCKED_OUT(locked));

                
    wire A,B;
    
    //produces 7.2Mhz clock.
    hackishClock try1(.RST(RST),.clkin(clk576),.clkout_A(A),.clkout_B(B));
    
    //B IS THE LAGGING ONE. SO B = PHI0_lag
    wire phi0_lag_b;
    clockHalf final1(B,phi0_lag_b);
    BUFG test0(phi0_lag,phi0_lag_b);
    
    //A IS THE NON LAGGING ONE
    wire phi0_b;
    
    BUFG fastphi(fphi0,A);
    
    clockHalf final2(A,phi0_b);
    BUFG test1(phi0,phi0_b);
 
endmodule


module hackishClock(RST,clkin,clkout_A,clkout_B);
    input RST,clkin;
    output clkout_A,clkout_B; //each with 1/28.64Mhz delay (~37ns)
    
    //produced clock is divided by 8.
    
    reg clkout_A,clkout_B = 1'b0;
    //reg clkout_B = 1'b0;
    
    reg [18:0] counter=0; 
    always @ (posedge clkin) begin
        if (RST) counter <= 0;
        else counter <= counter + 1;
    end    
    
    wire A,B;
    assign A = (counter == 2);
    assign B = (counter == 4);
 
    
    always @ (posedge A) begin
        if (RST) clkout_A <= 1'b0;
        else clkout_A <= ~clkout_A;
    end

    always @ (posedge B) begin
        if (RST) clkout_B <= 1'b0;
        else clkout_B <= ~clkout_B;
    end
    
endmodule

module clockGen50(CLK100,out);
    input CLK100;
    output out;
endmodule



module clockHalf(inClk,outClk);
    input inClk;
    output reg outClk = 1'b0;
    
    always @ (posedge inClk) begin
        outClk <= ~outClk;
    end
    
endmodule

module clockone4(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [1:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[1];
    
endmodule

module clockone8(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [2:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[2];
    
endmodule

module clockone16(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [3:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[3];
    
endmodule



module clockone256(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [7:0] count;
    
    always @ (posedge inClk) begin
            count <= count + 1;
    end
    
    assign outClk = count[7];
endmodule

module clockone1024(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [9:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[9];
endmodule

module clockone2048(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [10:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[10];
endmodule


module clockDivider(inClk,outClk);
    parameter DIVIDE = 500;
    
function integer log2;
    input [31:0] value;
    for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction
    
    parameter width = log2(DIVIDE);
        
    input inClk;
    output outClk;

    
    reg [width:0] counter = 0;
    always @ (posedge inClk) begin
        counter <= counter + 1;
        if (counter == DIVIDE>>1) counter <= 0;
    end
    

    wire en;
    assign en = (counter == 0);

    reg outClk = 1'b0;
    
    always @ (posedge inClk) begin
            if (en) outClk <= ~outClk;
            else outClk <= outClk;
    end

    
endmodule

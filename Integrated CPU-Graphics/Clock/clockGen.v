module clockGen179(RST,clk27,phi0,fphi0,latchClk,locked);
    parameter div = 4;
    input RST,clk27;
    (* clock_signal = "yes" *)output phi0,fphi0,latchClk;
    output locked;

    wire clk576_phi0,clk1052_fphi0;
    wire clk576_phi0_b,clk1052_fphi0_b,latchClk_b;


   //produces 57.6MHz
    clockDiv try0(.CLKIN1_IN(clk27), .RST_IN(RST), .CLK0_OUT(clk576_phi0),.CLK2X_OUT(clk1052_fphi0),.LOCKED_OUT(locked));

    clockoneX #(.width(div+1)) phi0make(clk576_phi0,clk576_phi0_b);
    clockoneX #(.width(div+1)) fphi0make(clk1052_fphi0,clk1052_fphi0_b); 
    hackishClock downto1_8Mhz(RST,clk576_phi0,latchClk_b);
 
    BUFG phi0out(phi0,clk576_phi0_b);
    BUFG fphi0out(fphi0,clk1052_fphi0_b);
	 BUFG latchclkout(latchClk,latchClk_b);

 
endmodule


module hackishClock(RST,clkin,latchClk);
    input RST,clkin;
    output latchClk;

    reg latchClk = 1'b0;
	 
    reg [3:0] counter = 4'd0;
    always @ (negedge clkin) begin
      if (RST) counter <= 4'd0;
      else begin  
        counter <= counter + 4'd1;
      end
    end
    
    
    
    always @ (posedge clkin) begin
		if (RST) begin
			latchClk <= 1'b0;
		
		end
	 
	 
		 else begin
		 
			if (counter == 3) latchClk <= 1'b0;
			if (counter == 12) latchClk <= 1'b1;

			
		 end
    end
endmodule

/*
module clockHalf(inClk,outClk);
    input inClk;
    output reg outClk = 1'b0;
    
    always @ (posedge inClk) begin
        outClk <= ~outClk;
    end
    
endmodule
*/

module clockHalf(inClk,outClk);
    input inClk;
    output outClk;
    
    reg count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count;
    
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


module clockone32(inClk,outClk);
    input inClk;
    output outClk;
    
    reg [4:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[4];
    
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

module clockoneX(inClk,outClk);
  
    input inClk;
    output outClk;
    
    
    parameter width = 50;

    reg [width-1:0] count;
    
    always @ (posedge inClk) begin
        count <= count + 1;
    end
    
    assign outClk = count[width-1];
endmodule


/*
module clockDividerN(N,inClk,out);
    input [80:0] N;
    input inClk;
    output out;

    
    reg [80:0] counterA,counterB = 0;
    wire en;
    wire [80:0] sum;
    
    assign en = (sum == N);
    
    reg rstNow = 1'b0;
    always @ (posedge inClk) begin
        if (en) rstNow <= 1;
        else rstNow <= 0;
    end
    
    always @ (posedge inClk) begin
        if (rstNow) counterA <= 0;
        else counterA <= counterA + 1;
    end
    
    always @ (negedge inClk) begin
        if (rstNow) counterB <= 0;
        else counterB <= counterB + 1;
    end
    

    
    
    assign sum = counterA + counterB;

    
    reg outClk = 1'b0;
    always @ (posedge en) begin
        outClk <= ~outClk;
    end


    BUFG c(out,outClk);
endmodule
*/





module clockDivider(inClk,out);
    parameter DIVIDE = 500;
    
function integer log2;
    input [80:0] value;
    for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction
    
    parameter width = log2(DIVIDE);
        
    input inClk;
    output out;

    
    reg [width:0] counter = 0;

    always @ (posedge inClk) begin
        counter <= counter + 1;
        if (counter == DIVIDE>>1) counter <= 0;
    end
    

    wire en;
    assign en = (counter == 0);

    reg outClk = 1'b0;
    
    always @ (negedge inClk) begin
            if (en) outClk <= (outClk) ? 1'b0 : 1'b1;
            else outClk <= outClk;
    end

    BUFG c(out,outClk);
endmodule


/****************************************************
 * Project: Atari 5200                              *
 *                                                  *
 * Peripherals 			                            *
 *                                                  *
 * Team Atari                                       *
 *    Alvin Goh     (chuehsig)                      *
 *    Benjamin Hong (bhong)                         *
 *    Jonathan Ong  (jonathao)                      *
 ****************************************************/
 
/* Changelog:
	15 Sep 2014,  0033hrs: added memory module (chue)
  29 Sep 2014,  1948hrs: modified memory module to become linear (ben)
  30 Sep 2014,  1927hrs: amended memory module to be writable (ben)
*/

module triState(out,in,en);
    inout out;
    input in;
    input en;
    
    assign out = (en) ? in : 1'bz;
    
endmodule
module debounce(clk, button_i,
                button_debounced_o);
    parameter PRESSLENGTH = 50; // minimum number of cycles to count
                
    input clk, button_i;
    output button_debounced_o;
    
    reg button_debounced_o = 1'b0;
    reg [15:0] count = 16'd0;

    always @(posedge clk) begin
        if (count == PRESSLENGTH) begin
            //stablized
            if (button_i) begin
                button_debounced_o <= 1'b1;
            end
            else button_debounced_o <= 1'b0;
            count <= 16'd0;
        end
        else if (count > 0) begin
            count <= count + 1;
        end
        
        else if (count == 0) begin
            if (button_i) count <= count + 1;
            
        end
    end

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
    reg outClk = 1'b0;

    always @ (posedge inClk or negedge inClk) begin
        
        if (counter == DIVIDE - 1) begin
            outClk <= ~outClk;
            counter <= 0;
        end
        else begin
            outClk <= outClk;
            counter <= counter + 1;
        end

    end

    
endmodule


// Assert 'en' to connect the left and right data buses
module transBuf(en, leftDriver, rightDriver, left, right);

    input en;
    input [2:0] leftDriver,rightDriver;
    inout [7:0] left, right;
    
    

    
    wire enLeft, enRight;
    assign enLeft = (leftDriver > rightDriver);
    assign enRight = (rightDriver > leftDriver);
    
    
    
    bufif1 LtoR[7:0](right, left, (en & enLeft));
    bufif1 RtoL[7:0](left, right, (en & enRight));
    //bufif1 LtoR[7:0](right, left, en);
endmodule



// 6502 can address up to 65K memory. (16 bits)
module memory256x256 (clock, enable, we_L, re_L,address,
				data);
				
	input clock, enable, we_L, re_L;
	input [15:0] address;
	inout [7:0] data;

	wire clock, enable, we_L, re_L;
	wire [15:0] address;
	
	// [7:0] addL, addH;
	//assign {addH,addL} = address;
    reg [7:0] data_reg;
	
	reg [7:0] mem [0:65535]; //65kb of linear memory declared
  
    //Initializing memory
    initial begin
     $readmemh("memory.list", mem);
    end

    //reading from memory is ASYNC
    //writing to memory is SYNC
	assign data = (enable & ~re_L) ? mem[address] : 8'bzzzzzzzz;
    
	always @(posedge clock) begin
    
		if (enable && ~we_L) begin
      // $display("we're storing data at %h", address);
			mem[address] = data;
        end
    /*
    else if (~re_L) begin
      // $display("we're reading data at %h", address);
      data_reg <= mem[address]; //not sure if this screws up the timing for memory being accessible not.
    end
    else begin
      $display("re_L is high, we_L is high");
      data_reg <= 8'bxxxxxxxx;
    end
    */
	end

endmodule

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

module debounce(
    input clk,
    input button_i,
    output button_debounced_o
    );

    parameter MIN_DELAY = 50; // minimum number of cycles to count
    parameter W_COUNTER = 20;
    reg [W_COUNTER:0] counter; // one bit wider than min_delay

    assign button_debounced_o = counter[W_COUNTER];

    always @(posedge clk) begin
        if (!button_i) begin
        // if button sensor is showing 'off' state, reset the counter
            counter <= 0;
        end 
        else if (!counter[W_COUNTER]) begin
            counter <= counter + 1'b1;
        end
    end

endmodule





module clockDivider(inClk,outClk);
    parameter DIVIDE = 3;
    
function integer log2;
    input [31:0] value;
    for (log2=0; value>0; log2=log2+1)
    value = value>>1;
endfunction

    parameter width = log2(DIVIDE);
        
    input inClk;
    output outClk;

    
    reg [width-1:0] counter = 0;
    reg outClk = 1'b0;

    always @ (posedge inClk) begin
        
        if (counter == DIVIDE) begin
            outClk <= ~outClk;
            counter <= 0;
        end
        else begin
            outClk <= outClk;
            counter <= counter + 1;
        end

    end

    
endmodule


module passBuffer(in,en,out);
    input [7:0] in;
    input en;
    output [7:0] out;
    
    wire [7:0] in;
    wire en;
	 wire [7:0] out;

    bufif1 buffer[7:0](out,en,in);
    //assign out = (en) ? in : 8'hzz;
    
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
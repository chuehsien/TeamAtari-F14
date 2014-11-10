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
    (* clock_signal = "yes" *)output out;

    
    reg [width:0] counter = 0;
    reg outClk = 1'b0;
    always @ (posedge inClk) begin
        counter <= counter + 1;
        if (counter == DIVIDE>>1) counter <= 0;
    end
    

    wire en;
    assign en = (counter == 0);

    reg outClk = 1'b0;
    
    always @ (negedge inClk) begin
            if (en) outClk <= ~outClk;
            else outClk <= outClk;
    end

    BUFG c(out, outClk);
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





// DeBounce_v.v


//////////////////////// Button Debounceer ///////////////////////////////////////
//***********************************************************************
// FileName: DeBounce_v.v
// FPGA: MachXO2 7000HE
// IDE: Diamond 2.0.1 
//
// HDL IS PROVIDED "AS IS." DIGI-KEY EXPRESSLY DISCLAIMS ANY
// WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
// BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
// DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
// PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
// BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
// ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
// DIGI-KEY ALSO DISCLAIMS ANY LIABILITY FOR PATENT OR COPYRIGHT
// INFRINGEMENT.
//
// Version History
// Version 1.0 04/11/2013 Tony Storey
// Initial Public Release
// Small Footprint Button Debouncer

module  DeBounce 
	(
	input 			clk, n_reset, button_in,				// inputs
	output reg 	DB_out													// output
	);
//// ---------------- internal constants --------------
	parameter N = 11 ;		// (2^ (21-1) )/ 38 MHz = 32 ms debounce time
////---------------- internal variables ---------------
	reg  [N-1 : 0]	q_reg;							// timing regs
	reg  [N-1 : 0]	q_next;
	reg DFF1, DFF2;									// input flip-flops
	wire q_add;											// control flags
	wire q_reset;
//// ------------------------------------------------------

////contenious assignment for counter control
	assign q_reset = (DFF1  ^ DFF2);		// xor input flip flops to look for level chage to reset counter
	assign  q_add = ~(q_reg[N-1]);			// add to counter when q_reg msb is equal to 0
	
//// combo counter to manage q_next	
	always @ ( q_reset, q_add, q_reg)
		begin
			case( {q_reset , q_add})
				2'b00 :
						q_next <= q_reg;
				2'b01 :
						q_next <= q_reg + 1;
				default :
						q_next <= { N {1'b0} };
			endcase 	
		end
	
//// Flip flop inputs and q_reg update
	always @ ( posedge clk )
		begin
			if(n_reset ==  1'b0)
				begin
					DFF1 <= 1'b0;
					DFF2 <= 1'b0;
					q_reg <= { N {1'b0} };
				end
			else
				begin
					DFF1 <= button_in;
					DFF2 <= DFF1;
					q_reg <= q_next;
				end
		end
	
//// counter control
	always @ ( posedge clk )
		begin
			if(q_reg[N-1] == 1'b1)
					DB_out <= DFF2;
			else
					DB_out <= DB_out;
		end

endmodule






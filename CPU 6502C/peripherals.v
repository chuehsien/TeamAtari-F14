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
*/


// 6502 can address up to 65K memory. (16 bits)
module memory256x256 (clock, enable, we_L, re_L,address,
				data)
				
	input clock, enable, we_L, re_L;
	input [15:0] address;
	inout [7:0] data;

	wire clock, enable, we_L, re_L;
	wire [15:0] address;
	
	wire [7:0] addL, addH;
	assign {addH,addL} = address;
	
	reg [7:0] mem [16'hffff][16'hffff];
	
	memory256 memRows[255:0](.clock(clock), .enable(enable), .we_L(we_L), .re_L(re_L),
						.address(addL), .data(dataCol);
						
	assign data = (enable & ~re_L) ? mem[addH][addL] : 8'bzzzzzzzz;
	always @(posedge clock) begin
		if (enable & ~we_L)
			mem[addH][addL] <= data;
	end

endmodule
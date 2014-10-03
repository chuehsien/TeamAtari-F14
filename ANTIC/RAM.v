/****************************************************
 * Project: Atari 5200                              *
 *                                                  *
 * Peripherals 			                                *
 *                                                  *
 * Team Atari                                       *
 *    Alvin Goh     (chuehsig)                      *
 *    Benjamin Hong (bhong)                         *
 *    Jonathan Ong  (jonathao)                      *
 ****************************************************/
 
/* Changelog:
	15 Sep 2014,  0033hrs: added memory module (chue)
  26 Sep 2014,  0115hrs: lifted module for temporary RAM for ANTIC (jong)
  01 Oct 2014,  1145hrs: lifted updated module, added memory list for display list (jong)
*/

// Temporary 65K memory to simulate RAM for ANTIC. (16 bits)
module memory256x256(clock, enable, we_L, re_L, address, data);
				
	input clock, enable, we_L, re_L;
	input [15:0] address;
	inout [7:0] data;

	wire clock, enable, we_L, re_L;
	wire [15:0] address;
	
  reg [7:0] data_reg;
	reg [7:0] mem [0:65535];
  
  // Initialize memory from .list file
  initial begin
    $readmemh("memory.list", mem);
  end
            
	assign data = (enable & ~re_L) ? data_reg : 8'bzzzzzzzz;
	always @(posedge clock) begin
		if (enable & ~we_L) begin
			mem[address] <= data;
      $display("RAM: Storing data %h at address %h", data, address);
    end
    else if (~re_L) begin
      data_reg <= mem[address]; //not sure if this screws up the timing for memory being accessible not.
      $display("RAM: Reading data %h at address %h", mem[address], address);
    end
    else begin
      $display("RAM: Neither read nor write is asserted on this cycle.");
      data_reg <= 8'bxxxxxxxx;
    end
	end

endmodule

/*  Place Display List in RAM:
    
    70  Blank 8 lines
    70  Blank 8 lines
    70  Blank 8 lines
    42  display ANTIC mode 2 (BASIC mode0)
    20  Also, screen memory starts at7C20
    7C
    02  Display Antic Mode 2
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    02
    41  Jump and watt for vertical
    E0  blank to display list which
    7B  starts at $7BEO  
 */
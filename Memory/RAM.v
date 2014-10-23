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
module memory256x256(clock, we, address, dataIn, dataOut);
				
	input clock, we;
	input [15:0] address;
	input [7:0] dataIn;
  output [7:0] dataOut;
	
  reg [7:0] data_reg;
	reg [7:0] mem [0:65535];
  
  // Initialize memory from .list file
  initial begin
    $readmemh("memory.list", mem);
  end
  
  assign dataOut = mem[address];
            
	always @(posedge clock) begin
		if (we) begin
			mem[address] <= dataIn;
      $display("RAM: Storing data %h at address %h", dataIn, address);
    end
    else begin
      $display("RAM: Reading data %h at address %h", mem[address], address);
    end
	end

endmodule

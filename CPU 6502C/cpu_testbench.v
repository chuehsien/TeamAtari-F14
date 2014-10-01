/*  Test module for top level CPU 6502C 
 *  Created:        1 Oct 2014, 1058 hrs (bhong)
 *  Last Modified:  1 Oct 2014, 1236 hrs

 Designed to test module "top_6502C", located in "6502C_top.v"

*/

module testCPU;
  
  reg RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
  reg [7:0] DBin;
  
  wire phi1_out, SYNC, phi2_out, RW;
  wire [15:0] AB; //Address Bus Low and High
  
  wire [7:0] DB; //Data Bus
  
  //Setting up the clock to run
  always begin
    #10 phi0_in = ~phi0_in;
  end
  
  top_6502C top_6502C_module(.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), .DB(DB), .phi1_out(phi1_out), .SYNC(SYNC), .AB(AB), .phi2_out(phi2_out), .RW(RW));
  
  /* High level description:  
   *  We want to generate an opcode on the databus, provide it to the CPU, and have it return a certain checkable value (e.g. control signals and Tstates (which we will have to hook out)). 
   Other components we want to observe: 
    - Address Bus (AB) high and low
    - Side Bus (SB) and Data Bus (DB)
    - X and Y registers
    - A and B registers
    - Accumulator registers
    - Status Register
    - Adder Hold Register
    - Decimal Adjust
    - ..and others?
  */













endmodule

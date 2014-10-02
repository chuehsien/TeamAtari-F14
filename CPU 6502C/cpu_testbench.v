/*  Test module for top level CPU 6502C 
 *  Created:        1 Oct 2014, 1058 hrs (bhong)
 *  Last Modified:  1 Oct 2014, 1236 hrs

 Designed to test module "top_6502C", located in "6502C_top.v"

*/

module testCPU;

  parameter NUM_VECTORS=30;
  
  reg RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
  reg [7:0] DBin;
  
  wire phi1_out, SYNC, phi2_out, RW;
  wire [15:0] AB; //Address Bus Low and High
  
  wire [7:0] DB; //Data Bus
  
  integer i, j;
  
  reg [3:0] numCycles;
  reg [11:0] vectors [NUM_VECTORS-1:0];
  reg [11:0] vec; 
  
  //Setting up the clock to run
  always begin
    #10 phi0_in = ~phi0_in;
  end
  
  top_6502C top_6502C_module(.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), .DB(DB), .phi1_out(phi1_out), .SYNC(SYNC), .AB(AB), .phi2_out(phi2_out), .RW(RW));
  
  /* High level description:  
   *  We want to generate an opcode on the databus, provide it to the CPU, and have it return a certain checkable value (e.g. control signals and Tstates (which we will have to hook out)), after a certain number of clock cycles have passed.
   Other components we want to observe: 
    - Address Bus (AB) high and low
    - Side Bus (SB) and Data Bus (DB)
    - X and Y registers
    - A and B registers
    - Accumulator registers
    - Status Register
    - Adder Hold Register
    - Decimal Adjust
    - ..and others? That's it for now.
  */

  task run_vector;
    input [7:0] A;
    input [3:0] B;
    begin
      DBin = A;
      numCycles = B;
      
      //Clock the system however many cycles this opcode needs
      for (j= 4'd0; j < numCycles; j=j+1) begin
        @(posedge phi0_in);
      end
      
      //Check that the output is correct
      //ALTERNATIVE: check that certain outputs correspond to expected values
      $display("======================");
      
      $display("\tDBin: \t%h", DBin);
      
      $display("======================");
    
    end
    






  initial begin
  
  $readmemh("fsm_test_vectors.vm", vectors);
  for (i=0; i<NUM_VECTORS; i=i+1) begin
    vec = vectors[i];
    run_vector(vec[11:4], vec[3:0]);
    //run_vector(opcodeIn, numCycles);
  end
  
  $finish;
  
  end





endmodule

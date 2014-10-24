/*  Test module for top level CPU 6502C 
 *  Created:        1 Oct 2014, 1058 hrs (bhong)
 *  Last Modified:  3 Oct 2014, 1414 hrs

 Designed to test module "top_6502C", located in "6502C_top.v"

*/

module testCPU;

  parameter NUM_TESTS=30;
  
  /* CPU registers */
  reg RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
  reg [7:0] extDBin;
  
  wire phi1_out, SYNC, phi2_out, RW;
  wire [15:0] extAB; //Address Bus Low and High
  
  wire [7:0] extDB; //Data Bus
  
  integer i, j;
  
  reg [3:0] numCycles;
  reg [11:0] vectors [NUM_TESTS-1:0];
  reg [11:0] vec; 
  
  /* Memory registers */
  reg clock, enable, we_L, re_L;
  reg [15:0] address;
  
  
  //Setting up the clock to run
  always begin
    #10 phi0_in = ~phi0_in;
  end
  
  top_6502C top_6502C_module(.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), .extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extAB(extAB), .phi2_out(phi2_out), .RW(RW));
  
  memory256x256 mem256x256_module(.clock(phi1_out), .enable(enable), .we_L(we_L), .re_L(re_L), .address(address), .data(extDB));

  
  
  /* High level description:  
   *  We want to generate an opcode on the databus, provide it to the CPU, and have it return a certain checkable value (e.g. control signals and Tstates (which we will have to hook out)), after a certain (known) number of clock cycles have passed.
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
  
  /*  We only control the bytecode that's coming in, we feed it into CPU one byte by one byte, and the CPU should be taking care of it. Display the associated outputs every half cycle (posedge and negedge phi0) Qn: when should I be loading the new byte from memory into the DBin? after every full clock?   
    
  
  */

  task run_vector;
    begin

      $display("======================");

      $display("DB: \t%h", extDB);
      
      @(posedge phi0_in);
      
      $display("DB:\t%h\tAB:\t%h\tSYNC:\t%h\tRW:\t%h\tcontrolSigs: \t%b\tA:\t%h\tY:\t%h", extDB, extAB, SYNC, RW, top_6502C_module.controlSigs, top_6502C_module.A, top_6502C_module.SB);
      
      @(negedge phi0_in);
      
      //Check that the output is correct
      //ALTERNATIVE: check that certain outputs correspond to expected values
      
      $display("DB:\t%h\tAB:\t%h\tSYNC:\t%h\tRW:\t%h\tcontrolSigs: \t%b\tA:\t%h\tY:\t%h", extDB, extAB, SYNC, RW, top_6502C_module.controlSigs, top_6502C_module.A, top_6502C_module.SB);
      
      $display("======================");
    
    end
    
  endtask
    






  initial begin
  
  phi0_in = 1'b0;
  enable = 1'b1;
  we_L = 1'b1;
  re_L = 1'b0; //We want to be reading from memory
  
  for (i=0; i<NUM_TESTS; i=i+1) begin
    run_vector;
  end
  
  $finish;
  
  end





endmodule

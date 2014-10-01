/*  Test module for top level CPU FSM
 *  Created:        1 Oct 2014, 1120 hrs (bhong)
 *  Last Modified:  1 Oct 2014, 1120 hrs

 Designed to test module "plaFSM", located in "plaFSM.v"

*/

module testCPU_FSM;

  parameter NUM_VECTORS=10;
  
  reg phi1, phi2, nmi, irq, rst, RDY;
  reg [7:0] statusReg, opcodeIn; //what is this status reg?
  
  reg [2:0] numCycles;
  
  reg [18:0] vectors [NUM_VECTORS-1:0];
  reg [18:0] vec;
  
  integer i, j;
  
  wire [62:0] controlSigs;
  wire SYNC;
  wire setBflag, clrBflag;
  
  plaFSM plaFSM_mod(.phi1(phi1), .phi2(phi2), .nmi(nmi), .rst(rst), .RDY(RDY), .statusReg(statusReg), .opcodeIn(opcodeIn), .controlSigs(controlSigs), .SYNC(SYNC), .setBflag(setBflag), .clrBflag(clrBflag));
  
  //need to keep flipping two clocks? off by half?
  
  //need to figure out how many times to clock the system before the results are known
  //put into vm file, 8 bit statusReg + 8 bit opcode + 3 bits to tell the number of required cycles
  //use task to cycle the appropriate number of times, then display the controlSigs, SYNC, and others
  
  
  task run_vector;
  input [7:0] A, B;
  input [2:0] C;
  begin
    statusReg = A;
    opcodeIn = B;
    numCycles = C;
    //clock the number of cycles, after this, the result should be ready on controlSigs already.
    //@(posedge clock) x 30
    
    $display("======================");
    
    $display("\tstatusReg is: \t%b, \topcodeIn is: \t%b, \tnumCycles is: \t%d", statusReg, opcodeIn, numCycles);
    
    
    for (j = 3'd0; j < numCycles; j=j+1) begin
      @(posedge phi1);
      @(posedge phi2);
    end
    
    
    $display("\tcontrolSigs: \t%b, \tSYNC: \t%b, \tsetBflag: \t%b, \tclrBflag: \t%b", controlSigs, SYNC, setBflag, clrBflag);
    
    $display("======================");
    
    
    
  
  end
  
  endtask
  
  
  initial begin
  
  $readmemh("fsm_test_vectors.vm", vectors);
  for (i=0; i<NUM_VECTORS; i=i+1) begin
    vec = vectors[i];
    run_vector(vec[18:11], vec[10:3], vec[2:0]);
    //run_vector(statusReg, opcodeIn, numCycles);
  end
  
  $finish;
  
  end

endmodule  
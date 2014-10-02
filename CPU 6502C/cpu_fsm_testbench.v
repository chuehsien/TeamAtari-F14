/*  Test module for top level CPU FSM
 *  Created:        1 Oct 2014, 1120 hrs (bhong)
 *  Last Modified:  1 Oct 2014, 1120 hrs

 Designed to test module "plaFSM", located in "plaFSM.v"

*/
module testCPU_FSM;
  //This number needs to change according to how many lines there are in fsm_test_vectors.vm
  parameter NUM_VECTORS=30;
  
  reg phi1, nmi, irq, rst, RDY;
  reg [7:0] statusReg, opcodeIn; 
  wire phi2;
  
  
  reg [2:0] numCycles;
  
  reg [31:0] vectors [NUM_VECTORS-1:0];
  reg [31:0] vec; 
  //20 bits per test vector, (nmi, irq, rst, RDY, opcodeIn, statusReg)
  
  integer i, j;
  
  reg[6:0] T_state;
  reg[2:0] FSM_state;
  reg[8*15:0] T_string;
  reg[8*9:0] FSM_string;
  
  wire [62:0] controlSigs;
  wire SYNC;
  
  //Setting up the clock signals
  assign phi2 = ~phi1;
  
  always begin
    #10 phi1 = ~phi1; //check after phi1 goes up @(posedge phi1)
  end
  
  
  
  plaFSM plaFSM_mod(.phi1(phi1), .phi2(phi2), .nmi(nmi), .irq(irq), .rst(rst), .RDY(RDY), 
                   .opcodeIn(opcodeIn), .statusReg(statusReg), .controlSigs(controlSigs), .SYNC(SYNC),.T1now());
  
  //need to keep flipping two clocks? off by half? Ans: no, just flip phi1 and get phi2 to be ~phi1
  
  //on every clock we should display the produced controlSignals
  //put into vm file, 8 bit statusReg + 8 bit opcode + 3 bits to tell the number of required cycles
  //use task to cycle the appropriate number of times, then display the controlSigs, SYNC, and others
  
  //20 bits per test vector, (nmi, irq, rst, RDY, opcodeIn, statusReg)
  task run_vector;
  input A, B, C, D;
  input [7:0] E, F;
  
  begin
    nmi = A;
    irq = B;
    rst = C;
    RDY = D;
    opcodeIn = E;
    statusReg = F;
    // numCycles = C;
    //clock the number of cycles, after this, the result should be ready on controlSigs already.
    
    //$display("A: %4d, B: %d, C:%d, E: %d, F: %D",A,B,C,D,E,F);
    T_state = plaFSM_mod.curr_T;
    FSM_state = plaFSM_mod.curr_state;
    TtoString();
    FSMtoString();

    $display("@%3d, SR: %b, OP: %b, nmi: %b, irq: %b, rst: %b, RDY: %b",i,statusReg, opcodeIn, nmi, irq, rst, RDY);
    $display("@%3d, (%s,%s) ---> control: %b, SYNC: %b",i, FSM_string,T_string, controlSigs, SYNC);
    
    
  end
  
  endtask
  
  task TtoString;
      begin
      if (T_state == `Tzero) T_string = "Tzero";
      else if (T_state == `Tone) T_string = "Tone";
      else if (T_state == `Ttwo) T_string = "Ttwo";
      else if (T_state == `Tthree) T_string = "Tthree";
      else if (T_state == `Tfour) T_string = "Tfour";
      else if (T_state == `Tfive) T_string = "Tfive";
      else if (T_state == `Tsix) T_string = "Tsix";
      else if (T_state == `T1NoBranch) T_string = "T1NoBranch";
      else if (T_state == `T1BranchNoCross) T_string = "T1BranchNoCross";
      else if (T_state == `T1BranchCross) T_string = "T1BranchCross";
      else if (T_state == `TzeroNoCrossPg) T_string = "TzeroNoCrossPg";
      else if (T_state == `TzeroCrossPg) T_string = "TzeroCrossPg";
      else T_string = "error";
      end
  endtask
  
    task FSMtoString;
      begin
      if (FSM_state == `FSMinit) FSM_string = "FSMinit";
      else if (FSM_state == `FSMfetch) FSM_string = "FSMfetch";
      else if (FSM_state == `FSMstall) FSM_string = "FSMstall";
      else if (FSM_state == `execNorm) FSM_string = "execNorm";
      else if (FSM_state == `execRMW) FSM_string = "execRMW";
      else if (FSM_state == `execBranch) FSM_string = "execBranch";
      else if (FSM_state == `execBrk) FSM_string = "execBrk";
      else FSM_string = "error";
      end
  endtask
  
  
  initial begin
  phi1 = 0;
    
  $readmemh("fsm_test_vectors.vm", vectors);
  for (i=0; i<NUM_VECTORS; i=i+1) begin
    vec = vectors[i];
    @(posedge phi1);
    $display("==========posedge========");
    run_vector(vec[28], vec[24], vec[20], vec[16], vec[15:8], vec[7:0]);
    //run_vector(4 bits of signals, statusReg, opcodeIn);
    
    @(negedge phi1);
    $display("==========negedge========");
    run_vector(vec[28], vec[24], vec[20], vec[16], vec[15:8], vec[7:0]);
  end
  
  $finish;
  
  end

endmodule  
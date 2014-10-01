// Test top module for ANTIC

`include "ANTIC.v"
`include "RAM.v"

module testANTIC;

  reg reset;
  reg clock;
  
  wire [2:0] AN;
  wire halt_L;
  wire [15:0] address;
  wire [7:0] DB;
  wire [15:0] dlistptr;
  wire [1:0] cstate;
  wire [7:0] data;
  
  // Instantiate Modules
  memory256x256 mem(.clock(clock), .enable(1'b1), .we_L(1'b1), .re_L(halt_L), .address(address), .data(DB));
  ANTIC antic(.F_phi0(), .LP_L(), .RW(), .RST(reset), .phi2(clock), .DB(DB), .address(address), .AN(AN),
              .halt_L(halt_L), .NMI_L(), .RDY_L(), .REF_L(), .RNMI_L(), .phi0(), .printDLIST(dlistptr), .cstate(cstate), .data(data));
  
  task print;
    $display("halt_L is %b, curr_state is %b, data is %h", halt_L, cstate, data);
  endtask
  
  initial begin
    $display("Begin ANTIC test.");
    clock = 1'b0; 
    
    reset = 1'b1;
    @(posedge clock); @(negedge clock);
    $display("reset is %b, curr_state is %b", reset, cstate);
    
    reset = 1'b0;
    
    @(posedge clock); @(negedge clock);
    print;
    @(posedge clock); @(negedge clock);
    print;
    @(posedge clock); @(negedge clock);
    print;
    @(posedge clock); @(negedge clock);
    print;
    
    // Print address of display list ptr
    $display("Display list pointer is %h.", dlistptr);
  
    $display("Completed ANTIC test.");
    $finish;
  end
  
  always begin
    forever #10 clock = ~clock;
  end
  
endmodule
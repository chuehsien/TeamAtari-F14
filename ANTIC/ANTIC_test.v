// Test top module for ANTIC

`include "ANTIC.v"
`include "RAM.v"

module testANTIC;

  reg reset;
  reg Fphi0;
  reg phi2;
  
  wire [2:0] AN;
  wire halt_L;
  wire [15:0] address;
  wire [7:0] DB;
  wire [15:0] dlistptr;
  wire [2:0] cstate;
  wire [7:0] data;
  wire [7:0] dataReg;
  wire [7:0] IR;
  
  // Instantiate Modules
  memory256x256 mem(.clock(~phi2), .enable(1'b1), .we_L(1'b1), .re_L(halt_L), .address(address), .data(DB));
  ANTIC antic(.Fphi0(Fphi0), .LP_L(), .RW(), .RST(reset), .phi2(phi2), .DB(DB), .address(address), .AN(AN),
              .halt_L(halt_L), .NMI_L(), .RDY_L(), .REF_L(), .RNMI_L(), .phi0(), .printDLIST(dlistptr), .cstate(cstate), .data(data), .IR_out(IR));
  
  task print;
    $display("halt_L is %b, curr_state is %b, data is %h, IR is %h", halt_L, cstate, data, IR);
  endtask
  
  initial begin
    $display("Begin ANTIC test.");
    Fphi0 = 1'b0;
    phi2 = 1'b0; 
    
    reset = 1'b1;
    @(posedge phi2); @(negedge phi2);
    reset = 1'b0;
    //$display("reset is %b, curr_state is %b", reset, cstate);
    
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    
    // Print address of display list ptr
    $display("Display list pointer is %h.", dlistptr);
    
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    print; @(posedge phi2); @(negedge phi2);
    
    $display("Completed ANTIC test.");
    $finish;
  end
  
  always begin
    forever #20  phi2 = ~phi2;
  end
  
  always begin
    forever #10 Fphi0 = ~Fphi0;
  end
  
endmodule
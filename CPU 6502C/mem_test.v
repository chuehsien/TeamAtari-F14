module testMem256x256;

  reg clock, enable, we_L, re_L;
  reg [15:0] address;
  reg [7:0] data_reg;
  
  wire [7:0] data;
  
  always begin
    forever #10 clock = ~clock;
  end
  
  memory256x256 mem256x256_module(.clock(clock), .enable(enable), .we_L(we_L), .re_L(re_L), .address(address), .data(data));
  
  
  task printMem;
    begin
      $display("Memory at %h: \t%h", address, data);
    end
  endtask
  
  assign data = (enable & ~we_L & re_L) ? data_reg : 8'bzzzzzzzz; //if its time to write, then data should have data_reg, otherwise it should be disconnected
  
  
  initial begin
    clock = 1'b0;
    @(posedge clock);
    
    enable = 1'b1;
    we_L = 1'b1;
    re_L = 1'b0;
    
    #50;
    $display("initial printing from memory...");
    $display("=======================");
    for (address = 16'd0; address < 16'hFFFF; address = address + 16'd1) begin
      #50;
      printMem;   
    end
    #50;
    printMem;
    $display("=======================");
    $display("done printing from memory...");
    
    
    $display("amending memory...");
    enable = 1'b1;
    we_L = 1'b0;
    re_L = 1'b1;
    address = 16'd0;
    data_reg = 8'hBE;
    #50;
    
    $display("done amending memory...");
    $display("printing from amended memory...");
    enable = 1'b1;
    we_L = 1'b1;
    re_L = 1'b0;
    address = 16'd0;
    #50;
    printMem;
    
    $display("done printing amended memory...");
  
    $finish;
  
  end
  
  
  
endmodule
module trig_latch (side_but, en_latch, bottom_latch);

    input [1:0] side_but;
    input en_latch;
    output bottom_latch;

   FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_inst (
      .Q(bottom_latch),      // 1-bit Data output
      .C(~side_but[0]),      // 1-bit Clock input
      .CE(en_latch),    // 1-bit Clock enable input
      .CLR(~en_latch),  // 1-bit Asynchronous clear input
      .D(1'b1)       // 1-bit Data input
   );
  
  


endmodule
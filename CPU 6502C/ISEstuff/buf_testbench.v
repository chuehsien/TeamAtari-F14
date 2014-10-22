/*  
  Test module for bidirectional pass mosfet
  
  Description:
    - SW[1-4] sets the data on the left bus
    - SW[5-8] sets the data on the right bus
    - SW_W asserts the data on the left bus
    - SW_E asserts the data on the right bus
    - SW_C bridges the two buses
    - LED[0-3] displays the data on the left bus
    - LED[4-7] displays the data on the right bus
*/

module testBUF(GPIO_SW_C,GPIO_DIP_SW1,GPIO_LED_0);
               
    input GPIO_SW_C,GPIO_DIP_SW1;
  
    output GPIO_LED_0;

    (* clock_signal = "yes" *)wire NMI_L;
    wire nmiPending,nmiDone;
    assign GPIO_LED_0 = nmiPending;
    assign nmiDone = GPIO_SW_C;
    assign NMI_L = GPIO_DIP_SW1;
    
   FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_inst (
      .Q(nmiPending),      // 1-bit Data output
      .C(~NMI_L),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .CLR(nmiDone),  // 1-bit Asynchronous clear input
      .D(1'b1)       // 1-bit Data input
   );
   
   
   

endmodule

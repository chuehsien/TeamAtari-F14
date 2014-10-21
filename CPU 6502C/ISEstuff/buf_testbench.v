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

module testBUF(USER_CLK,GPIO_SW_C, 
               GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5,
               GPIO_LED_6, GPIO_LED_7);
               
    input USER_CLK,GPIO_SW_C;
  
    output GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3,
           GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;

    wire phi1,phi2,phi2_shifted,phi0_in;
    assign GPIO_LED_0 = phi1;
    assign GPIO_LED_1 = phi2;
    assign GPIO_LED_2 = phi2_shifted;
    assign GPIO_LED_7 = phi0_in;
    assign {GPIO_LED_3, GPIO_LED_4, GPIO_LED_5} = 3'd0;
    
    assign GPIO_LED_6 = GPIO_SW_C;
    clockone2048 test1(USER_CLK,memClk_b0);
    clockone2048 test2(memClk_b0,memClk_b1);
    clockone4    test3(memClk_b1,memClk_b2);
    clockone4    test4(memClk_b2,phi0_in);
    
    clockGen test(.RST(GPIO_SW_C),.phi0_in(phi0_in),.phi1_out(phi1),.phi2_out(phi2),.phi2shift_out(phi2_shifted));
    

endmodule

module clockGen(RST,phi0_in,
                phi1_out,phi2_out,phi2shift_out);
                
    input RST,phi0_in;
    output phi1_out,phi2_out,phi2shift_out;
  
    wire DCMIn;
    BUFG DCMb(.O(DCMin),.I(phi0_in));
  
    wire phi1,phi2,phi2shift;
  
  
    BUFG a(.O(phi1_out),.I(~phi0_in));
    
    BUFG b(.O(phi2_out),.I(phi0_in));
    
    skewClk test(phi2shift_out,phi2_out);

    
endmodule

// delay the clock by 1 tick.
module skewClk(outClk,inClk);
    output outClk;
    input inClk;
    
    reg [1:0] count = 1'b0;


    always @ (posedge inClk) begin
        count <= {count[0],~count[0]};
    end
    
    assign outClk = count[1];
endmodule

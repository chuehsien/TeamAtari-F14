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

module testBUF(GPIO_SW_C, GPIO_SW_E, GPIO_SW_W, GPIO_DIP_SW1, GPIO_DIP_SW2,
               GPIO_DIP_SW3, GPIO_DIP_SW4, GPIO_DIP_SW5, GPIO_DIP_SW6,
               GPIO_DIP_SW7, GPIO_DIP_SW8, GPIO_LED_0, leftBus, rightBus,
               GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5,
               GPIO_LED_6, GPIO_LED_7);
               
    input GPIO_SW_C, GPIO_SW_E, GPIO_SW_W;
    input GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4,
          GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8;
    inout [3:0] leftBus, rightBus;          
    output GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3,
           GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;

    assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, 
            GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = {leftBus, rightBus};
    
    // Pullup mosfets for databus (drives bus with 0xFF when no data is driven)
    PULLUP pL [3:0] (.O(leftBus));
    PULLUP pR [3:0] (.O(rightBus));
    
    assign leftBus = (GPIO_SW_W) ? {GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4} : 4'hz;
    assign rightBus = (GPIO_SW_E) ? {GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8} : 4'hz;
               
    wire enLeft, enRight;
    assign enLeft = (leftBus != 4'hF);
    assign enRight = (rightBus != 4'hF);
    
    wire notEq;
    assign notEq = (leftBus != rightBus);
    
    bufif1 LtoR(rightBus, leftBus, (GPIO_SW_C & notEq & enLeft));
    bufif1 RtoL(leftBus, rightBus, (GPIO_SW_C & notEq & enRight));
    
endmodule


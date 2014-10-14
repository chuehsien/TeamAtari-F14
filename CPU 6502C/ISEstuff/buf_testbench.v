`include "peripherals.v"

/*
center switch to enable trans.
*/
module testBUF(GPIO_SW_C,GPIO_SW_W,GPIO_SW_E,			   
               GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8,  
               GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7);

	input GPIO_SW_C,GPIO_SW_W,GPIO_SW_E, GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8;    
	output GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	
    wire GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	
    (* PULLUP = "yes" *) wire [3:0] left,right;
    assign left = (GPIO_SW_W) ? {GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4} : 4'hz;
               
    assign right = (GPIO_SW_E) ? {GPIO_DIP_SW5,
               GPIO_DIP_SW6,
                GPIO_DIP_SW7,
               GPIO_DIP_SW8} : 4'hz;
               
    assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = {left,right};
    passBuffer SBtoDB(left,GPIO_SW_C,right);
    passBuffer DBtoSB(right,GPIO_SW_C,left);
            
endmodule           
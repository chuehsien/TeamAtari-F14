/*  Test module for top level CPU 6502C 

 Designed to test module "top_6502C", located in "top_6502C.v"

*/


/*
description:
press west button to reset lcd
press south button to tick up phi1.
press centre button to reset cpu.
press north button to display current eDB on lcd.
press east button to clear lcd.
the lower byte of eAB is always on the leds.

*/
module testBUF(GPIO_SW_C,			   
			   GPIO_SW_E,			   
			   GPIO_SW_W,


               GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4,
               GPIO_DIP_SW5,
               GPIO_DIP_SW6,
               GPIO_DIP_SW7,
               GPIO_DIP_SW8,
               
               left,right,
               GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7);



	input	   GPIO_SW_C, GPIO_SW_E, GPIO_SW_W;
	input      GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4,
               GPIO_DIP_SW5,
               GPIO_DIP_SW6,
               GPIO_DIP_SW7,
               GPIO_DIP_SW8;
    inout [3:0] left,right;           
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	
    
    wire [3:0] left,right;
    //dualBus db(left,right);

	assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = {left,right};
    
    /*
    assign left = (GPIO_SW_W) ? {GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4} : 4'hz;
               
    assign right = (GPIO_SW_E) ? {GPIO_DIP_SW5,
               GPIO_DIP_SW6,
                GPIO_DIP_SW7,
               GPIO_DIP_SW8} : 4'hz;
       */       
               
     /*          
    wire enLeft, enRight;
    assign enLeft = (left != 4'hf);
    assign enRight = (right != 4'hf);
    
    pass LtoR(right,enLeft,left);
    pass RtoL(left,enRight,right);
    
*/
endmodule


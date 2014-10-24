module lcd_top(
			   GPIO_DIP_SW1,
			   GPIO_DIP_SW2,
			   GPIO_DIP_SW3,
			   GPIO_DIP_SW4,
			   GPIO_DIP_SW5,
			   GPIO_DIP_SW6,
			   GPIO_DIP_SW7,
			   GPIO_DIP_SW8,
               GPIO_LED_C);
		

	input	    GPIO_DIP_SW1,
			   GPIO_DIP_SW2,
			   GPIO_DIP_SW3,
			   GPIO_DIP_SW4,
			   GPIO_DIP_SW5,
			   GPIO_DIP_SW6,
			   GPIO_DIP_SW7,
			   GPIO_DIP_SW8;

    output      GPIO_LED_C;


    wire [7:0] db;
    assign db = {GPIO_DIP_SW1,
			   GPIO_DIP_SW2,
			   GPIO_DIP_SW3,
			   GPIO_DIP_SW4,
			   GPIO_DIP_SW5,
			   GPIO_DIP_SW6,
			   GPIO_DIP_SW7,
			   GPIO_DIP_SW8};

    assign GPIO_LED_C = (~|db);

endmodule


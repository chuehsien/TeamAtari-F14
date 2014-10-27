module POKEY_controller_interface (key_scan_L, control_input, control_output, kr1_L, kr2_L, pot_scan_2);

    input [5:0] key_scan_L;
    input [8:0] control_input; 
	 output [3:0] control_output;
    output kr1_L, kr2_L;
    output [1:0] pot_scan_2;

    /*  Controller Pinout 
     * 
     *  Pins 1-8: Keyboard (0-9, Start, Pause, Reset) (0-3)(0-3)
     *  Pins 9-11: Potentiometer Reads (4-6)
	9: POT common (4)
	10: left-right POT (5)
	11: up-down POT (6)
     *  Pins 13-15: 4 x Side Buttons
	15: GND (not included)
	14: top side buttons (8)
	13: bottom side buttons (7)
     *
     *
     */
     
     //K4, K5 selects pins 5-8
     //K1,K2 selects pins 1-4
     
    //wire output1, output2;
     
    mux pin_4_1 (control_input[3:0], key_scan_L[2:1], kr1_L);
     
    demux pin_8_5 (1'b0, key_scan_L[5:4], control_output[3:0]);
	
    assign pot_scan_2 = control_input[6:5];

	
    
    


endmodule

/* 
module controller_test;
    reg [5:0] key_scan_L;
    reg [14:0] control_input;
    wire kr1_L;
    
    
endmodule */

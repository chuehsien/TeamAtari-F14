module POKEY_controller_interface (key_scan_L, control_input, kr1_L, kr2_L);

    input [5:0] key_scan_L;
    input [14:0] control_input; 
    output kr1_L, kr2_L;

    /*  Controller Pinout 
     * 
     *  Pins 1-8: Keyboard (0-9, Start, Pause, Reset)
     *  Pins 9-11: Potentiometer Reads
     *  Pins 13-15: 4 x Side Buttons
     *
     *
     */
     
     //K4, K5 selects pins 5-8
     //K1,K2 selects pins 1-4
     
    //wire output1, output2;
     
    mux pin_4_1 (control_input[3:0], key_scan_L[2:1], kr1_L);
     
    demux pin_8_5 (1'b0, key_scan_L[5:4], control_input[7:4]);
    
    


endmodule

/* 
module controller_test;
    reg [5:0] key_scan_L;
    reg [14:0] control_input;
    wire kr1_L;
    
    
endmodule */
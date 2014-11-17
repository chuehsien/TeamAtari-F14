module POKEY_top(CLK_27MHZ_FPGA, HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_20, HDR1_22, HDR1_24, HDR1_26,
				GPIO_SW_C, GPIO_SW_E,
				HDR1_10, HDR1_12, HDR1_14, HDR1_16, HDR1_18, HDR1_54, HDR1_58,
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
				GPIO_LED_C , GPIO_LED_E, GPIO_LED_N, GPIO_LED_S, GPIO_LED_W, HDR1_64);
	//input USER_CLK;
	input CLK_27MHZ_FPGA;
		
	input HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_20, HDR1_22, HDR1_24, HDR1_26;
	input GPIO_SW_C, GPIO_SW_E;  

	//SW_C==1: write to POTGO, SW_C==0: continue key_scan
	//SW_E==1: display POT0;

	/*	
	*	Atari 5200 Controller Pinout:
	*
	* 	HDR1_2: Pin 1
	*	HDR1_4: Pin 2
	*	HDR1_6:Pin 3
	*	HDR1_8:Pin 4
	*	HDR1_10:Pin 5
	* 	HDR1_12:Pin 6
	*	HDR1_14:Pin 7
	*	HDR1_16:Pin 8
	*	HDR1_18:Pin 9 
	*	HDR1_20:Pin 10
	*	HDR1_22:Pin 11
	* 	HDR1_24:Pin 13
	*	HDR1_26:Pin 14
	*
	*	Pin 12: VCC 5V
	*	Pin 15: GND
	*
	*/
	
	output HDR1_10, HDR1_12, HDR1_14, HDR1_16, HDR1_18, HDR1_54, HDR1_58;
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output 	GPIO_LED_C , GPIO_LED_E, GPIO_LED_N, GPIO_LED_S, GPIO_LED_W;  
	output HDR1_64;

	//19 Key Buttons, 8 Pots to test
	// 8 + 5 available LEDs for output = 13 LEDs

	wire[3:0]key_scan_L;
	wire kr1_L;
	wire o2;
	wire[7:0]pot_scan;
	wire[1:0]pot_scan_2;
	(* PULLUP="yes" *) wire[3:0]control_input_4_1;
	wire[3:0]control_output_8_5;
	wire [2:0] control_input_pot_scan;
	wire [1:0] control_input_side_but;
	wire[3:0] addr_bus;
	wire [7:0] out;
	
	wire [35:0] CONTROL0,CONTROL1;
	wire [7:0] TRIG0,
    TRIG1,
    TRIG2,
    TRIG3,
    TRIG4,
    TRIG5,
    TRIG6,
    TRIG7,
    TRIG8,
    TRIG9,TRIG10, TRIG11, TRIG12, TRIG13, TRIG14, TRIG15;
	 wire cs_clk1, cs_clk2;
	 
	 wire center_pressed;
	 wire testing_wire, test_out;
	 
	 //testing hooks
	 wire pot_rel_0, pot_rel_1;
	 wire [3:0] compare_latch;
	 wire [3:0] keycode_latch;
	 wire key_depr;
	 wire [7:0] bin_ctr_pot, POT0, POT1;

	assign addr_bus = center_pressed ? 4'b0000 : 4'b1111;
	//assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = out;
	assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3} = 4'b0000;
	assign {GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = keycode_latch;
	//assign out = GPIO_SW_E ? 
	assign pot_scan = {6'd0, pot_scan_2};
	assign control_input_4_1 = {HDR1_8, HDR1_6, HDR1_4, HDR1_2};
	assign control_input_pot_scan = {HDR1_22, HDR1_20, HDR1_18};
	assign control_input_side_but = {HDR1_26, HDR1_24};
	assign {HDR1_16, HDR1_14, HDR1_12,HDR1_10} = control_output_8_5;
	assign HDR1_54 = pot_rel_0;
	assign HDR1_58 = pot_rel_1;
	assign HDR1_18 = 1'b1; //permanently powered
	assign HDR1_64 = o2;
	
	//clockGen179 clk_179(.RST(0),.clk27(CLK_27MHZ_FPGA), .fphi0(testing_wire) ,.phi0(o2),.locked());
	clockDivider #(1800) out15(CLK_27MHZ_FPGA,o2);
	//BUFG test_buf (test_out, testing_wire);
	
	clockone4 clk_divide_mod3(.inClk(CLK_27MHZ_FPGA),.outClk(cs_clk1));
	//clockone4 clk_divide_mod3(.inClk(cs_clk1),.outClk(o2));
	//clockone4 clk_divide_mod4(.inClk(cs_clk2),.outClk(o2));
	
	//clockone2048 clk_divide_mod(.inClk(USER_CLK),.outClk(cs_clk1));
	
	DeBounce debounce_mod(.clk(CLK_27MHZ_FPGA), .n_reset(1'b1), .button_in(GPIO_SW_C),.DB_out(center_pressed));

	POKEY_controller_interface pokey_ctrl_interface_mod (.key_scan_L(key_scan_L), .control_input({control_input_side_but, control_input_pot_scan, control_input_4_1}), .control_output(control_output_8_5), .kr1_L(kr1_L), .kr2_L(), .pot_scan_2(pot_scan_2));

	/*
	input [5:0] key_scan_L;
	input [14:0] control_input; 
    	output kr1_L, kr2_L; kr2_L LEFT BLANK
	*/

	
	
	POKEY pokey_mod(.o2(o2), .cs0_L(), .cs1(), .rw_ctrl(), .pot_scan(pot_scan), .kr1_L(kr1_L), .kr2_L(), .addr_bus(addr_bus), .sel(GPIO_SW_E), .POTGO(), .key_scan_L(key_scan_L), .irq_L(), .audio_out(), .pot_rel_0(pot_rel_0), .pot_rel_1(pot_rel_1), .compare_latch(compare_latch), .keycode_latch(keycode_latch), .key_depr(key_depr), .bin_ctr_pot(bin_ctr_pot), .POT0(POT0), .POT1(POT1), .ALLPOT(), .data_bus(out), .bclk());

	/*
	input o2; //phase 2 clock

    	input cs0_L, cs1, rw_ctrl; //chip select and R/W control LEFT BLANK

   	input [7:0] pot_scan; //potentiometer scan

    	input kr1_L, kr2_L; //indicates the value of key being pressed kr2_L left blank

    	input [3:0] addr_bus; //what is this addr_bus for? the place in mem to write to/read from 
    
	output [5:0] key_scan_L; //0 - 63, which key do we want to scan? BINARY. 
	output irq_L; //interrupt request LEFT BLANK
	output audio_out; //for audio generation chip LEFT BLANK
	    
	inout [7:0] data_bus; //keycode latch values are output here too QN: how do we buf this?
	inout bclk;//bidirection clock LEFT BLANK
	*/

	
	
	chipscope_icon  icon(
    CONTROL0,
    CONTROL1);
	 
	
	 
	chipscope_ila inst0(
    CONTROL0,
    cs_clk1,
    {4'd0, key_scan_L}, //7:0
    {7'd0, kr1_L}, //15:8
    {7'd0, o2}, //23:16
    pot_scan, //31:24
    {6'd0, pot_scan_2}, //39:32
    {6'd0,control_input_side_but}, //47:40
    {1'd0, control_input_pot_scan, control_input_4_1}, //55:48
    {4'd0, control_output_8_5}, //63:56
    {4'd0, addr_bus}, //71:64
    out, //79:72
    {pot_rel_0, pot_rel_1, ~key_scan_L}, //87:80
    {4'd0, compare_latch}, //95:88
    {key_depr,3'd0, compare_latch}, //103:96
    bin_ctr_pot, //111:104
    POT0, //119:112
    POT1); //127:120
	 
	 chipscope_ila inst1(
    CONTROL1,
    cs_clk1,
    TRIG0,
    TRIG1,
    TRIG2,
    TRIG3,
    TRIG4,
    TRIG5,
    TRIG6,
    TRIG7,
    TRIG8,
    TRIG9,
    TRIG10,
    TRIG11,
    TRIG12,
    TRIG13,
    TRIG14,
    TRIG15);
	 
	 /*wire[5:0]key_scan_L;
	wire kr1_L;
	wire o2;
	wire[7:0]pot_scan;
	wire[1:0]pot_scan_2;
	wire[8:0]control_input;
	wire[3:0]control_output;
	wire[3:0] addr_bus;
	wire [7:0] out;*/
endmodule

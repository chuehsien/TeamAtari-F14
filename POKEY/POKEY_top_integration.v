module POKEY_top_integration(CLK_27MHZ_FPGA, HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P, 
										HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P, HDR2_24_SM_10_P, HDR2_26_SM_11_N, GPIO_SW_C, 
										GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4,

                            POT0_bus, POT1_bus, ALLPOT_bus, KBCODE_bus, TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus, 
									 HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P, HDR2_22_SM_10_N, HDR2_28_SM_11_P, 
									 HDR2_30_DIFF_3_N, 
									 GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7);

input CLK_27MHZ_FPGA;
//input [7:0] SKCTL, GRACTL, POTGO;
input HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P,  HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P, HDR2_24_SM_10_P, HDR2_26_SM_11_N;
input GPIO_SW_C, GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4;


output [7:0] POT0_bus, POT1_bus, ALLPOT_bus, KBCODE_bus;
output TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus;
output HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P, HDR2_22_SM_10_N, HDR2_28_SM_11_P, HDR2_30_DIFF_3_N;
output GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;




    
    
    /*
    * Available pins: 

        NET  HDR2_2_SM_8_N        LOC="K34";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[15]) J4-2
        NET  HDR2_4_SM_8_P        LOC="L34";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[15]) J4-4
        NET  HDR2_6_SM_7_N        LOC="K32";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[14]) J4-6
        NET  HDR2_8_SM_7_P        LOC="K33";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[14]) J4-8
        NET  HDR2_10_DIFF_0_N     LOC="N32";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[13]) J4-10
        NET  HDR2_12_DIFF_0_P     LOC="P32";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[13]) J4-12
        NET  HDR2_14_DIFF_1_N     LOC="R34";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[12]) J4-14
        NET  HDR2_16_DIFF_1_P     LOC="T33";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[12]) J4-16
        NET  HDR2_18_DIFF_2_N     LOC="R32";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[11]) J4-18
        NET  HDR2_20_DIFF_2_P     LOC="R33";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[11]) J4-20
        NET  HDR2_22_SM_10_N      LOC="T34";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[10]) J4-22
        NET  HDR2_24_SM_10_P      LOC="U33";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[10]) J4-24
        NET  HDR2_26_SM_11_N      LOC="U31";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[9]) J4-26
        NET  HDR2_28_SM_11_P      LOC="U32";   # Bank 11, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[9]) J4-28
        NET  HDR2_30_DIFF_3_N     LOC="V33";   # Bank 13, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXN[8]) J4-30
        NET  HDR2_32_DIFF_3_P     LOC="V32";   # Bank 13, Vcco=2.5V or 3.3V user selectable by J20 (SYSMON External Input: VAUXP[8]) J4-32

        HDR2_2_SM_8_N           Pin 8                       (output)
        HDR2_4_SM_8_P           Pin 7                       (output)
        HDR2_6_SM_7_N           Pin 6                       (output)
        HDR2_8_SM_7_P           Pin 5                       (output)
        HDR2_10_DIFF_0_N        Pin 4                       (input)
        HDR2_12_DIFF_0_P        Pin 3                       (input)
        HDR2_14_DIFF_1_N        Pin 2                       (input)
        HDR2_16_DIFF_1_P        Pin 1                       (input)
        HDR2_18_DIFF_2_N        Pin 14 (top side buttons)   (input) (BRK?)
        HDR2_20_DIFF_2_P        Pin 13 (bottom side buttons)(input) (TRIG)
        HDR2_22_SM_10_N         Pin 9 (driving Pot current) (output) 
        HDR2_24_SM_10_P         Pin 11 (Up/Down Pot)        (input)
        HDR2_26_SM_11_N         Pin 10 (Left/Right Pot)     (input)
        HDR2_28_SM_11_P         POT0 Release (Up/Down)      (output)
        HDR2_30_DIFF_3_N        POT1 Release (Left/Right)   (output)
        HDR2_32_DIFF_3_P  

    */

    /* Notes:
        We need to include functionality for POTGO, ALLPOT, mux-ing the triggers
    */

   wire[3:0]key_scan_L;
	wire kr1_L;
	wire o2;
	wire[7:0]pot_scan;
	wire[1:0]pot_scan_2;
	wire[3:0]control_input_4_1;
	wire[3:0]control_output_8_5;
	wire [2:0] control_input_pot_scan;
	wire [1:0] control_input_side_but;
	wire[3:0] addr_bus;
	wire [7:0] out;
    
    wire pot_rel_0, pot_rel_1;
    wire [3:0] compare_latch;
    wire [3:0] keycode_latch;
    wire key_depr;
    wire [7:0] bin_ctr_pot, POT0_bus, POT1_bus;

    wire trig0_latch, trig1_latch, trig2_latch, trig3_latch;
	 
	 //reg [3:0] KBCODE_4_1;
    
    
    /* Testing harness - Chipscope */
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
     wire [7:0] SKCTL, GRACTL, POTGO;
	  
    assign pot_scan = {6'd0, pot_scan_2};
	 assign control_input_4_1 = {HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P};
    assign control_input_pot_scan = {HDR2_24_SM_10_P, HDR2_26_SM_11_N, 1'b1};
    assign control_input_side_but = {HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P};
    assign {HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P} = control_output_8_5;
    assign HDR2_28_SM_11_P = pot_rel_0;
    assign HDR2_30_DIFF_3_N = pot_rel_1;
    assign HDR2_22_SM_10_N = 1'b1; //Pin 9: permanently powered
    assign KBCODE_bus = {3'd0, KBCODE_4_1, 1'd0};
	 
	 
    
    /* Begin testing assignments */
    assign {GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = keycode_latch;//KBCODE_bus[4:1];
    assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3} = {TRIG0_bus, HDR2_18_DIFF_2_N, TRIG2_bus, TRIG3_bus};
    assign POTGO = center_pressed ? 8'h00 : 8'hFF;
    assign GRACTL[2] = GPIO_DIP_SW1;
    assign SKCTL[3:0] = {GPIO_DIP_SW4, GPIO_DIP_SW3, GPIO_DIP_SW2};
    /* End testing assignments */
    
    clockDivider #(1800) out15(CLK_27MHZ_FPGA,o2);
    
    POKEY_controller_interface pokey_ctrl_interface_mod (.key_scan_L(key_scan_L), .control_input({control_input_side_but, control_input_pot_scan, control_input_4_1}), .control_output(control_output_8_5), .kr1_L(kr1_L), .kr2_L(), .pot_scan_2(pot_scan_2));
    
    POKEY pokey_mod(.o2(o2), .cs0_L(), .cs1(), .rw_ctrl(), .pot_scan(pot_scan), .kr1_L(kr1_L), .kr2_L(), .addr_bus(addr_bus), .sel(GPIO_SW_E), .POTGO(POTGO), .side_but(control_input_side_but), .key_scan_L(key_scan_L), .irq_L(), .audio_out(), .pot_rel_0(pot_rel_0), .pot_rel_1(pot_rel_1), .compare_latch(compare_latch), .keycode_latch(keycode_latch), .key_depr(key_depr), .bin_ctr_pot(bin_ctr_pot), .POT0(POT0_bus), .POT1(POT1_bus), .ALLPOT(ALLPOT_bus), .bottom_latch(), .data_bus(out), .bclk());

    //add new module to handle latching of trigger buttons for trig0
    trig_latch trig_latch_mod_0 (.side_but(control_input_side_but), .bottom_latch(trig0_latch));

    /* Need to sort out: SKCTL, GRACTL, how that affects TRIG0-3 */

    //latched, unlatched behavior
    
    mux_2 trig0mux ({trig0_latch,HDR2_20_DIFF_2_P}, GRACTL[2], TRIG0_bus);
    //mux_2 trig1mux ({}, GRACTL[2], TRIG1_bus);
    // mux_2 trig2mux ({}, GRACTL[2], TRIG2_bus);
    //mux_2 trig3mux ({}, GRACTL[2], TRIG3_bus);
    
    /* Chipscope stuff */
    clockone4 clk_divide_mod3(.inClk(CLK_27MHZ_FPGA),.outClk(cs_clk1));
    
    DeBounce debounce_mod(.clk(CLK_27MHZ_FPGA), .n_reset(1'b1), .button_in(GPIO_SW_C),.DB_out(center_pressed));
    
    
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
    {key_depr,3'd0, keycode_latch}, //103:96
    bin_ctr_pot, //111:104
    POT0_bus, //119:112
    POT1_bus); //127:120
	 
	 chipscope_ila inst1(
    CONTROL1,
    cs_clk1,
    POTGO, //7:0
    GRACTL,//15:8
    SKCTL,//23:16
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
    
    /* End chipscope stuff */
    

endmodule

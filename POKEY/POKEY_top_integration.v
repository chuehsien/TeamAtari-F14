module POKEY_top_integration(CLK_27MHZ_FPGA, SKCTL, GRACTL, POTGO, HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P, HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P, HDR2_24_SM_10_P, HDR2_26_SM_11_N,

                            POT0_bus, POT1_bus, ALLPOT, TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus, HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P, HDR2_22_SM_10_N, HDR2_28_SM_11_P, HDR2_30_DIFF_3_N);

input CLK_27MHZ_FPGA;
input [7:0] SKCTL, GRACTL, POTGO;
input HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P,  HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P, HDR2_24_SM_10_P, HDR2_26_SM_11_N;


output [7:0] POT0_bus, POT1_bus, ALLPOT_bus, KBCODE_bus;
output TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus;
output HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P, HDR2_22_SM_10_N, HDR2_28_SM_11_P, HDR2_30_DIFF_3_N;




    
    
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
	(* PULLUP="yes" *) wire[3:0]control_input_4_1;
	wire[3:0]control_output_8_5;
	wire [2:0] control_input_pot_scan;
	wire [1:0] control_input_side_but;
	wire[3:0] addr_bus;
	wire [7:0] out;
    
    wire pot_rel_0, pot_rel_1;
    wire [3:0] compare_latch;
    wire [3:0] keycode_latch;
    wire key_depr;
    wire [7:0] bin_ctr_pot, POT0, POT1;

    wire trig0_latch, trig1_latch, trig2_latch, trig3_latch;


    assign pot_scan = {6'd0, pot_scan_2};
    assign control_input_4_1 = {HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P};
    assign control_input_pot_scan = {HDR2_24_SM_10_P, HDR2_26_SM_11_N,HDR2_22_SM_10_N}；
    assign control_input_side_but = {HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P};
    assign {HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P} = control_output_8_5;
    assign HDR2_28_SM_11_P = pot_rel_0;
    assign HDR2_30_DIFF_3_N = pot_rel_1;
    assign HDR2_22_SM_10_N = 1'b1; //Pin 9: permanently powered
    assign KBCODE_bus = {3'd0, keycode_latch, 1'd0};
    
    clockDivider #(1800) out15(CLK_27MHZ_FPGA,o2);
    
    POKEY_controller_interface pokey_ctrl_interface_mod (.key_scan_L(key_scan_L), .control_input({control_input_side_but, control_input_pot_scan, control_input_4_1}), .control_output(control_output_8_5), .kr1_L(kr1_L), .kr2_L(), .pot_scan_2(pot_scan_2));
    
    POKEY pokey_mod(.o2(o2), .cs0_L(), .cs1(), .rw_ctrl(), .pot_scan(pot_scan), .kr1_L(kr1_L), .kr2_L(), .addr_bus(addr_bus), .sel(GPIO_SW_E), .POTGO(POTGO), .side_but(control_input_side_but), .key_scan_L(key_scan_L), .irq_L(), .audio_out(), .pot_rel_0(pot_rel_0), .pot_rel_1(pot_rel_1), .compare_latch(compare_latch), .keycode_latch(keycode_latch), .key_depr(key_depr), .bin_ctr_pot(bin_ctr_pot), .POT0(POT0_bus), .POT1(POT1_bus), .ALLPOT(ALLPOT_bus), .bottom_latch(trig0_latch), .data_bus(out), .bclk());

    //add new module to handle latching of trigger buttons for trig0
    trig_latch trig_latch_mod_0 (.side_but(control_input_side_but), .bottom_latch(trig0_latch));

    /* Need to sort out: SKCTL, GRACTL, how that affects TRIG0-3 */

    //latched, unlatched behavior
    
    mux_2 trig0mux ({trig0_latch,HDR2_20_DIFF_2_P}, GRACTL[2], TRIG0_bus);
    //mux_2 trig1mux ({}, GRACTL[2], TRIG1_bus);
    // mux_2 trig2mux ({}, GRACTL[2], TRIG2_bus);
    //mux_2 trig3mux ({}, GRACTL[2], TRIG3_bus);

endmodule

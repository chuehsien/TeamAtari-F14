module POKEY_top_integration(SKCTL, GRACTL, POTGO, HDR...

                            POT0_bus, POT1_bus, ALLPOT, TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus, HDR...);

input [7:0] SKCTL, GRACTL, POTGO;
input HDR2_10_DIFF_0_N, HDR2_12_DIFF_0_P, HDR2_14_DIFF_1_N, HDR2_16_DIFF_1_P, HDR2_24_SM_10_P, HDR2_26_SM_11_N;


output [7:0] POT0_bus, POT1_bus, ALLPOT;
output TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus;
output HDR2_2_SM_8_N, HDR2_4_SM_8_P, HDR2_6_SM_7_N, HDR2_8_SM_7_P, HDR2_18_DIFF_2_N, HDR2_20_DIFF_2_P, HDR2_22_SM_10_N, HDR2_28_SM_11_P, HDR2_30_DIFF_3_N;



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
        HDR2_18_DIFF_2_N        Pin 14 (top side buttons)   (output)
        HDR2_20_DIFF_2_P        Pin 13 (bottom side buttons)(output)
        HDR2_22_SM_10_N         Pin 9 (driving Pot current) (output) 
        HDR2_24_SM_10_P         Pin 11 (Up/Down Pot)        (input)
        HDR2_26_SM_11_N         Pin 10 (Left/Right Pot)     (input)
        HDR2_28_SM_11_P         POT0 Release (Up/Down)      (output)
        HDR2_30_DIFF_3_N        POT1 Release (Left/Right)   (output)
        HDR2_32_DIFF_3_P  

    */


















endmodule

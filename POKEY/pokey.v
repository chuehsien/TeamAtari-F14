/* 
 *  Top module for POKEY chip 
 *  Created: 19 Oct 2014
 *
 */
 
`include "IOControl.v"

module POKEY (o2, cs0_L, cs1, rw_ctrl, pot_scan, kr1_L, kr2_L, addr_bus, sel, key_scan_L, irq_L, audio_out, pot_rel_0, pot_rel_1, compare_latch, keycode_latch, key_depr, bin_ctr_pot, POT0, POT1, data_bus, bclk);
    
    //use the pinout to decide what inputs/outputs POKEY should have 
    //need to be careful about timing issues especially when polling..
    
    input o2; //phase 2 clock

    input cs0_L, cs1, rw_ctrl; //chip select and R/W control

    input [7:0] pot_scan; //potentiometer scan

    input kr1_L, kr2_L; //indicates the value of key being pressed

    input [3:0] addr_bus; //what is this addr_bus for? the place in mem to write to/read from
    input sel;
    
    // output oclk; //serial output clock
    output [3:0] key_scan_L; //0 - 15, which key do we want to scan? BINARY. 
    output irq_L; //interrupt request
    output audio_out; //for audio generation chip
	 output pot_rel_0, pot_rel_1;
	 output [3:0] compare_latch;
	 output [3:0] keycode_latch;
	 output key_depr;
	 output [7:0] bin_ctr_pot, POT0, POT1;
    
    inout [7:0] data_bus; //keycode latch values are output here too
    inout bclk;//bidirection clock
	 
	 //wire o2, cs0_L, cs1, rw_ctrl;
	 //wire 

    
    
    IOControl iocontrol_mod(.o2(o2), .pot_scan(pot_scan), .kr1_L(kr1_L), .kr2_L(kr2_L), .addr_bus(addr_bus), .sel(sel), .key_scan_L(key_scan_L), .data_out(data_bus), .pot_rel_0(pot_rel_0), .pot_rel_1(pot_rel_1), .compare_latch(compare_latch), .keycode_latch(keycode_latch), .key_depr(key_depr), .bin_ctr_pot(bin_ctr_pot), .POT0(POT0), .POT1(POT1));
	 
	 
    
    

endmodule

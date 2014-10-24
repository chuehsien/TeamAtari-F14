/* 
 *  Top module for POKEY chip 
 *  Created: 19 Oct 2014
 *
 */

module POKEY (o2, cs0_L, cs1, rw_ctrl, pot_scan, key_scan_L, kr1_L, kr2_L, addr_bus, irq_L, audio_out, data_bus, bclk);
    
    //use the pinout to decide what inputs/outputs POKEY should have 
    //need to be careful about timing issues especially when polling..
    
    input o2; //phase 2 clock

    input cs0_L, cs1, rw_ctrl; //chip select and R/W control

    input [7:0] pot_scan; //potentiometer scan

    input kr1_L, kr2_L; //indicates the value of key being pressed

    input [3:0] addr_bus; //what is this addr_bus for? the place in mem to write to/read from
    
    // output oclk; //serial output clock
    output [5:0] key_scan_L; //0 - 63, which key do we want to scan? BINARY. 
    output irq_L; //interrupt request
    output audio_out; //for audio generation chip
    
    inout [7:0] data_bus; //keycode latch values are output here too
    inout bclk //bidirection clock
    
    IOControl iocontrol_mod(o2, pot_scan, kr1_L, kr2_L, addr_bus, key_scan_L, data_out);
    
    

endmodule

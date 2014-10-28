/*  Module for I/O control portion of POKEY
 *  Created: 19 Oct 2014 (bhong)
 *  
 */
 
//`define NUMLINES 228

`include "muxLib.v"

module IOControl (o2, pot_scan, kr1_L, kr2_L, addr_bus, sel, key_scan_L, data_out, pot_rel_0, pot_rel_1, compare_latch);
    // key debounce needs FSM?
    // key matrix formed by K0-K5, kr1 reads whether value high or not.
    //parameter NUM_LINES = 228;
    
    input o2;
    input [7:0] pot_scan; //when pot_scan becomes 1, capture time! 
    input kr1_L, kr2_L;
    input [3:0] addr_bus;
    input sel;
    
    output [3:0] key_scan_L; //decide which of the 64 keys to be decoded, decodes 0-63 keys
    output [7:0] data_out; //to output the value of the key that was pressed.
	 output pot_rel_0, pot_rel_1;
	 output [3:0] compare_latch; 

    
    
    wire [3:0] key_scan_L;
    
    /* Key Scan latches */
    reg [3:0] bin_ctr_key; //15-0
    integer ctr_key = 0;
    reg [3:0] compare_latch = 4'd0;
    reg [3:0] keycode_latch;
	 reg key_depr;
    
    
    /* Potentiometer latches */
    reg [7:0] bin_ctr_pot;
    integer ctr_pot = 0; 
    reg [7:0] POT0, POT1, POT2, POT3, POT4, POT5, POT6, POT7;
    reg [7:0] pot_scan_reg;
    reg [7:0] ALLPOT, POTGO;
    reg pot_rel_0_reg, pot_rel_1_reg;
    integer i;
    
    
    
    //need to use FSM to control which states we are in, or actually not really... need FSM to control debounce (to be added later)
    
    /* 
     *  Potentiometer Description 
     *  
     *  8 pot inputs (Analog to Digital converters)(from the joystick controller)
     *  each input also has a drop transistor (to pull to 0? - can be turned on or off from software)  
     *  What do the POT* registers/memory addresses capture? ctr value from bin_ctr
     *  "Each input has 8-bit timer, counting time when each TV line is being displayed" ???
     *  Atari paddle values range from 0 to 228 (although max is 244)
     *  Binary counter that counts from 0 to 228 (increment once per line)
     *  when each line reaches logic 1 (i.e. enough current flowing through?)
     since cap is charging up w time, and we are changing the resistance in the POT
     *  value of the counter is latched into the corresponding latches (POT*?)
     *  
     *  Paddle Reading Process:
     *  1) Write to POTGO - resets POT* values to 0, ALLPOT value to $FF, discharge pot read capacitors (dump the charge in the caps via dump transistors) (we are charging the capacitors?)
     
     
     */
     
     /* Note: ALLPOT not implemented yet caa 21Oct2014 */
     
     initial begin //clear EVERYTHING
        bin_ctr_key = 4'd0;
        bin_ctr_pot = 8'd0;  
        POT0 <= 8'd0;
        POT1 <= 8'd0;
        POT2 <= 8'd0;
        POT3 <= 8'd0;
        POT4 <= 8'd0;
        POT5 <= 8'd0;
        POT6 <= 8'd0;
        POT7 <= 8'd0;
		  pot_rel_0_reg <= 1'd0; //turn off transistor0
		  pot_rel_1_reg <= 1'd0; //turn off transistor1
     end
     
     assign key_scan_L = ~bin_ctr_key;
     assign data_out = sel ? POT0 : {4'd0, keycode_latch};
	  assign pot_rel_0 = pot_rel_0_reg;
	  assign pot_rel_1 = pot_rel_1_reg;
     
     always @ (posedge o2) begin
     
        /* Keyboard Scan Code */
        
        //keep this permanently enabled
        
        //initialize the counter, starting counting up, check kr1_L for value
        //at certain line values, check kr2_L for value also
        //don't include debounce yet. include debounce? LATER. 
        
        if ((kr1_L == 1'd0) begin
		  
			if (key_depr == 1'b0))begin //key has not been depressed, first time kr1_L went low
				compare_latch <= bin_ctr_key;
				key_depr <= 1'b1;
			end
			else begin //key depressed has been noted, and the key is still being depressed
				keycode_latch <= compare_latch; //ready for confirmation to the CPU
				
			end
			
			end
        if (bin_ctr_key < 4'd15) bin_ctr_key <= bin_ctr_key + 1; //increment the counter
        else bin_ctr_key <= 4'd0; //reset
        
        

        
        /* Potentiometer Code */
        pot_scan_reg <= pot_scan; //may need to put this value in ALLPOT also
	
        
        if (addr_bus != 4'h0) begin //we need to start over again
				POTGO <= 8'h00;
            bin_ctr_pot <= 8'd0;
            POT0 <= 8'd0;
            POT1 <= 8'd0;
            POT2 <= 8'd0;
            POT3 <= 8'd0;
            POT4 <= 8'd0;
            POT5 <= 8'd0;
            POT6 <= 8'd0;
            POT7 <= 8'd0;
            pot_scan_reg <= 8'd0; //clear the "lines"
            ctr_pot = 0; //reset the pot counter
				pot_rel_0_reg <= 1'd0; //turn off transistor0
				pot_rel_1_reg <= 1'd0; //turn off transistor1
        end
        else if (ctr_pot < 228) begin
            //we are still in the cycle
         
            if ((pot_scan[0] == 1) && (POT0 == 8'd0)) POT0 <= bin_ctr_pot;
            if ((pot_scan[1] == 1) && (POT1 == 8'd0)) POT1 <= bin_ctr_pot;
            if ((pot_scan[2] == 1) && (POT2 == 8'd0)) POT2 <= bin_ctr_pot;
            if ((pot_scan[3] == 1) && (POT3 == 8'd0)) POT3 <= bin_ctr_pot;
            if ((pot_scan[4] == 1) && (POT4 == 8'd0)) POT4 <= bin_ctr_pot;
            if ((pot_scan[5] == 1) && (POT5 == 8'd0)) POT5 <= bin_ctr_pot;
            if ((pot_scan[6] == 1) && (POT6 == 8'd0)) POT6 <= bin_ctr_pot;
            if ((pot_scan[7] == 1) && (POT7 == 8'd0)) POT7 <= bin_ctr_pot;
            
            ctr_pot = ctr_pot + 1; //NB: ctr supposed to increment once per line
            bin_ctr_pot <= bin_ctr_pot + 1;
        end 
        else begin //this means our counter went past 228
            ctr_pot = 0; //reset the pot counter
            bin_ctr_pot <= 8'd0;
            pot_scan_reg <= 8'd0; //clear the "lines"
				pot_rel_0_reg <= 1'd1; //turn on transistor0 to clear the cap
				pot_rel_1_reg <= 1'd1; //turn on transistor1 to clear the cap
        end
        
     end
    
    


endmodule




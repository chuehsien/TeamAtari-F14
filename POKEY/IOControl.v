/*  Module for I/O control portion of POKEY
 *  Created: 19 Oct 2014 (bhong)
 *  
 */
 
//`define NUMLINES 228

`include "muxLib.v"

module IOControl (o2, pot_scan, kr1_L, kr2_L, addr_bus, sel, POTGO, side_but, key_scan_L, data_out, pot_rel_0, pot_rel_1, compare_latch, keycode_latch, key_depr, bin_ctr_pot, POT0, POT1, ALLPOT, bottom_latch);
    // key debounce needs FSM?
    // key matrix formed by K0-K5, kr1 reads whether value high or not.
    //parameter NUM_LINES = 228;
    
    /* Need to implement: 
        - output to wires: KBCODE, POT0, POT1, ALLPOT
        - 
    */
    
    input o2;
    input [7:0] pot_scan; //when pot_scan becomes 1, capture time! 
    input kr1_L, kr2_L;
    input [3:0] addr_bus;
    input sel;
    input [7:0] POTGO;
    input [1:0] side_but;
    
    output [3:0] key_scan_L; //decide which of the 64 keys to be decoded, decodes 0-63 keys
    output [7:0] data_out; //to output the value of the key that was pressed.
	 output pot_rel_0, pot_rel_1;
	 output [3:0] compare_latch; 
	 output [3:0] keycode_latch;
	 output key_depr;
	 output [7:0] bin_ctr_pot;
	 output [7:0] POT0, POT1;
     output [7:0] ALLPOT;
     output bottom_latch;
	 

    
    
    wire [3:0] key_scan_L;
    
    /* Key Scan latches */
    reg [3:0] bin_ctr_key; //15-0
    integer ctr_key = 0;
    reg [3:0] compare_latch;
    reg [3:0] keycode_latch;
	 reg key_depr;
    
    
    /* Potentiometer latches */
    reg [7:0] bin_ctr_pot;
    integer ctr_pot = 0; 
    reg [7:0] POT0, POT1;
    reg [7:0] pot_scan_reg;
    reg [7:0] ALLPOT_reg, POTGO_reg;
    reg pot_rel_0_reg, pot_rel_1_reg, bottom_latch_reg;
    integer i;
    
    assign ALLPOT = ALLPOT_reg;
    assign key_scan_L = ~bin_ctr_key;
    assign data_out = sel ? POT0 : {4'd0, keycode_latch};
    assign pot_rel_0 = pot_rel_0_reg;
    assign pot_rel_1 = pot_rel_1_reg;
    assign bottom_latch = bottom_latch_reg;
    
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
//        POT2 <= 8'd0;
//        POT3 <= 8'd0;
//        POT4 <= 8'd0;
//        POT5 <= 8'd0;
//        POT6 <= 8'd0;
//        POT7 <= 8'd0;
		  pot_rel_0_reg <= 1'd0; //turn off transistor0
		  pot_rel_1_reg <= 1'd0; //turn off transistor1
		  
		  //keyscan stuff
		  keycode_latch <= 4'd0;
		  compare_latch <= 4'd0;
          
          
          //trigger stuff
          bottom_latch_reg <= 1'd0;
     end
     
     
     
     always @ (posedge o2) begin
     
        /* Keyboard Scan Code */
        
        //keep this permanently enabled
        
        //initialize the counter, starting counting up, check kr1_L for value
        //at certain line values, check kr2_L for value also
        //don't include debounce yet. include debounce? LATER. 
        /* if (the bit is 1) begin
            bottom_latch_reg <= side_but[0];
        end else begin
            //nothing changes
        
        end */
        
        if (kr1_L == 1'd0) begin // there is a button being pressed
		  
			if (key_depr == 1'b0) begin //key has not been depressed, first time kr1_L went low
				compare_latch <= bin_ctr_key;
				key_depr <= 1'b1;
			end
			else if ((keycode_latch != compare_latch) && (compare_latch == bin_ctr_key)) begin //key depressed has been noted, and the key is still being depressed, but value not recorded yet
				keycode_latch <= compare_latch; //ready for confirmation to the CPU, value in keycode_latch
                //NOTE: if more than one button pressed, will not record the updated one
					 //i THINK it will just not register anything if there are two buttons pressed at same time
			end
			//else begin //value has already been recorded but the button is still depressed
                //continue;
			//end
			
        end
        else if (compare_latch == bin_ctr_key) begin //kr1_L is high, no buttons being pressed and we are checking the same button
            if ((key_depr == 1'b1) && (keycode_latch != 4'd0)) begin //not pressed anymore but had been previously and value already recorded
                keycode_latch <= 4'd0; //clear the keycode_latch
                compare_latch <= 4'd0; //clear the compare_latch
                key_depr <= 1'b0; //clear the status that key had been earlier pressed
            end
            else if (key_depr == 1'b1) begin //key had been depressed earlier, but now not pressed anymore and was only pressed for one cycle: it's debouncing
                key_depr <= 1'b0;     
				//keycode_latch <= 4'd0; //clear the keycode_latch
                //compare_latch <= 4'd0; //clear the compare_latch					 
            end
			else if (key_depr == 1'b0) begin
				keycode_latch <= 4'd0; //clear the keycode_latch
				compare_latch <= 4'd0; //clear the compare_latch		
			end
            //else begin
                //continue; //no key earlier depressed, just continue
            //end
        end
	    //trying this
	    else begin
			keycode_latch <= 4'd0; //clear the keycode_latch
			compare_latch <= 4'd0; //clear the compare_latch		
	    end
	    //end trial
            
            
        /*Actual Scanning Process*/
        if (bin_ctr_key < 4'd15) bin_ctr_key <= bin_ctr_key + 1; //increment the counter
        else bin_ctr_key <= 4'd0; //reset
        
        

        
        /* Potentiometer Code */
        pot_scan_reg <= pot_scan; //may need to put this value in ALLPOT also
	
        
        if (POTGO == 8'h0) begin //we need to start over again
            POTGO_reg <= 8'h00;
            bin_ctr_pot <= 8'd0;
            POT0 <= 8'd0;
            POT1 <= 8'd0;
//            POT2 <= 8'd0;
//            POT3 <= 8'd0;
//            POT4 <= 8'd0;
//            POT5 <= 8'd0;
//            POT6 <= 8'd0;
//            POT7 <= 8'd0;
            pot_scan_reg <= 8'd0; //clear the "lines"
            ctr_pot = 0; //reset the pot counter
				pot_rel_0_reg <= 1'd0; //turn off transistor0
				pot_rel_1_reg <= 1'd0; //turn off transistor1
        end
        else if (ctr_pot < 228) begin
            //we are still in the cycle
         
            if ((pot_scan[0] == 1) && (POT0 == 8'd0)) begin 
                POT0 <= bin_ctr_pot;
                ALLPOT_reg[0] <= 1;
            end
            if ((pot_scan[1] == 1) && (POT1 == 8'd0)) begin 
                POT1 <= bin_ctr_pot;
                ALLPOT_reg[1] <= 1;
            end
//            if ((pot_scan[2] == 1) && (POT2 == 8'd0)) POT2 <= bin_ctr_pot;
//            if ((pot_scan[3] == 1) && (POT3 == 8'd0)) POT3 <= bin_ctr_pot;
//            if ((pot_scan[4] == 1) && (POT4 == 8'd0)) POT4 <= bin_ctr_pot;
//            if ((pot_scan[5] == 1) && (POT5 == 8'd0)) POT5 <= bin_ctr_pot;
//            if ((pot_scan[6] == 1) && (POT6 == 8'd0)) POT6 <= bin_ctr_pot;
//            if ((pot_scan[7] == 1) && (POT7 == 8'd0)) POT7 <= bin_ctr_pot;
            
            ctr_pot = ctr_pot + 1; //NB: ctr supposed to increment once per line
            bin_ctr_pot <= bin_ctr_pot + 1;
        end 
        else begin //this means our counter went past 228
            ctr_pot = 0; //reset the pot counter
            bin_ctr_pot <= 8'd0;
            pot_scan_reg <= 8'd0; //clear the "lines"
            pot_rel_0_reg <= 1'd1; //turn on transistor0 to clear the cap
            pot_rel_1_reg <= 1'd1; //turn on transistor1 to clear the cap
            //lock in the max value in the POT* registers
            POT0 <= 8'd228;
            POT1 <= 8'd228;
        end
        
     end
    
    


endmodule




module IOControl (rst,clk15,clk179, SKCTL, POTGO, kr1_L, pot_scan_in,
                    key_scan_L,keycode_latch,POT0, POT1, POT2, POT3, ALLPOT,pot_rel,potDone);

    input rst;
    input clk15,clk179;
    input [7:0] SKCTL;
    input POTGO;
    input kr1_L;
    input [3:0] pot_scan_in;
    
    output [3:0] key_scan_L; //is decoded by controlinterface into switch matrix in/outs
    output reg [3:0] keycode_latch = 4'd0;

	output reg [7:0] POT0, POT1, POT2, POT3 = 8'd0;
    output reg [7:0] ALLPOT = 8'hff;
	output reg pot_rel = 1'd1;
    output reg potDone = 1'b0;

    /* ======================== keyboard scanning ==========================*/

    reg [3:0] key_scan_ctr = 4'd0;
    reg [3:0] compare_latch = 4'd0;
	reg key_depr = 1'd0;
    assign key_scan_L = ~key_scan_ctr;

    always @ (posedge clk179) begin

        if(SKCTL[1]) begin 
            if (kr1_L == 1'd0) begin // there is a button being pressed
		      
			    if (key_depr == 1'b0) begin 
					    //first time in
					    keycode_latch <= keycode_latch;
					    compare_latch <= key_scan_ctr;
					    key_depr <= 1'b1;
			    end
			    else if (key_depr) begin
					    //2nd time in
					
				    if (compare_latch == key_scan_ctr) begin
						    //same key
					    keycode_latch <= compare_latch;
					    compare_latch <= compare_latch;
					    key_depr <= 1'b1;
				    end
				    else begin
					    //different key, do nothing
					    keycode_latch <= keycode_latch;
					    compare_latch <= compare_latch;
					    key_depr <= key_depr;
				    end
	            end
				
		    end
		    else begin
			
			    //no button pressed
			    if (compare_latch == key_scan_ctr) begin
				    //went first time in, entering 2nd time
				    //button got released
				    compare_latch <= 4'd0;
				    keycode_latch <= 4'd0;
				    key_depr <= 1'b0;
					
			    end
				
				
			    else begin
				    //went first time in, now cycling other keys
				    //ignore
				    compare_latch <= compare_latch;
				    keycode_latch <= keycode_latch;
				    key_depr <= key_depr;
			    end
			
		    end
           
            if (key_scan_ctr < 4'd15) key_scan_ctr <= key_scan_ctr + 1;
            else key_scan_ctr <= 4'd0; 
            
        end
    end



    /* ======================== pot scanning ==========================*/

	reg [7:0] ctr_pot = 8'd0;
    wire potEn;
    FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) potStrobe (
      .Q(potEn),      // 1-bit Data output
      .C(POTGO),      // 1-bit Clock input
      .CE(1'b1),    // 1-bit Clock enable input
      .CLR((ctr_pot==8'd230)),  // 1-bit Asynchronous clear input
      .D(1'b1)       // 1-bit Data input
   );


    wire potClock,potClock_b;
    assign potClock_b = SKCTL[2] ? clk179 : clk15;
    BUFG makepotclock(potClock,potClock_b);

    reg selfRst = 1'b0;
    
   /* Potentiometer Code */
    always @ (posedge potClock) begin  
     

        if (rst | (~potEn) | selfRst) begin //we need to start over again
            potDone <= 1'b0;
            POT0 <= 8'd0;
            POT1 <= 8'd0;
            POT2 <= 8'd0;
            POT3 <= 8'd0;
            ALLPOT <= 8'hff;
            ctr_pot <= 0; //reset the pot counter
		    pot_rel <= 1'd1; //dump transistors
            
            selfRst <= 1'b0;
        end
        else begin
            if (potEn) pot_rel <= 1'b0;    
            
            else if (potEn & (ctr_pot < 8'd229)) begin

                ctr_pot <= ctr_pot + 1; 

                if ((pot_scan_in[0] == 1 | (ctr_pot == 8'd228)) & (POT0 == 8'd0)) begin 
                    POT0 <= ctr_pot;
                    ALLPOT[0] <= 0;
                end
                if ((pot_scan_in[1] == 1 | (ctr_pot == 8'd228)) & (POT1 == 8'd0)) begin 
                    POT1 <= ctr_pot;
                    ALLPOT[1] <= 0;
                end
                if ((pot_scan_in[2] == 1 | (ctr_pot == 8'd228)) & (POT2 == 8'd0)) begin 
                    POT2 <= ctr_pot;
                    ALLPOT[2] <= 0;
                end
                if ((pot_scan_in[3] == 1 | (ctr_pot == 8'd228)) & (POT3 == 8'd0)) begin 
                    POT3 <= ctr_pot;
                    ALLPOT[3] <= 0;
                end
                
                if ((ctr_pot == 8'd228) | (ALLPOT[3:0] == 4'h0)) potDone <= 1'b1;

            end 
            else begin //reached 229, cpu didnt disable potEn
                selfRst <= 1'b1;
                
            end
        end
    
     end
    
    


endmodule





`define state_IDLE 2'b00
`define state_LATCHED 2'b01
`define state_CONFIRM 2'b10

`define pot_IDLE 1'b0;
`define pot_SCAN 1'b1;




module IOControl (rst_latch,state,rst,clk15,clk179,clk64, SKCTL, POTGO_strobe, kr1_L, pot_scan_in,
                    key_scan_L,keycode_latch,POT0, POT1, POT2, POT3, ALLPOT,pot_rel);
//output potEn0,potClock;
//output [7:0] timer;  
		output rst_latch;
	  output [1:0] state;
    input rst;
    input clk15,clk179,clk64;
    input [7:0] SKCTL;
    input POTGO_strobe;
    input kr1_L;
    input [3:0] pot_scan_in;
    
    output [3:0] key_scan_L; //is decoded by controlinterface into switch matrix in/outs
    output reg [3:0] keycode_latch = 4'd0;

	output [7:0] POT0, POT1, POT2, POT3;
   output [7:0] ALLPOT;
	output pot_rel;

    /* ======================== keyboard scanning ==========================*/
    reg state,next_state = 1'b0;
    reg [3:0] key_scan_ctr = 4'd0;
    reg [3:0] compare_latch = 4'd0;
    assign key_scan_L = ~key_scan_ctr;

    reg rst_latch, load_latch, confirm_latch = 1'b0;
    
    //update state on posedge
    always @ (posedge clk64) begin
        if (rst) begin
          state <= `state_IDLE;
        end
        else begin
          state <= next_state;
        end
    end    
    
    //output takes effect
    always @ (posedge clk64) begin
      if (rst_latch) begin
        compare_latch <= 4'd0;
        keycode_latch <= 4'd0;
      end
      else if (load_latch) begin
        compare_latch <= key_scan_ctr;
        keycode_latch <= keycode_latch;
      end
      else if (confirm_latch) begin
        keycode_latch <= compare_latch;
        compare_latch <= compare_latch;
      end
      else begin
        compare_latch <= compare_latch;
        keycode_latch <= keycode_latch;
      end
    end
    //combinational logic to determine control signals
    always @ (SKCTL[1] or kr1_L or key_scan_ctr or compare_latch or state) begin

      case (state) 

      `state_IDLE: begin
        if (~SKCTL[1]) begin
          next_state = `state_IDLE;
          rst_latch = 1'b1;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
        
        else if (~kr1_L) begin
          next_state = `state_LATCHED;
          rst_latch = 1'b0;
          load_latch = 1'b1;
          confirm_latch = 1'b0;
        end
        
        else begin
          next_state = `state_IDLE;
          rst_latch = 1'b1;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
      end
      
      `state_LATCHED: begin
        if (~SKCTL[1]) begin
          next_state = `state_IDLE;
          rst_latch = 1'b1;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
        else if (key_scan_ctr != compare_latch) begin
          next_state = `state_LATCHED;
          rst_latch = 1'b0;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
        else begin
          if (~kr1_L) begin
            next_state = `state_CONFIRM;
            rst_latch = 1'b0;
            load_latch = 1'b0;
            confirm_latch = 1'b1;
          end
          else begin
            next_state = `state_IDLE;
            rst_latch = 1'b1;
            load_latch = 1'b0;
            confirm_latch = 1'b0;
          end
        end
      end

        
      
      `state_CONFIRM: begin
   /*     if (~SKCTL[1]) begin
          next_state = `state_IDLE;
          rst_latch = 1'b1;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
  */
        if (kr1_L & key_scan_ctr == compare_latch) begin
          // key let go
          next_state = `state_IDLE;
          rst_latch = 1'b1;
          load_latch = 1'b0;
          confirm_latch = 1'b0;
        end
      
        else begin //stay here until first key let go
          next_state = `state_CONFIRM;
          rst_latch = 1'b0;
          load_latch=1'b0;
          confirm_latch = 1'b0;
        end
      
      
      end
      
      
      
      endcase
      
    end

      
    always @ (negedge clk64) begin
        key_scan_ctr <= key_scan_ctr + 8'd1;
    end

    /* ======================== pot scanning ==========================*/



    wire potClock;
    assign potClock = SKCTL[2] ? clk179 : clk15;

    wire POTGO_ACK;
    wire potEn0,potEn1,potEn2,potEn3;

    FDCE #(.INIT(1'b0)) strobepot0(.Q(potEn0), .C(POTGO_strobe),.CE(1'b1), .CLR(POTGO_ACK), .D(1'b1));
    FDCE #(.INIT(1'b0)) strobepot1(.Q(potEn1), .C(POTGO_strobe),.CE(1'b1), .CLR(POTGO_ACK), .D(1'b1));
    FDCE #(.INIT(1'b0)) strobepot2(.Q(potEn2), .C(POTGO_strobe),.CE(1'b1), .CLR(POTGO_ACK), .D(1'b1));
    FDCE #(.INIT(1'b0)) strobepot3(.Q(potEn3), .C(POTGO_strobe),.CE(1'b1), .CLR(POTGO_ACK), .D(1'b1));


    wire potstate;
    wire pot_rdy0,pot_rdy1,pot_rdy2,pot_rdy3;

    potScanFSM  pot0(potClock,rst,pot_scan_in[0],potEn0,POT0,pot_rdy0,potstate,);
    potScanFSM  pot1(potClock,rst,pot_scan_in[1],potEn1,POT1,pot_rdy1,,);
    potScanFSM  pot2(potClock,rst,pot_scan_in[2],potEn2,POT2,pot_rdy2,,);
    potScanFSM  pot3(potClock,rst,pot_scan_in[3],potEn3,POT3,pot_rdy3,,);  

    wire [3:0] nALLPOT;
   

    FDCE #(.INIT(1'b0)) pot0rdy(.Q(nALLPOT[0]), .C(pot_rdy0),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot1rdy(.Q(nALLPOT[1]), .C(pot_rdy1),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot2rdy(.Q(nALLPOT[2]), .C(pot_rdy2),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot3rdy(.Q(nALLPOT[3]), .C(pot_rdy3),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    assign ALLPOT = ~nALLPOT;
    assign pot_rel = (potstate == 1'd0);
    assign POTGO_ACK = (potstate == 1'd1);

/*


	always @ (posedge clk15) begin
	    

        pot_scan_reg <= pot_scan_in; //may need to put this value in ALLPOT also
			
        
        if (~POTGO) begin //we need to start over again
   
            ctr_pot <= 8'd0;
            POT0 <= 8'd0;
            POT1 <= 8'd0;
            potDone <= 1'b0;
            pot_scan_reg <= 8'd0; //clear the "lines"
			pot_rel <= 1'd0; //turn off transistor0
				
        end
        else if (ctr_pot < 8'd228) begin
            //we are still in the cycle
				ctr_pot <= ctr_pot + 1;
            potDone <= 1'b0;
            if ((pot_scan_in[0] == 1) && (POT0 == 8'd0)) begin 
                POT0 <= ctr_pot;
                ALLPOT[0] <= 0;
            end
            if ((pot_scan_in[1] == 1) && (POT1 == 8'd0)) begin 
                POT1 <= ctr_pot;
                ALLPOT[1] <= 0;
            end
         
        end 
        else begin //this means our counter went past 228
            potDone <= 1'b1;
            ctr_pot <= 8'd0;
            pot_scan_reg <= 8'd0; //clear the "lines"
            pot_rel <= 1'd1; //turn on transistor0 to clear the cap
				
        end
        
     end
    


	*/

	
	
	
	/*
    always @ (posedge clk15) begin  
     

        if (~POTGO | delay < `DELAY) begin //we need to start over again
				delay <= delay + 1;
            potDone <= 1'b0;
            POT0 <= 8'd0;
            POT1 <= 8'd0;
            POT2 <= 8'd0;
            POT3 <= 8'd0;
            ALLPOT <= 8'hff;
				pot_rel <= 1'd1; //dump transistors
            
            selfRst <= 1'b0;
        end
        else begin
            pot_rel <= 1'b0;    
				delay <= 4'd0;
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
    
     end
    
    
*/

endmodule




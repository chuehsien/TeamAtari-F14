
`define state_IDLE 2'b00
`define state_LATCHED 2'b01
`define state_CONFIRM 2'b10

`define pot_IDLE 1'b0;
`define pot_SCAN 1'b1;




module IOControl (rst_latch,state,rst,clk15,clk179,clk64, SKCTL, POTGO_strobe, kr1_L, pot_scan_in,
                    key_scan_L,keycode_latch,POT0, POT1, POT2, POT3, ALLPOT,pot_rel);

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

    wire [2:0] potstate;
    wire pot_rdy0,pot_rdy1,pot_rdy2,pot_rdy3;

    potScanFSM  pot0(.clk(potClock),.rst(rst),.pot_in(pot_scan_in[0]),.POTGO(potEn0),.POTOUT(POT0),.pot_rdy(pot_rdy0),.pot_state(potstate),.rel_pots(pot_rel));
    potScanFSM  pot1(.clk(potClock),.rst(rst),.pot_in(pot_scan_in[1]),.POTGO(potEn1),.POTOUT(POT1),.pot_rdy(pot_rdy1));
    potScanFSM  pot2(.clk(potClock),.rst(rst),.pot_in(pot_scan_in[2]),.POTGO(potEn2),.POTOUT(POT2),.pot_rdy(pot_rdy2));
    potScanFSM  pot3(.clk(potClock),.rst(rst),.pot_in(pot_scan_in[3]),.POTGO(potEn3),.POTOUT(POT3),.pot_rdy(pot_rdy3));  

    wire [3:0] nALLPOT;
   

    FDCE #(.INIT(1'b0)) pot0rdy(.Q(nALLPOT[0]), .C(pot_rdy0),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot1rdy(.Q(nALLPOT[1]), .C(pot_rdy1),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot2rdy(.Q(nALLPOT[2]), .C(pot_rdy2),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    FDCE #(.INIT(1'b0)) pot3rdy(.Q(nALLPOT[3]), .C(pot_rdy3),.CE(1'b1), .CLR(POTGO_strobe), .D(1'b1)); 
    assign ALLPOT = ~nALLPOT;
    assign POTGO_ACK = (potstate == 3'd3);


endmodule




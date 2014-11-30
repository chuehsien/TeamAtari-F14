`define pot_IDLE 3'd0
`define pot_SCAN 3'd1
`define pot_rel1 3'd2
`define pot_rel2 3'd3
`define pot_rel3 3'd4
`define pot_rel4 3'd5

`define DELAY 4'd12
module potScanFSM(clk,rst,pot_in,POTGO,POTOUT,pot_rdy,pot_state,rel_pots);
 
	 input clk, rst, pot_in, POTGO;
    output reg [7:0] POTOUT = 8'd0;
    output pot_rdy;
	 output [2:0] pot_state;
    output rel_pots;

	reg [2:0] pot_state,next_pot_state = `pot_IDLE;
    reg pot_rdy = 1'b0;
    reg run_timer = 1'b0;
    reg rst_timer = 1'b0;
    
    reg [7:0] timer = 8'd0;
    

    wire rel_pots;
    assign rel_pots = (pot_state == `pot_rel1) | (pot_state == `pot_rel2) | (pot_state == `pot_rel3) | (pot_state == `pot_rel4);

   always @ (posedge clk) begin
        if (rst) begin
            pot_state <= `pot_IDLE;
        end    
        else begin
            pot_state <= next_pot_state;
        end
    end
    
    always @ (posedge clk) begin

        if (pot_rdy) begin
           POTOUT <= timer; 
        end

        if (rst_timer) begin
            timer <= 8'd0;
        end

        else if (run_timer) begin
           timer <= timer + 8'd1;
        end

    end



    always @ (pot_in or POTGO or timer) begin
    
        case (pot_state)
        
        `pot_IDLE: begin
            if (POTGO) begin
                
                next_pot_state = `pot_rel1;
                run_timer = 1'b0;
                rst_timer = 1'b1;
                pot_rdy = 1'b0;
            end

            else begin
                next_pot_state = `pot_IDLE;
                run_timer = 1'b0;
                rst_timer = 1'b1;  
                pot_rdy = 1'b0;          
            end

        end

        `pot_rel1: begin
                next_pot_state = `pot_rel2;
                run_timer = 1'b0;
                rst_timer = 1'b1;
                pot_rdy = 1'b0;
        end


        `pot_rel2: begin
                next_pot_state = `pot_SCAN;
                run_timer = 1'b0;
                rst_timer = 1'b1;
                pot_rdy = 1'b0;
        end


        `pot_SCAN: begin
            
            if ((pot_in | (timer > 8'd227))) begin
                next_pot_state = `pot_IDLE;
                run_timer = 1'b0;
                rst_timer = 1'b1;
                pot_rdy = 1'b1;
            end
            else begin  
                next_pot_state = `pot_SCAN;
                run_timer = 1'b1;
                rst_timer = 1'b0;  
                pot_rdy = 1'b0;
            end
        end
            
        default : begin
                next_pot_state = `pot_IDLE;
                run_timer = 1'b0;
                rst_timer = 1'b1;  
                pot_rdy = 1'b0;
        end

        endcase
    end




endmodule

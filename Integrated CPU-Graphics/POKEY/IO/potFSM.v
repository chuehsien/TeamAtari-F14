`define pot_IDLE 1'b0
`define pot_SCAN 1'b1
`define DELAY 4'd16
module potScanFSM(clk,rst,pot_in,POTGO,POTOUT,pot_rdy,pot_state,timer);
 
	 input clk, rst, pot_in, POTGO;
    output reg [7:0] POTOUT = 8'd0;
    output pot_rdy;
	 output [1:0] pot_state;
   	output [7:0] timer;

	reg pot_state,next_pot_state = `pot_IDLE;
    reg pot_rdy = 1'b0;
    reg run_timer = 1'b0;
    reg rst_timer = 1'b0;
    
    reg [7:0] timer = 8'd0;

   always @ (posedge clk) begin
        if (rst) begin
            pot_state <= `pot_IDLE;
        end    
        else begin
            pot_state <= next_pot_state;
        end
    end
    
    always @ (posedge clk) begin

        if (rst_timer) begin
            timer <= 8'd0;
        end

        else if (run_timer) begin
           timer <= timer + 8'd1;
        end

        if (pot_rdy) begin
           POTOUT <= timer; 
        end

    end



    always @ (pot_in or POTGO or timer) begin
    
        case (pot_state)
        
        `pot_IDLE: begin
            if (POTGO & (timer > `DELAY)) begin
                
                next_pot_state = `pot_SCAN;
                run_timer = 1'b0;
                rst_timer = 1'b1;
                pot_rdy = 1'b0;
            end
            else if (POTGO) begin
                next_pot_state = `pot_IDLE;
                run_timer = 1'b1;
                rst_timer = 1'b0;
                pot_rdy = 1'b0;                
            end
            else begin
                next_pot_state = `pot_IDLE;
                run_timer = 1'b0;
                rst_timer = 1'b1;  
                pot_rdy = 1'b0;          
            end

        end
        
        `pot_SCAN: begin
            
            if ((timer > 8'd4) & (pot_in | (timer > 8'd227))) begin
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

        endcase
    end




endmodule

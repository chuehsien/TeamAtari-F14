/* This example is an FSM that interacts with the lcd_control.v module.  
   It first sends the string "18545" to the LCD module
   It then waits for the nextString input to be asserted
   It then sends the string "ECE" to the LCD module
   It then waits forever.
 */
 
 
 module testFSM(clkFSM,
					resetFSM,
					initDone,
					writeDone,
					dataHi,dataLo,
					data, 
					writeStart);
					
	input clkFSM;
	input resetFSM;
	input initDone;
	input writeDone;
	input [3:0] dataHi,dataLo	;
	
	output [7:0]	data;
	output			writeStart;
	
	reg [7:0]		data;
	reg 		 		writeStart;
	reg [5:0] 		state,next_state;
	
	`define idle 	     6'b000000
	`define data1	     6'b000001
	`define wait1	     6'b100001
	`define data2	     6'b000010
	`define wait2	     6'b100010
	`define data3	     6'b000011
	`define wait3	     6'b100011
	`define data4	     6'b000100
	`define wait4	     6'b100100
	`define data5	     6'b000101
	`define wait5	     6'b100101
	`define data6	     6'b000110
	`define wait6	     6'b100110
	`define data7	     6'b000111
	`define wait7	     6'b100111
	`define data8	     6'b001000
	`define wait8	     6'b101000
	`define waitClear   6'b011111
	`define finish      6'b111111
	
    
    reg [7:0] asciiHi,asciiLo;
    always @ (dataHi) begin
        case (dataHi)
            4'd0 : asciiHi = 8'd48;
            4'd1 :asciiHi = 8'd49;
            4'd2 :asciiHi = 8'd50;
            4'd3 :asciiHi = 8'd51;
            4'd4 :asciiHi = 8'd52;
            4'd5 :asciiHi = 8'd53;
            4'd6 :asciiHi = 8'd54;
            4'd7 :asciiHi = 8'd55;
            4'd8:asciiHi = 8'd56;
            4'd9 :asciiHi = 8'd57;
            4'd10 :asciiHi = 8'd65;
            4'd11 :asciiHi = 8'd66;
            4'd12 :asciiHi = 8'd67;
            4'd13 :asciiHi = 8'd68;
            4'd14 :asciiHi = 8'd69;
            4'd15 :asciiHi = 8'd70;
        endcase
    
    end
    
        always @ (dataLo) begin
        case (dataLo)
            4'd0 : asciiLo = 8'd48;
            4'd1 :asciiLo = 8'd49;
            4'd2 :asciiLo = 8'd50;
            4'd3 :asciiLo = 8'd51;
            4'd4 :asciiLo = 8'd52;
            4'd5 :asciiLo = 8'd53;
            4'd6 :asciiLo = 8'd54;
            4'd7 :asciiLo = 8'd55;
            4'd8:asciiLo = 8'd56;
            4'd9 :asciiLo = 8'd57;
            4'd10 :asciiLo = 8'd65;
            4'd11 :asciiLo = 8'd66;
            4'd12 :asciiLo = 8'd67;
            4'd13 :asciiLo = 8'd68;
            4'd14 :asciiLo = 8'd69;
            4'd15 :asciiLo = 8'd70;
        endcase
    
    end
    
    
	/* first write 18545, then write ECE to LCD */
	always @ (clkFSM or state or initDone or writeDone)
		begin
			next_state <= `idle;
			data = 8'b00000000;
			writeStart = 'b0;
			case(state)
				`idle : 
					begin
						if(initDone == 1'b1) 
							next_state <= `data1;
						else
							next_state <= `idle;
					end
				`data1 :
					begin
						data = asciiHi;		//1
						writeStart = 1'b1;
						next_state <= `wait1;
					end
				`wait1 :
					begin
						data = asciiHi;
						if(writeDone == 1'b1)
							next_state <= `data2;
						else
							next_state <= `wait1;
					end
				`data2 :
					begin
						data = asciiLo;		//8
						writeStart = 1'b1;
						next_state <= `wait2;
					end
				`wait2 :
					begin
						data = asciiLo;
						if(writeDone == 1'b1)
							next_state <= `finish;
						else
							next_state <= `wait2;
					end

                    
                `finish :
                    begin
                        if (initDone == 1'b0) next_state <= `idle;
                        else next_state <= `finish;
                    end
                    
			
			endcase	
		
		end

	//registers state variables
	always @ (posedge clkFSM)
		begin
			if (resetFSM) 
				begin
					state <= `idle;			
				end
			else 
				begin
					state <= next_state;			
				end
		end // always 
					
endmodule
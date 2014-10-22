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
                    display,
					A,X,Y,
					data, 
					writeStart,clrLCD);
					
	input clkFSM;
	input resetFSM;
	input initDone;
	input writeDone;
    input display;
	input [7:0] A,X,Y;
    
	output [7:0]	data;
	output			writeStart,clrLCD;
	
	reg [7:0]		data;
	reg 		    writeStart,clrLCD;
	reg [5:0] 		state,next_state;
	
	`define idle 	    6'd0
    `define clear0      6'd1
    `define wait0       6'd2
	`define data1	    6'd3
	`define wait1	    6'd4
	`define data2	    6'd5
	`define wait2	    6'd6
	`define data3	    6'd7
	`define wait3	    6'd8
	`define data4	    6'd9
	`define wait4	    6'd10
	`define data5	    6'd11
	`define wait5	    6'd12
	`define data6	    6'd13
	`define wait6	    6'd14
	`define waitClear   6'd15
	`define finish      6'd16
	
    task toAscii;
    input [3:0] data;
    output [7:0] ascii;
    
    begin
        case (data)
            4'd0 : ascii = 8'd48;
            4'd1 :ascii = 8'd49;
            4'd2 :ascii = 8'd50;
            4'd3 :ascii = 8'd51;
            4'd4 :ascii = 8'd52;
            4'd5 :ascii = 8'd53;
            4'd6 :ascii = 8'd54;
            4'd7 :ascii = 8'd55;
            4'd8 :ascii = 8'd56;
            4'd9 :ascii = 8'd57;
            4'd10 :ascii = 8'd65;
            4'd11 :ascii = 8'd66;
            4'd12 :ascii = 8'd67;
            4'd13 :ascii = 8'd68;
            4'd14 :ascii = 8'd69;
            4'd15 :ascii = 8'd70;
        endcase
    end
    endtask

    
    
	/* first write 18545, then write ECE to LCD */
	always @ (clkFSM or state or initDone or writeDone or writeStart)
		begin
			next_state <= `idle;
			data = 8'b00000000;
			writeStart = 1'b0;
            clrLCD <= 1'b0;
			case(state)
				`idle : 
					begin
                        if (~initDone) next_state <= `idle;
                        else if (display) begin
                            next_state <= `clear0;
                            clrLCD <= 1'b1;
                        end
                        else next_state <= `idle;
					end
                    
                `clear0:
                    begin
                        clrLCD <= 1'b1;
                        if (initDone) next_state <= `data1;
                        else next_state <= `clear0;
                    end
                    
                    
				`data1 :
					begin
						toAscii(A[7:4],data);		//A_hi
						writeStart = 1'b1;
						next_state <= `wait1;
					end
				`wait1 :
					begin
						toAscii(A[7:4],data);
						if(writeDone == 1'b1)
							next_state <= `data2;
						else
							next_state <= `wait1;
					end
				`data2 :
					begin
						toAscii(A[3:0],data);		//A_lo
						writeStart = 1'b1;
						next_state <= `wait2;
					end
				`wait2 :
					begin
						toAscii(A[3:0],data);
						if(writeDone == 1'b1)
							next_state <= `data3;
						else
							next_state <= `wait2;
					end
				`data3 :
					begin
						toAscii(X[7:4],data);		//X_hi
						writeStart = 1'b1;
						next_state <= `wait3;
					end
				`wait3 :
					begin
						toAscii(X[7:4],data);
						if(writeDone == 1'b1)
							next_state <= `data4;
						else
							next_state <= `wait3;
					end
				`data4 :
					begin
						toAscii(X[3:0],data);		//X_lo
						writeStart = 1'b1;
						next_state <= `wait4;
					end
				`wait4 :
					begin
						toAscii(X[3:0],data);
						if(writeDone == 1'b1)
							next_state <= `data5;
						else
							next_state <= `wait4;
					end
				`data5 :
					begin
						toAscii(Y[7:4],data);		//Y_hi
						writeStart = 1'b1;
						next_state <= `wait5;
					end
				`wait5 :
					begin
						toAscii(Y[7:4],data);
						if(writeDone == 1'b1)
							next_state <= `data6;
						else
							next_state <= `wait5;
					end
				
				`data6 :
					begin
						toAscii(Y[3:0],data);	//Y_lo
						writeStart = 1'b1;
						next_state <= `wait6;
					end
				`wait6 :
					begin
						toAscii(Y[3:0],data);
						if(writeDone == 1'b1)
							next_state <= `finish;
						else
							next_state <= `wait6;
					end
				
				`finish :
					begin
						if (~display) next_state <= `idle;
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
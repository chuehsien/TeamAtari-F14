module lcd_top(USER_CLK, 
			   GPIO_SW_C,			   
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_W,
                GPIO_SW_N,
                GPIO_LED_C, 
GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,                
			   LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4);
		
	input	   USER_CLK;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_C, GPIO_SW_E, GPIO_SW_S, GPIO_SW_W,GPIO_SW_N;	
    output      GPIO_LED_C;
    output      GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output	   LCD_FPGA_RW, LCD_FPGA_RS, LCD_FPGA_E, LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4;
	
	wire		[2:0]	control_out; //rs, rw, en
	wire		[3:0]   out;
	wire				reset;
	
	wire	writeStart;
	wire	writeDone;
	wire	initDone;
	wire[7:0]	data;
	wire	clearAll;
	wire	resetFSM;
	wire	nextString,display;
	

	
	assign LCD_FPGA_DB7 = out[3];
	assign LCD_FPGA_DB6 = out[2];
	assign LCD_FPGA_DB5 = out[1];
	assign LCD_FPGA_DB4 = out[0];	
	
	assign LCD_FPGA_RS = control_out[2];
	assign LCD_FPGA_RW = control_out[1];
	assign LCD_FPGA_E  = control_out[0];
    
    
    assign GPIO_LED_C = initDone;
	assign reset = GPIO_SW_C;
    
	assign resetFSM = GPIO_SW_S;
	assign clearAll = GPIO_SW_E;
	//assign nextString = GPIO_SW_W; //phi2 clock
   // assign display = GPIO_SW_N;
// nextString = GPIO_SW_W;

    
    DeBounce sn(USER_CLK,1'b1,GPIO_SW_N,display);
    DeBounce sw(USER_CLK,1'b1,GPIO_SW_W,nextString);
    
    
	lcd_control		lcd(.rst(reset), .clk(USER_CLK), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(data), 
							 .clearAll(clrLCD|clearAll));
	wire [5:0] state;							
	testFSM			myTestFsm(.state(state),.clkFSM(USER_CLK), .resetFSM(resetFSM),.data(data),
									 .initDone(initDone),.writeDone(writeDone),.writeStart(writeStart),.clrLCD(clrLCD),
                                     .A(8'hAA),.X(8'hBB),.Y(8'hCC),
                                     .display(display),
									 .nextString(nextString)
									 );
    assign {GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = state;
    assign GPIO_LED_1 = 1'b0;
    assign GPIO_LED_0 = writeDone;
/*
testFSM			myTestFsm(.clkFSM(USER_CLK), .resetFSM(resetFSM), .data(data),
									 .initDone(initDone), .writeStart(writeStart),
									 .nextString(nextString),
									 .writeDone(writeDone));
*/

endmodule
/*  Test module for top level CPU 6502C 

 Designed to test module "top_6502C", located in "top_6502C.v"

*/
`include "top_6502C.v"
`include "lcd_control.v"

/*
description:
press west button to reset lcd
press south button to tick up phi1.
press centre button to reset cpu.
press north button to display current eDB on lcd.
press east button to clear lcd.
the lower byte of eAB is always on the leds.
*/
module testCPU(USER_CLK, 
			   GPIO_SW_C,			   
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_N,
               GPIO_SW_W,
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
			   GPIO_LED_N, GPIO_LED_W,GPIO_LED_S,
				LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4);

	input	   USER_CLK;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_C, GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output 	GPIO_LED_N, GPIO_LED_W,GPIO_LED_S;
	output	LCD_FPGA_RS,LCD_FPGA_RW,LCD_FPGA_E;
	output   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4;
	
	
	
	wire		[2:0]	control_out; //rs, rw, en
	wire		[3:0]   out;
	wire				reset;
	assign LCD_FPGA_DB7 = out[3];
	assign LCD_FPGA_DB6 = out[2];
	assign LCD_FPGA_DB5 = out[1];
	assign LCD_FPGA_DB4 = out[0];	
	
	assign LCD_FPGA_RS = control_out[2];
	assign LCD_FPGA_RW = control_out[1];
	assign LCD_FPGA_E  = control_out[0];
	
	
	
	
	wire	writeStart;
	wire	writeDone;
	wire	initDone;
	wire clearAll;
	wire	resetFSM;

	/* CPU registers */
    wire RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;
    wire phi1_out, SYNC, phi2_out, RW;
    wire [15:0] extAB; //Address Bus Low and High
    wire [7:0] extDB; //Data Bus
	 
	assign RDY = ~GPIO_SW_C;
	assign IRQ_L = 1'b1;
	assign NMI_L = 1'b1;
	assign RES_L = 1'b1;
	assign SO = 1'b1;
	assign phi0_in = ~GPIO_SW_S; //pressing button => phi1 tick.
	assign writeStart = GPIO_SW_N;
	assign GPIO_LED_N = writeDone;
	assign GPIO_LED_W = initDone;
    assign reset = GPIO_SW_W;
	assign GPIO_LED_S = phi2_out;
	assign clearAll = GPIO_SW_E;
	assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = extAB[7:0];
	
	
	lcd_control		lcd(.rst(reset), .clk(USER_CLK), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(extDB), 
							 .clearAll(clearAll));
							 
		 
	 top_6502C cpu(.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), 
                            .extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extAB(extAB), .phi2_out(phi2_out), .RW(RW));
	 wire we_L, re_L;
    assign we_L = RW;
    assign re_L = ~RW; //RW=1 => read mode.
    memory256x256 mem(.clock(phi1_out), .enable(1'b1), .we_L(we_L), .re_L(re_L), .address(extAB), .data(extDB));


endmodule


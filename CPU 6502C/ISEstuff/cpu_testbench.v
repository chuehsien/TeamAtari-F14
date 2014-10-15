/*  Test module for top level CPU 6502C 

 Designed to test module "top_6502C", located in "top_6502C.v"

*/
`include "top_6502C.v"
`include "lcd_control.v"
`include "testFSM.v"
/*
description:
press west button to reset lcd
press south button to tick up phi1.
press centre button to reset cpu.
press north button to display current eDB on lcd.
press east button to clear lcd.
the lower byte of eAB is always on the leds.
*/
module CPUtest(USER_CLK, 
			   GPIO_SW_C,			   
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_N,
               GPIO_SW_W,
               GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
			   GPIO_LED_N, GPIO_LED_W,GPIO_LED_S,
				LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4);

	input	   USER_CLK;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_C, GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	input GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3;
               
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
    
    wire we_L, re_L;
    assign we_L = RW;
    assign re_L = ~RW; //RW=1 => read mode.
   
    wire [7:0] memOut;
   
    wire memClk; //tager inClk = 1.79 * 2 = 3.6Mhz
    
    //clockDivider    #(3) mainClock(USER_CLK,inClk); 
    clockDivider    #(10000000) cpuClock(USER_CLK,memClk); //now its 10Mhz, slow down to 1Hz. divide by 3300.
    clockDivider    #(2) memClock(memClk,phi0_in);
    
    
    //clockDivider #(2) cpuClock(inClk,phi0_in);
    //buf memClock(memClk,inClk);

    blkMem mem(
      .clka(memClk), // input clka
      .wea(~we_L), // input [0 : 0] wea
      .addra(extAB), // input [15 : 0] addra
      .dina(extDB), // input [7 : 0] dina
      .douta(memOut) // output [7 : 0] douta
    );
	bufif1 busDriver[7:0](extDB,memOut,RW);
    
    assign RDY = 1'b1;
	assign IRQ_L = GPIO_DIP_SW1;
	assign NMI_L = GPIO_DIP_SW2;
	assign RES_L = GPIO_DIP_SW3;
	assign SO = GPIO_SW_S;
	//assign phi0_in = ~GPIO_SW_S; //pressing button => phi1 tick.
	
	assign GPIO_LED_N = writeDone;
	assign GPIO_LED_W = initDone;
    assign reset = GPIO_SW_W;
	assign GPIO_LED_S = phi0_in;
	assign clearAll = GPIO_SW_E;
	assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = extAB[7:0];
	//assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3,GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = 
    //{RDY,IRQ_L,NMI_L,RES_L,4'b0000};
    
	wire [7:0] data;
	lcd_control		lcd(.rst(reset), .clk(USER_CLK), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(data), 
							 .clearAll(clearAll));

    wire butOut;
    debounce        deb(USER_CLK,GPIO_SW_N,butOut);
  
	testFSM			myTestFsm(.clkFSM(USER_CLK), .resetFSM(reset), .data(data),
									 .initDone(butOut), .writeStart(writeStart),
									 .dataHi(extDB[7:4]),.dataLo(extDB[3:0]),
									 .writeDone(writeDone));
    wire [6:0] currT;
    wire [1:0] currState;
    wire [7:0] DB,ADH,ADL,SB,adCon,ALUout;
    wire [2:0] activeInt;
    wire holdHi,holdLo;
    //fsm to translate stuff on DB into readable format and tick the lcd.
	top_6502C cpu(.ALUout(ALUOut),.holdHi(holdHi),.holdLo(holdLo),.activeInt(activeInt),.adCon(adCon),.currT(currT),.currState(currState),.DB(DB),.SB(SB),.ADH(ADH),.ADL(ADL),.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), 
                            .extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extAB(extAB), .phi2_out(phi2_out), .RW(RW));

    
    wire [7:0] TRIG0,
    TRIG1,
    TRIG2,
    TRIG3,
    TRIG4,
    TRIG5,
    TRIG6,
    TRIG7,
    TRIG8,
    TRIG9,
    TRIG10,
    TRIG11,
    TRIG12,
    TRIG13,
    TRIG14,
    TRIG15;
    
    wire chipClk;
    clockDivider    #(500000) mainClock2(USER_CLK,chipClk);
    
    wire [35 : 0] CONTROL;
    chipscope_ila ila(
    CONTROL,
    chipClk,
    extAB[15:8],
    extAB[7:0],
    extDB,
    {1'b0,currT},
    {6'b0,currState},
    DB,
    ADH,
    ADL,
    SB,
    {7'd0,phi1_out},
    {RW,activeInt,RDY,IRQ_L,NMI_L,RES_L},
    adCon,
    {holdHi,6'd0,holdLo},
    ALUout,
    {phi0_in,6'd0,memClk},
    TRIG15);
    
    
 chipscope_icon icon(
    CONTROL);
    
    
endmodule


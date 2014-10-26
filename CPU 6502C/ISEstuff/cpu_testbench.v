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
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_N,
               GPIO_SW_W,
               GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4,
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
			   GPIO_LED_N, GPIO_LED_W,
				LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4);

	input	   USER_CLK;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	input      GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
                GPIO_DIP_SW4;
               
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output 	GPIO_LED_N, GPIO_LED_W;
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
	wire    clearAll;
	wire	resetFSM;


    wire phi0_in;
    
    wire HALT,RDY, IRQ_L, NMI_L, RES_L, SO;
    
    wire phi1_out, SYNC, phi2_out, RW;
    wire [7:0] extABH,extABL; //Address Bus Low and High
    wire [7:0] extDB; //Data Bus
    
   //RW=1 => read mode.
   
   
    wire memClk; //target inClk = 1.79 * 2 = 3.6Mhz
    wire memClk_b0,memClk_b1,memClk_b2,memClk_b3;
    //clockDivider    #(3) mainClock(USER_CLK,inClk); 
    //clockDivider    #(5000000) cpuClock(USER_CLK,memClk_b0); //now its 10Mhz, slow down to 1Hz. divide by 3300.
    clockone2048 test1(USER_CLK,memClk_b0);
    clockone1024 test2(memClk_b0,memClk_b1);
    clockHalf    test3(memClk_b1,memClk_b2);
    clockHalf    test4(memClk_b2,memClk_b3);
    buf clkBuf0(phi0_in,memClk_b3);
    
     /*-------------------------------------------------------------*/
    // mem stuff
    
    wire fastClk;
    buf fast(fastClk,memClk_b2);
    (* clock_signal = "yes" *)wire memReadClock,memWriteClock;
    buf writeclk(memWriteClock,phi1_out);
    buf readclk(memReadClock,~memClk_b2); //read clock is doublespeed, and inverted of phi1 (which means same as phi0).
    
   
    wire [15:0] memAdd,memAdd_b;
    wire [7:0] memOut,memOut_b,memDBin;
    assign memAdd = {extABH,extABL};
    buf memB0[7:0](memOut,memOut_b);
    buf memB1[15:0](memAdd_b,memAdd);
    buf memB2[7:0](memDBin,extDB);
	triState busDriver[7:0](extDB,memOut,RW);
    
    memTestFull mem( 
      .clka(memWriteClock), // input clka
      .wea(~RW), // input [0 : 0] wea
      .addra(memAdd_b), // input [15 : 0] addra
      .dina(memDBin), // input [7 : 0] dina
      .clkb(memReadClock),
      .addrb(memAdd_b),
      .doutb(memOut_b) // output [7 : 0] douta
    );

    
    
    
    
    
    
    
    
    /*-------------------------------------------------------------*/
    // cpu stuff
    
    
    
    
    DeBounce #(.N(8)) rdyB(USER_CLK,1'b1,GPIO_DIP_SW1,HALT);
    DeBounce #(.N(8)) irqB(USER_CLK,1'b1,GPIO_DIP_SW2,IRQ_L);
    DeBounce #(.N(8)) nmiB(USER_CLK,1'b1,GPIO_DIP_SW3,NMI_L);
    DeBounce #(.N(8)) resB(USER_CLK,1'b1,GPIO_DIP_SW4,RES_L);
    
    
   // not invAgain[3:0]({RDY,IRQ_L,NMI_L,RES_L},{nRDY,nIRQ_L,nNMI_L,nRES_L});
	assign SO = GPIO_SW_S;
	//assign phi0_in = ~GPIO_SW_S; //pressing button => phi1 tick.

    wire [6:0] currT;
    //wire [2:0] dbDrivers,sbDrivers,adlDrivers,adhDrivers;
    wire [7:0] DB,ADH,ADL,SB,DB_b,ADH_b,ADL_b,SB_b;
    wire [2:0] activeInt;
    
    wire phi1_b,phi0_in_b,memReadClock_b;
    buf b[31:0]({DB_b,ADH_b,ADL_b,SB_b},{DB,ADH,ADL,SB});
    buf b1(phi1_b,phi1_out);
    buf b2(phi0_in_b,phi0_in);
    buf b3(memReadClock_b,memReadClock);
    wire [7:0] ALUhold_out;
    wire rstAll,nmiPending,resPending,irqPending;
    
    wire [7:0] idlContents,A,B,outToPCL,outToPCH,accumVal;
    wire [1:0] currState;
    wire [7:0] second_first_int;
    wire [7:0] OP,opcodeToIR;
    wire [7:0] Accum,Xreg,Yreg;
    wire [7:0] SRflags;
    wire phi1,phi2;
    //fsm to translate stuff on DB into readable format and tick the lcd.
	top_6502C cpu(.phi1(phi1),.phi2(phi2),
                .SRflags(SRflags),.opcode(OP),.opcodeToIR(opcodeToIR),.second_first_int(second_first_int),.nmiPending(nmiPending),
                .resPending(resPending),.irqPending(irqPending),.currState(currState),.accumVal(accumVal),
                .outToPCL(outToPCL),.outToPCH(outToPCH),.A(A),.B(B),.idlContents(idlContents),.rstAll(rstAll),.ALUhold_out(ALUhold_out),
                .activeInt(activeInt),.currT(currT),
                .DB(DB),.SB(SB),.ADH(ADH),.ADL(ADL),
                .HALT(HALT),.IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), .fastClk(fastClk),
                .RDY(RDY),.extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extABH(extABH),.extABL(extABL), .phi2_out(phi2_out), .RW(RW),
                .Accum(Accum),.Xreg(Xreg),.Yreg(Yreg));

    

    /*-------------------------------------------------------------*/
    // LCD stuff

	assign GPIO_LED_W = initDone;
    assign reset = GPIO_SW_W;
    assign GPIO_LED_N = SYNC;
    
	//buf tada0(GPIO_LED_N,memReadClock);
	buf tada2[7:0]({GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7},extABL);
    
	wire [7:0] data;
    wire clrLCD;
    //write to lcd control every phi1. before write, clear LCD.
	lcd_control		lcd(.rst(reset), .clk(USER_CLK), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(data), 
							 .clearAll(clrLCD));


    //wire butOut;
    //wire [5:0] lcdstate;
    //DeBounce #(.N(8)) deb(USER_CLK,1'b1,GPIO_SW_N,butOut);
    
     testFSM			myTestFsm(.clkFSM(USER_CLK), .resetFSM(reset),.data(data),
									 .initDone(initDone),.writeDone(writeDone),.writeStart(writeStart),.clrLCD(clrLCD),
                                     .A(Accum),.X(Xreg),.Y(Yreg),.OP(OP),
                                     .display(phi1_out),
									 .nextString(~phi1_out)
									 );          
                                     
           
 /*-------------------------------------------------------------*/
    // chipscope stuff


    wire [7:0] TRIG0,TRIG1,TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    
    wire chipClk,chipClk_b0;
    clockone2048 test11(USER_CLK,chipClk_b0);
    clockone256  test12(chipClk_b0,chipClk_b);
    BUFG chipscopeClk(chipClk,chipClk_b);
    
    //clockDivider    #(250000) mainClock2(USER_CLK,chipClk);
    
    wire [35 : 0] CONTROL0,CONTROL1;
    chipscope_ila ila0(
    CONTROL0,
    chipClk,
    extABH,
    extABL,
    extDB,
    {1'b0,currT},
    DB_b,
    ADH_b,
    ADL_b,
    SB_b,
    {7'd0,phi1_b},
    {RW,activeInt,RDY,IRQ_L,NMI_L,RES_L},
    Accum,
    opcodeToIR,
    SRflags,
    OP,
    second_first_int,
    8'd0);
    
    // extra ila for use...
    chipscope_ila ila1(
    CONTROL1,
    chipClk,
    memAdd_b[15:8],
    memAdd_b[7:0],
    memOut,
    {1'b0,currT},
    outToPCH,
    outToPCL,
    {7'd0,memReadClock_b},
    {7'd0,phi0_in},
    {7'd0,phi1_out},
    {7'd0,phi2_out},
    {7'd0,phi1},
    {7'd0,phi2},
    TRIG12,
    TRIG13,
    TRIG14,
    TRIG15);

    chipscope_icon2 icon(
    .CONTROL0(CONTROL0),
    .CONTROL1(CONTROL1));
               
endmodule


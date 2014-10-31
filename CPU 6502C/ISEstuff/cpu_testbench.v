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
module CPUtest(USER_CLK, 	CLK_27MHZ_FPGA,		   
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_N,
               GPIO_SW_W,
               GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4,
               
               HDR1_50,HDR1_52,HDR1_54,HDR1_56,HDR1_58,HDR1_60,HDR1_62,HDR1_64,
                
               
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
			   GPIO_LED_N, GPIO_LED_W,
				LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4,
               
               HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32,HDR1_34);

	input	   USER_CLK,CLK_27MHZ_FPGA;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	input      GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
                GPIO_DIP_SW4;
    input HDR1_50,HDR1_52,HDR1_54,HDR1_56,HDR1_58,HDR1_60,HDR1_62,HDR1_64;
    
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output 	GPIO_LED_N, GPIO_LED_W;
	output	LCD_FPGA_RS,LCD_FPGA_RW,LCD_FPGA_E;
	output  LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4;
	
	output  HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32,HDR1_34;	
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
    
    
    wire mainClock;
   // BUFG muxmain(mainClock,USER_CLK);
    //buf muxmain(mainClock,CLK_27MHZ_FPGA);
   //RW=1 => read mode.
   
   //wire phi0_lag,fphi0,locked;
   wire phi0_in_b,phi1_out_b,phi2_out_b;
   clockGen179 makeclock(GPIO_SW_S,CLK_27MHZ_FPGA,phi0_lag,fphi0,phi0_in,locked);
   //BUFG clockb(phi0_in,phi0_in_b);
   
    wire memClk; //target inClk = 1.79 * 2 = 3.6Mhz
    wire memClk_b0,memClk_b1,memClk_b2,memClk_b3;
    //clockDivider    #(3) mainClock(USER_CLK,inClk); 
    //clockDivider    #(5000000) cpuClock(USER_CLK,memClk_b0); //now its 10Mhz, slow down to 1Hz. divide by 3300.
    //clockone4 test1(USER_CLK,memClk_b0);
    //clockHalf test2(memClk_b0,memClk_b1);
    //clockHalf    test3(memClk_b1,memClk_b2);
    //clockHalf    test4(memClk_b2,memClk_b3);
    //buf clkBuf0(phi0_in,memClk_b3);
   /* 
    wire h2,h4,h6,h8;
    BUFG t1(h2,phi1_out);
    BUFG t2(h4,fphi0);
    BUFG t3(h6,phi1_out_b);
    BUFG t4(h8,phi2_out_b);
    assign HDR1_2 = h2;
    assign HDR1_4 = h4;
    assign HDR1_6 = h6;
    assign HDR1_8 = h8;
   */
    //assign HDR1_2 = 1'b0;
    //assign HDR1_4 = 1'b0;
    //assign HDR1_6 = 1'b0;
    //assign HDR1_8 = 1'b0;
     /*-------------------------------------------------------------*/
    // mem stuff
    
    wire fastClk;
    //buf fast(fastClk,memClk_b2);
    buf fast(fastClk,~fphi0); //x2 phi1 speed.
    
    (* clock_signal = "yes" *)wire memReadClock,memWriteClock;
    buf writeclk(memWriteClock,phi1_out); 
    buf readclk(memReadClock,~fphi0); //read clock is doublespeed, and inverted of phi1 (which means same as phi0).
    //buf readclk(memReadClock,~memClk_b2);
   
    wire [15:0] memAdd,memAdd_b;
    wire [7:0] memOut,memOut_b,memDBin;
    assign memAdd = {extABH,extABL};
    buf memB0[7:0](memOut,memOut_b);
    buf memB1[15:0](memAdd_b,memAdd);
    buf memB2[7:0](memDBin,extDB);
	/*
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

    
    */ 
   
/* wire [7:0] bios_data_out;
  memBios mem(
    .clka(memReadClock),
    .addra({1'b1,extABH[2:0],extABL}),
    .douta(bios_data_out)
    );
    
    assign memOut_b = ({1'd0,extABH} >= {1'd0,8'hF8}) ? bios_data_out : 8'hff;
   */ 
    wire addr_RAM,addr_BIOS,addr_CART;
    
    
    wire [7:0] data_CART;
    assign data_CART = {HDR1_50,HDR1_52,HDR1_54,HDR1_56,HDR1_58,HDR1_60,HDR1_62,HDR1_64};
    assign {HDR1_28,HDR1_26,HDR1_24,HDR1_22,HDR1_20,HDR1_18,HDR1_16,HDR1_14,HDR1_12,HDR1_10,HDR1_8,HDR1_6,HDR1_4,HDR1_2} = memAdd_b[13:0];
   
    assign HDR1_30 = ((16'h4000 <= {1'b0,memAdd_b}) & ({1'b0,memAdd_b} < 16'h8000)) ? 1'b1 : 1'b0;
    assign HDR1_32 = ((16'h8000 <= {1'b0,memAdd_b}) & ({1'b0,memAdd_b} < 16'hC000)) ? 1'b1 : 1'b0;
   assign HDR1_34 = memReadClock;
    
    
   
    memoryMap   integrateMem(.addr_RAM(addr_RAM),.addr_BIOS(addr_BIOS),.addr_CART(addr_CART),
                .Fclk(memReadClock), .clk(memWriteClock), .CPU_writeEn(~RW), .CPU_addr(memAdd_b), 
                 .data_CART_out(data_CART),
                 .CPU_data(extDB) 
                );
    
    
    
    
    /*-------------------------------------------------------------*/
    // cpu stuff
    
    
    
    
    DeBounce #(.N(8)) rdyB(phi0_in,1'b1,GPIO_DIP_SW1,HALT);
    DeBounce #(.N(8)) irqB(phi0_in,1'b1,GPIO_DIP_SW2,IRQ_L);
    DeBounce #(.N(8)) nmiB(phi0_in,1'b1,GPIO_DIP_SW3,NMI_L);
    DeBounce #(.N(8)) resB(phi0_in,1'b1,GPIO_DIP_SW4,RES_L);
    
    
   // not invAgain[3:0]({RDY,IRQ_L,NMI_L,RES_L},{nRDY,nIRQ_L,nNMI_L,nRES_L});
	assign SO = 1'b0;
	//assign phi0_in = ~GPIO_SW_S; //pressing button => phi1 tick.

    wire [6:0] currT;
    //wire [2:0] dbDrivers,sbDrivers,adlDrivers,adhDrivers;
    wire [7:0] DB,ADH,ADL,SB,DB_b,ADH_b,ADL_b,SB_b;
    wire [2:0] activeInt;
    
    wire memReadClock_b;
    buf b[31:0]({DB_b,ADH_b,ADL_b,SB_b},{DB,ADH,ADL,SB});
   
    buf b3(memReadClock_b,memReadClock);
    wire [7:0] ALUhold_out;
    wire rstAll,nmiPending,resPending,irqPending;
     buf b1(phi0_in_b,phi0_in);
    //buf b4(phi1_out_b,phi1_out);
    //buf b5(phi2_out_b,phi2_out);

    wire [7:0] idlContents,A,B,outToPCL,outToPCH,accumVal;
    wire [1:0] currState;
    wire [7:0] second_first_int;
    wire [7:0] OP,opcodeToIR;
    wire [7:0] Accum,Xreg,Yreg;
    wire [7:0] SRflags;
    //wire phi1,phi2;
    //fsm to translate stuff on DB into readable format and tick the lcd.
	top_6502C cpu(
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
	lcd_control		lcd(.rst(reset), .clk(fphi0), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(data), 
							 .clearAll(clrLCD));


    //wire butOut;
    //wire [5:0] lcdstate;
    //DeBounce #(.N(8)) deb(USER_CLK,1'b1,GPIO_SW_N,butOut);
    
     testFSM			myTestFsm(.clkFSM(fphi0), .resetFSM(reset),.data(data),
									 .initDone(initDone),.writeDone(writeDone),.writeStart(writeStart),.clrLCD(clrLCD),
                                     .A(Accum),.X(Xreg),.Y(Yreg),.OP(OP),
                                     .display(phi1_out),
									 .nextString(~phi1_out)
									 );          
                                     
           
 /*-------------------------------------------------------------*/
    // chipscope stuff


    wire [7:0] TRIG0,TRIG1,TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    
    wire chipClk,chipClk_b0;
    //clockone4 test11(USER_CLK,chipClk_b);
    clockone256  test12(CLK_27MHZ_FPGA,chipClk_b);
    //BUFG chipscopeClk(chipClk,chipClk_b);
    
    //clockDivider    #(250000) mainClock2(USER_CLK,chipClk);
    
    wire [35 : 0] CONTROL0,CONTROL1;
    chipscope_ila ila0(
    CONTROL0,
    chipClk_b,
    extABH,
    extABL,
    extDB,
    {1'b0,currT},
    DB_b,
    ADH_b,
    ADL_b,
    SB_b,
    {7'd0,phi1_out_b},
    {RW,activeInt,RDY,IRQ_L,NMI_L,RES_L},
    second_first_int,
    opcodeToIR,
    {rstAll,4'd0,addr_RAM,addr_BIOS,addr_CART},
    OP,
    idlContents,
    8'd0);
    
    // extra ila for use...
    chipscope_ila ila1(
    CONTROL1,
    chipClk_b,
    memAdd_b[15:8],
    memAdd_b[7:0],
    memOut,
    {1'b0,currT},
    outToPCH,
    outToPCL,
    {7'd0,memReadClock_b},
    {7'd0,memWriteClock},
    {7'd0,fastClk},
    {7'd0,1'b0},
    {7'd0,phi1},
    {7'd0,1'b0},
    TRIG12,
    TRIG13,
    TRIG14,
    TRIG15);

    chipscope_icon2 icon(
    .CONTROL0(CONTROL0),
    .CONTROL1(CONTROL1));
               
endmodule


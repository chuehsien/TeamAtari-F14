/*  Test module for top level CPU 6502C 

 Designed to test module "top_6502C", located in "top_6502C.v"

*/
`include "top_6502C.v"
`include "lcd_control.v"
`include "testFSM.v"

`define DIV 8'd4
/*
description:
press west button to reset lcd
press south button to tick up phi1.
press centre button to reset cpu.
press north button to display current eDB on lcd.
press east button to clear lcd.
the lower byte of eAB is always on the leds.
*/
module CPUtest(CLK_27MHZ_FPGA,		   
			   GPIO_SW_E,			   
			   GPIO_SW_S,			   
			   GPIO_SW_N,
               GPIO_SW_W,
               GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
               GPIO_DIP_SW4,
               GPIO_DIP_SW5,
               GPIO_DIP_SW6,
               GPIO_DIP_SW7,
               GPIO_DIP_SW8,
               
               HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48,
                
               
				GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7,
			   GPIO_LED_N, GPIO_LED_W,
				LCD_FPGA_RS, LCD_FPGA_RW, LCD_FPGA_E,
			   LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4,
               
               HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32,
               HDR1_50,HDR1_52,HDR1_54,HDR1_56,HDR1_58);

	input	   CLK_27MHZ_FPGA;
	/* switch C is reset, E is clear, S is resetFSM, W is nextString */
	input	   GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	input      GPIO_DIP_SW1,
               GPIO_DIP_SW2,
               GPIO_DIP_SW3,
                GPIO_DIP_SW4,
                GPIO_DIP_SW5,
               GPIO_DIP_SW6,
               GPIO_DIP_SW7,
               GPIO_DIP_SW8;
    input HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48;
    
	output 	GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7;
	output 	GPIO_LED_N, GPIO_LED_W;
	output	LCD_FPGA_RS,LCD_FPGA_RW,LCD_FPGA_E;
	output  LCD_FPGA_DB7, LCD_FPGA_DB6, LCD_FPGA_DB5, LCD_FPGA_DB4;
	
	output  HDR1_2,HDR1_4,HDR1_6,HDR1_8,HDR1_10,HDR1_12,HDR1_14,HDR1_16,HDR1_18,HDR1_20,HDR1_22,HDR1_24,HDR1_26,HDR1_28,HDR1_30,HDR1_32;	
	output HDR1_50,HDR1_52,HDR1_54,HDR1_56,HDR1_58;
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


    
    wire HALT,RDY, IRQ_L, NMI_L, RES_L, SO;
    
    wire phi1_out,phi2_out,SYNC,RW;
    wire [7:0] extABH,extABL,extDB; 
    wire [7:0] extABH_b,extABL_b,extDB_b; 

   wire phi0_in,fphi0;
   clockGen179 #(.div(`DIV)) makeclock(GPIO_SW_S,CLK_27MHZ_FPGA,phi0_in,fphi0,locked);
   
    (* clock_signal = "yes" *) wire clk64,clk16,clk15,clk60;

    clockDivider #(422) out64(CLK_27MHZ_FPGA,clk64);
    clockDivider #(1688) out16(CLK_27MHZ_FPGA,clk16);
    clockDivider #(1800) out15(CLK_27MHZ_FPGA,clk15);
    clockDivider #(450000) out60(CLK_27MHZ_FPGA,clk60);
     /*-------------------------------------------------------------*/
    // mem stuff
    
    wire fastClk;
    BUFG fast(fastClk,fphi0); //x2 phi1 speed.
    
    (* clock_signal = "yes" *)wire memReadClock,memWriteClock;
    
   //read clock is doublespeed, and inverted of phi1 (which means same as phi0).

    BUFG  mR(memReadClock,fphi0);

    wire [15:0] memAdd;
   
    wire [7:0] memOut,memOut_b,memDBin;
    assign memAdd = {extABH,extABL};
   // assign memAdd = 16'h9882;
	

    triState8 busDriver(extDB,memOut_b,RW);
  
    memTestFull2 mem( 
      .clka(memReadClock), // input clka
      .wea(~RW), // input [0 : 0] wea
      .addra(memAdd), // input [15 : 0] addra
      .dina(extDB), // input [7 : 0] dina
      .douta(memOut_b) // output [7 : 0] douta
    );


   
    wire addr_RAM,addr_BIOS,addr_CART;
    
    wire [7:0] data_CART;
    wire [7:0] data_CART2;
    
    assign data_CART2 = {HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48};
    assign {HDR1_28,HDR1_26,HDR1_24,HDR1_22,HDR1_20,HDR1_18,HDR1_16,HDR1_14,HDR1_12,HDR1_10,HDR1_8,HDR1_6,HDR1_4,HDR1_2} = memAdd[13:0];
   
    assign HDR1_30 = ((16'h4000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'h8000)) ? 1'b0 : 1'b1;
    assign HDR1_32 = ((16'h8000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'hC000)) ? 1'b0 : 1'b1;
   
   
    wire [7:0] AUDF1,AUDC1,AUDF2,AUDC2,AUDF3,AUDC3,AUDF4,AUDC4,AUDCTL;
    wire audio1,audio2,audio3,audio4;
    wire [3:0] vol1,vol2,vol3,vol4;
    assign HDR1_50 = audio3;
    assign {HDR1_52,HDR1_54,HDR1_56,HDR1_58} = vol3;

    pokeyaudio pokey(.init_L(RES_L),.clk179(fphi0),.clk64(clk64),.clk16(clk16),
                    .AUDF1(AUDF1),.AUDF2(AUDF2),.AUDF3(AUDF3),.AUDF4(AUDF4),
                    .AUDC1(AUDC1),.AUDC2(AUDC2),.AUDC3(AUDC3),.AUDC4(AUDC4),.AUDCTL(AUDCTL),
                    .audio1(audio1),.audio2(audio2),.audio3(audio3),.audio4(audio4),
                    .vol1(vol1),.vol2(vol2),.vol3(vol3),.vol4(vol4));
                    
    wire [15:0] cartROMadd;
    assign cartROMadd = (memAdd - 16'h4000);
    //memDefender memD(.clka(memReadClock),.addra(cartROMadd[14:0]),.douta(data_CART));
    /*
    memoryMap   integrateMem(.addr_RAM(addr_RAM),.addr_BIOS(addr_BIOS),.addr_CART(addr_CART),
                .Fclk(memReadClock), .clk(memReadClock), .CPU_writeEn(~RW), .CPU_addr(memAdd), 
                 .data_CART_out(data_CART),
                 .CPU_data(extDB),
                 .AUDF1(AUDF1), .AUDC1(AUDC1), .AUDF2(AUDF2), .AUDC2(AUDC2), 
                 .AUDF3(AUDF3), .AUDC3(AUDC3), .AUDF4(AUDF4), .AUDC4(AUDC4), .AUDCTL(AUDCTL)
                );
*/
    /*-------------------------------------------------------------*/
    // cpu stuff

    /*
    DeBounce #(.N(8)) rdyB(fphi0,1'b1,GPIO_DIP_SW1,HALT);
    DeBounce #(.N(8)) irqB(fphi0,1'b1,GPIO_DIP_SW2,IRQ_L);
    DeBounce #(.N(8)) nmiB(fphi0,1'b1,GPIO_DIP_SW3,NMI_L);
    DeBounce #(.N(8)) resB(fphi0,1'b1,GPIO_DIP_SW4,RES_L);
    */
    
    assign IRQ_L = 1'b1;
    wire nRES_L,nNMI_L;
    assign RES_L = ~nRES_L;
    assign NMI_L = ~GPIO_SW_N;
    //assign NMI_L = ~clk60; //VBI every 1/60seconds
    DeBounce #(.N(8)) resB(fphi0,1'b1,GPIO_SW_W,nRES_L);
   // DeBounce #(.N(8)) nmiB(fphi0,1'b1,GPIO_SW_N,nNMI_L);
    DeBounce #(.N(8)) haltiB(fphi0,1'b1,GPIO_SW_E,HALT);
    
   // not invAgain[3:0]({RDY,IRQ_L,NMI_L,RES_L},{nRDY,nIRQ_L,nNMI_L,nRES_L});
	assign SO = 1'b0;
    
    wire [6:0] currT,currT_b;

    wire [7:0] DB,ADH,ADL,SB,DB_b,ADH_b,ADL_b,SB_b;
    
    wire [2:0] activeInt;
    
    buf b0[7:0](DB_b,DB);
    buf b1[7:0](SB_b,SB);
    buf b2[7:0](ADH_b,ADH);
    buf b3[7:0](ADL_b,ADL);
    
    buf b_a[7:0](extDB_b,extDB);
    buf b_b[7:0](extABL_b,extABL);
    buf b_c[7:0](extABH_b,extABH);
    buf b_d[6:0](currT_b,currT);

    wire [7:0] ALUhold_out;
    wire rstAll,nmiPending,resPending,irqPending;
    wire [7:0] idlContents,A,B,outToPCL,outToPCH,accumVal;
    wire [1:0] currState;
    wire [7:0] second_first_int;
    wire [7:0] OP,opcodeToIR,prevOpcode;
    wire [7:0] Accum,Xreg,Yreg;
    wire [7:0] DBforSR,extAB_b1,SRflags,holdAB,SR_contents;

	top_6502C cpu(.DBforSR(DBforSR),.prevOpcode(prevOpcode),.extAB_b1(extAB_b1),.SR_contents(SR_contents),.holdAB(holdAB),
                .SRflags(SRflags),.opcode(OP),.opcodeToIR(opcodeToIR),.second_first_int(second_first_int),.nmiPending(nmiPending),
                .resPending(resPending),.irqPending(irqPending),.currState(currState),.accumVal(accumVal),
                .outToPCL(outToPCL),.outToPCH(outToPCH),.A(A),.B(B),.idlContents(idlContents),.rstAll(rstAll),.ALUhold_out(ALUhold_out),
                .activeInt(activeInt),.currT(currT),
                
                .DB(DB),.SB(SB),.ADH(ADH),.ADL(ADL),
                .HALT(HALT),.IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in),.fastClk(fastClk),
                .RDY(RDY),.extDB(extDB), .phi1_out(phi1_out), .phi2_out(phi2_out),.SYNC(SYNC), .extABH(extABH),.extABL(extABL),  .RW(RW),
                .Accum(Accum),.Xreg(Xreg),.Yreg(Yreg));

    

    /*-------------------------------------------------------------*/
    // LCD stuff

	assign GPIO_LED_W = initDone;
    assign reset = 1'b0;
    assign GPIO_LED_N = SYNC;

	assign {GPIO_LED_0, GPIO_LED_1, GPIO_LED_2, GPIO_LED_3, GPIO_LED_4, GPIO_LED_5, GPIO_LED_6, GPIO_LED_7} = extABL;
    
    
	wire [7:0] data;
    wire clrLCD;
    //write to lcd control every phi1. before write, clear LCD.
	lcd_control		lcd(.rst(reset), .clk(CLK_27MHZ_FPGA), .control(control_out), .sf_d(out),
							 .writeStart(writeStart), .initDone(initDone), .writeDone(writeDone), 
							 .dataIn(data), 
							 .clearAll(clrLCD));

     testFSM			myTestFsm(.clkFSM(CLK_27MHZ_FPGA), .resetFSM(reset),.data(data),
									 .initDone(initDone),.writeDone(writeDone),.writeStart(writeStart),.clrLCD(clrLCD),
                                     .A(Accum),.X(Xreg),.Y(Yreg),.OP(OP),
                                     .display(phi1_out),
									 .nextString(~phi1_out)
									 );          
                                     
           
 /*-------------------------------------------------------------*/
    // chipscope stuff


    //need counter to check how many types it's been at an address!
    //sense outToPCH and outToPCL
    
    wire sense;
    assign sense = ({ADH_b,ADL_b} == {8'hfd,GPIO_DIP_SW1,GPIO_DIP_SW2,GPIO_DIP_SW3,GPIO_DIP_SW4,GPIO_DIP_SW5,GPIO_DIP_SW6,GPIO_DIP_SW7,GPIO_DIP_SW8});
    
    wire [7:0] count,countin;
    assign countin = count + 8'd1;
    FlipFlop8clr FF0(~phi0_in,countin,sense,count,nRES_L);

    
   // wire [7:0] TRIG0,TRIG1,TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    
    wire chipClk,chipClk_b0;

    clockoneX #(.width(`DIV-3))  test12(CLK_27MHZ_FPGA,chipClk_b);
    
    wire [35 : 0] CONTROL0,CONTROL1;
    chipscope_ila ila0(
    CONTROL0,
    chipClk_b,
    memAdd[15:8],
    memAdd[7:0],
    extDB,
    {1'b0,currT_b},
    DB_b,
    ADH_b,
    ADL_b,
    SB_b,
    {7'd0,phi1_out},
    {RW,activeInt,RDY,IRQ_L,NMI_L,RES_L},
    Accum,
    Xreg,
    8'd0,
    OP,
    Yreg,
    SRcontents);
    
    // extra ila for use...
    chipscope_ila ila1(
    CONTROL1,
    chipClk_b,
    memAdd[15:8],
    memAdd[7:0],
    memOut_b,
    {1'b0,currT_b},
    8'd0,
    8'd0,
    8'd0,
    8'd0,
    {7'd0,fastClk},
    8'd0,
    8'd0,
    8'd0,
    8'd0,
    8'd0,
    8'd0,
    8'd0);

    chipscope_icon2 icon(
    .CONTROL0(CONTROL0),
    .CONTROL1(CONTROL1));
               
endmodule

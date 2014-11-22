/*
 * Top module for CPU-Graphics integrated testing
 *
 * Button description:
 *   - West: Reset entire system
 *   - North: Trigger (test) NMI
 *   - East: Trigger (test) DMA
 */

`include "CPU/top_6502C.v"
`include "Clock/clockDiv.v"
`include "Clock/clockGen.v"
`include "Memory/memoryMap.v"
`include "POKEY/Audio/pokeyaudio.v"
`include "POKEY/IO/POKEY_top_integration.v"
`include "Graphics/ANTIC.v"
`include "Graphics/GTIA.v"
`include "Graphics/DVI.v"
`include "Graphics/displayBlockMem.v"

`define DIV 8'd4

module Atari5200(CLK_27MHZ_FPGA, USER_CLK, 
                //switches/dipswitches pin in
                GPIO_SW_N, GPIO_SW_S, GPIO_SW_E, GPIO_SW_W, GPIO_SW_C,
                 GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4,
                 GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8,
                //Cart pin in
                 HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48,
                 
                 //pokey io pin in
                 
                 HDR2_10, HDR2_12, HDR2_14, HDR2_16, HDR2_18, HDR2_20, HDR2_22, HDR2_24, HDR2_26, HDR2_28, HDR2_30, HDR2_32,

                 IIC_SDA_VIDEO, IIC_SCL_VIDEO, 
                 
                 //Cart pin out
                 HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_10, HDR1_12, HDR1_14, HDR1_16, 
                 HDR1_18, HDR1_20, HDR1_22, HDR1_24, HDR1_26, HDR1_28, HDR1_30, HDR1_32,
                 

                 //pokey audio pin out
					  HDR1_50,HDR1_52,HDR1_54,HDR1_56,
                 HDR2_34, HDR2_36, HDR2_38, HDR2_40, HDR2_42, HDR2_44, HDR2_46, HDR2_48,
                 HDR2_50, HDR2_52, HDR2_54,HDR2_56,HDR2_58, HDR2_60, HDR2_62, HDR2_64,

                 //pokey io pin out
                 HDR2_2, HDR2_4, HDR2_6, HDR2_8,HDR1_60, HDR1_62, HDR1_64,



                 DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5,
                 DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0, DVI_XCLK_P, DVI_XCLK_N,
                 DVI_V, DVI_H, DVI_DE, DVI_RESET_B,

                //LED pin outs
                GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,GPIO_LED_6,GPIO_LED_7,
                GPIO_LED_N,GPIO_LED_S,GPIO_LED_E,GPIO_LED_W,GPIO_LED_C);

	input  CLK_27MHZ_FPGA, USER_CLK;
	input  GPIO_SW_N, GPIO_SW_S, GPIO_SW_E, GPIO_SW_W, GPIO_SW_C;
	input  GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4, 
          GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8;
   //Cart pin in
   input  HDR1_34, HDR1_36, HDR1_38, HDR1_40, HDR1_42, HDR1_44, HDR1_46, HDR1_48;
   //pokey io pin in
	input  HDR2_10, HDR2_12, HDR2_14, HDR2_16, HDR2_18, HDR2_20, HDR2_22, HDR2_24, 
          HDR2_26, HDR2_28, HDR2_30, HDR2_32;
    
   inout  IIC_SDA_VIDEO, IIC_SCL_VIDEO;
	//Cart pin out
	output HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_10, HDR1_12, HDR1_14, HDR1_16, 
          HDR1_18, HDR1_20, HDR1_22, HDR1_24, HDR1_26, HDR1_28, HDR1_30, HDR1_32;
	       
  //pokey audio pin out
   output HDR1_50,HDR1_52,HDR1_54,HDR1_56,
	       HDR2_34, HDR2_36, HDR2_38, HDR2_40, HDR2_42, HDR2_44, HDR2_46, HDR2_48,
          HDR2_50, HDR2_52, HDR2_54,HDR2_56,HDR2_58, HDR2_60, HDR2_62, HDR2_64;
			 
	//pokey io pin out
   output HDR2_2, HDR2_4, HDR2_6, HDR2_8,HDR1_60, HDR1_62, HDR1_64;
    
    
   output DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6,
          DVI_D5, DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0,
          DVI_XCLK_P, DVI_XCLK_N, DVI_V, DVI_H, DVI_DE, DVI_RESET_B;
   output GPIO_LED_0,GPIO_LED_1,GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_5,GPIO_LED_6,GPIO_LED_7,
          GPIO_LED_N,GPIO_LED_S,GPIO_LED_E,GPIO_LED_W,GPIO_LED_C;


    //place holders for switches/leds
   assign {GPIO_LED_2,GPIO_LED_3,GPIO_LED_4,GPIO_LED_N,GPIO_LED_S,GPIO_LED_E,GPIO_LED_W,GPIO_LED_C} = 0;
    
	wire writeStart;
	wire writeDone;
	wire initDone;
	wire clearAll;
	wire resetFSM;
    wire HALT, RDY, IRQ_L, NMI_L, RES_L, SO;
    wire phi1_out,phi2_out,SYNC,RW;
    wire [7:0] extABH,extABL,extDB; 
    wire [7:0] extABH_b,extABL_b,extDB_b;
  

    // clock generation
    (* clock_signal = "yes" *) wire phi0_in, fphi0,fphi0X2;
    clockGen179 #(.div(`DIV)) makeclock(.RST(GPIO_SW_S),.clk27(CLK_27MHZ_FPGA),
                                        .phi0(phi0_in),.fphi0(fphi0),.fphi0x2(fphi0X2));
    
    (* clock_signal = "yes" *) wire clk64,clk16,clk15,clk60;

    clockDivider #(422) out64(CLK_27MHZ_FPGA,clk64);
    clockDivider #(1688) out16(CLK_27MHZ_FPGA,clk16);
    clockDivider #(1800) out15(CLK_27MHZ_FPGA,clk15);
    clockDivider #(450000) out60(CLK_27MHZ_FPGA,clk60);

    // switches
    wire nRES_L;
    assign RES_L = ~nRES_L;
    DeBounce #(.N(8)) resB(fphi0,1'b1,GPIO_SW_W,nRES_L);



    // mem stuff
    wire [15:0] memAdd;
   
    wire [7:0] memOut,memOut_b,memDBin;
    assign memAdd = {extABH,extABL};
  
    /*
    triState8 busDriver(extDB,memOut_b,RW);
  
    memTestFull2 mem( 
      .clka(fphi0), // input clka
      .wea(~RW), // input [0 : 0] wea
      .addra(memAdd), // input [15 : 0] addra
      .dina(extDB), // input [7 : 0] dina
      .douta(memOut_b) // output [7 : 0] douta
    );
    */
    

    // Graphics components
    wire Fphi0;
    wire phi2;
    wire clk_DVI;
    wire clk_half;
    wire rst = nRES_L;
    wire request;
    wire [63:0] doutB;
    wire [11:0] DVI_D;

    reg [15:0] addrB = 16'd0;
    
    assign DVI_D11 = DVI_D[11];
    assign DVI_D10 = DVI_D[10];
    assign DVI_D9 = DVI_D[9];
    assign DVI_D8 = DVI_D[8];
    assign DVI_D7 = DVI_D[7];
    assign DVI_D6 = DVI_D[6];
    assign DVI_D5 = DVI_D[5];
    assign DVI_D4 = DVI_D[4];
    assign DVI_D3 = DVI_D[3];
    assign DVI_D2 = DVI_D[2];
    assign DVI_D1 = DVI_D[1];
    assign DVI_D0 = DVI_D[0];
    
    //BUFG  bufGraphics(Fphi0, ~fphi0);
    //BUFG  bufDVI(clk_DVI, clk_half);
    //clockHalf dviclk(USER_CLK, clk_half);
    
    assign Fphi0 = ~fphi0;
    
      
    reg [1:0] clkdiv = 2'd0;
    assign clk_DVI = clkdiv[1];
    
    always @(posedge USER_CLK) begin
      if (clkdiv == 2'd3)
        clkdiv <= 2'd0;
      else
        clkdiv <= clkdiv + 2'd1;
    end
    
    // GTIA to memory map wires
    wire [7:0] COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY,
               GRACTL, HITCLR, HPOSP0_M0PF_bus, HPOSP1_M1PF_bus, HPOSP2_M2PF_bus, 
               HPOSP3_M3PF_bus, HPOSM0_P0PF_bus, HPOSM1_P1PF_bus, HPOSM2_P2PF_bus, 
               HPOSM3_P3PF_bus, SIZEP0_M0PL_bus, SIZEP1_M1PL_bus, SIZEP2_M2PL_bus, 
               SIZEP3_M3PL_bus, SIZEM_P0PL_bus, GRAFP0_P1PL_bus, GRAFP1_P2PL_bus, 
               GRAFP2_P3PL_bus, GRAFP3_TRIG0_bus, GRAFPM_TRIG1_bus, COLPM0_TRIG2_bus, 
               COLPM1_TRIG3_bus, COLPM2_PAL_bus, CONSPK_CONSOL_bus;
    
    // ANTIC to memory map wires
    wire [7:0] DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, WSYNC, NMIEN, 
               NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, VCOUNT, PENH, PENV;
    wire [2:0] ANTIC_writeEn;
    
    wire [31:0] dBuf_data;
    wire [16:0] dBuf_addr; 
    wire dBuf_writeEn;
    
    wire [3:0] AN;
    wire [15:0] address = {extABH, extABL};
    wire [2:0] charMode;
    wire vblank, hblank;
    wire [1:0] numLines;
    wire [8:0] width;
    wire [7:0] height;
    
     //TEMP
    wire [7:0] IR;
    wire [1:0] currStateANTIC;
    wire [3:0] mode;
    wire IR_rdy;
    wire [15:0] dlist;
    wire [7:0] DLISTL;
    wire idle;
    wire [15:0] MSR;
    wire [1:0] loadMSRstate;
    wire DLISTend;
    wire [8:0] x;
    wire [7:0] y;
    wire [15:0] addressOut;
    wire haltANTIC;
    wire rdyANTIC;
    wire [7:0] MSRdata;
    wire [1:0] colorSel4;
    wire [7:0] colorData;
    wire [23:0] RGB;
    wire ANTIC_writeNMI;
    wire incrY;
    wire saveY;

    // Module instantiation
    ANTIC antic(.Fphi0(Fphi0), .LP_L(), .RW(), .rst(rst), .vblank(vblank), .hblank(hblank), .DMACTL(DMACTL), .CHACTL(CHACTL),
                .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE), .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), 
                .DB(extDB), .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
                .address(address), .AN(AN), .halt(HALT), .NMI_L(NMI_L), .RDY(RDY), .REF_L(), .RNMI_L(), .phi0(), 
                .IR_out(IR), .loadIR(), .VCOUNT(VCOUNT), .PENH(PENH), .PENV(PENV), .ANTIC_writeEn(ANTIC_writeEn), 
                .charMode(charMode), .numLines(numLines), .width(width), .height(height), .incrY(incrY), .saveY(saveY),
                .printDLIST(dlist), .currState(currStateANTIC), .MSR(MSR), .loadDLIST_both(), 
                .loadMSR_both(), .IR_rdy(IR_rdy), .mode(mode), .numBytes(), .MSRdata(MSRdata), 
                .DLISTL(DLISTL), .blankCount(), .addressIn(), .loadMSRdata(),
                .charData(), .newDLISTptr(), .loadDLIST(), .DLISTend(DLISTend), 
                .idle(idle), .loadMSRstate(loadMSRstate), .addressOut(addressOut), .haltANTIC(haltANTIC), .rdyANTIC(rdyANTIC),
                .colorSel4(colorSel4), .ANTIC_writeNMI(ANTIC_writeNMI));
    
    GTIA gtia(.address(), .AN(AN), .CS(), .DEL(), .OSC(), .RW(), .trigger(), .Fphi0(Fphi0), .rst(rst), .charMode(charMode),
              .DLISTend(DLISTend), .numLines(numLines), .width(width), .height(height), .incrY(incrY), .saveY(saveY),
              .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2), .COLPF3(COLPF3), .COLBK(COLBK),
              .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
              .DB(extDB), .switch(),
              .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
              .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
              .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
              .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
              .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus), 
              .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
              .COLPM0_TRIG2_bus(COLPM0_TRIG2_bus), .COLPM1_TRIG3_bus(COLPM1_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus), 
              .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus),
              .COL(), .CSYNC(), .phi2(phi2), .HALT(), .L(),
              .dBuf_data(dBuf_data), .dBuf_addr(dBuf_addr), .dBuf_writeEn(dBuf_writeEn),
              .vblank(vblank), .hblank(hblank), .x(x), .y(y),
              .colorData(colorData), .RGB(RGB));
                 

    displayBlockMem dbm(.clka(Fphi0), .wea(dBuf_writeEn), .addra(dBuf_addr), .dina(dBuf_data), .clkb(clk_DVI),
                        .addrb(addrB), .doutb(doutB));
    
    DVI dvi(.clock(clk_DVI), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
            .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
            .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
            .request(request));
    
    // FSM to control DVI reads from port B
    always @(posedge request or posedge nRES_L) begin
      if (nRES_L) begin
        addrB <= 16'd0;
      end
      else begin
        if (addrB >= 16'd34559)
          addrB <= 16'd0;
        else
          addrB <= addrB + 16'd1;
      end
    end


   
    wire addr_RAM,addr_BIOS,addr_CART;
    
    wire [7:0] data_CART;
    wire [7:0] data_CART2;
    
    assign data_CART2 = {HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48};
    assign {HDR1_28,HDR1_26,HDR1_24,HDR1_22,HDR1_20,HDR1_18,HDR1_16,HDR1_14,HDR1_12,HDR1_10,HDR1_8,HDR1_6,HDR1_4,HDR1_2} = memAdd[13:0];
   
    assign HDR1_30 = ((16'h4000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'h8000)) ? 1'b0 : 1'b1;
    assign HDR1_32 = ((16'h8000 <= {1'b0,memAdd}) & ({1'b0,memAdd} < 16'hC000)) ? 1'b0 : 1'b1;
   
   
	/*  =============== POKEY stuff ============ */

    wire [7:0] AUDF1,AUDC1,AUDF2,AUDC2,AUDF3,AUDC3,AUDF4,AUDC4,AUDCTL;
    wire [7:0] SKCTL, IRQEN,IRQST_BUS,POT0_BUS, POT1_BUS, POT2_BUS, POT3_BUS, ALLPOT_BUS, KBCODE_BUS, SKSTAT_BUS,
               TRIG0_BUS,TRIG1_BUS,TRIG2_BUS,TRIG3_BUS,RANDOM_BUS,CONSPK_CONSOL;
	wire POTGO_strobe,STIMER_strobe;

    wire audio1,audio2,audio3,audio4;
    wire [3:0] vol1,vol2,vol3,vol4;
    wire timer1_int,timer2_int,timer4_int;

    assign HDR1_50 = clk15;
    assign HDR1_52 = audio2;
    assign HDR1_54 = audio3;
    assign HDR1_56 = audio4;
   
	/*
    assign HDR1_50 = phi1_out;
    assign HDR1_52 = fphi0;
    assign HDR1_54 = Fphi0;
    assign HDR1_56 = fphi0X2;
   */
	
    assign {HDR2_34, HDR2_36, HDR2_38, HDR2_40} = vol1;
    assign {HDR2_48, HDR2_46, HDR2_44, HDR2_42} = vol2;
    assign {HDR2_50, HDR2_52, HDR2_54, HDR2_56} = vol3;
    assign {HDR2_64, HDR2_62, HDR2_60, HDR2_58} = vol4;
	 
    pokeyaudio pokeyAudio(.init_L(RES_L),.clk179(phi1_out),.clk64(clk64),.clk16(clk16),
                    .AUDF1(AUDF1),.AUDF2(AUDF2),.AUDF3(AUDF3),.AUDF4(AUDF4),
                    .AUDC1(AUDC1),.AUDC2(AUDC2),.AUDC3(AUDC3),.AUDC4(AUDC4),.AUDCTL(AUDCTL),
                    .audio1(audio1),.audio2(audio2),.audio3(audio3),.audio4(audio4),
                    .vol1(vol1),.vol2(vol2),.vol3(vol3),.vol4(vol4),.RANDOM(RANDOM_BUS),
					.int1(timer1_int),.int2(timer2_int),.int4(timer4_int),.STIMER_strobe(STIMER_strobe));
    
	 wire [3:0] cIn,cOut,keyscan;
    POKEY_top_integration pokeyIO( .control_input(cIn),.control_output_8_5(cOut),.key_scan_L(keyscan),
                                  .rst(~RES_L), .clk15(clk15), .clk179(phi1_out), .HDR2_10(HDR2_10), .HDR2_12(HDR2_12), .HDR2_14(HDR2_14), .HDR2_16(HDR2_16), .HDR2_18(HDR2_18), 
                                  .HDR2_20(HDR2_20), .HDR2_22(HDR2_22), .HDR2_24(HDR2_24), .HDR2_26(HDR2_26), .HDR2_28(HDR2_28), .HDR2_30(HDR2_30), .HDR2_32(HDR2_32),
                                  .SKCTL(SKCTL), .GRACTL(GRACTL),.IRQEN(IRQEN),.CONSOL(CONSPK_CONSOL),
                                  .timer4Pending(timer1_int),.timer2Pending(timer2_int),.timer1Pending(timer4_int), .POTGO_strobe(POTGO_strobe),

                                   .IRQ_ST(IRQST_BUS), .POT0_bus(POT0_BUS), .POT1_bus(POT0_BUS), .POT2_bus(POT0_BUS), .POT3_bus(POT0_BUS), .ALLPOT_bus(ALLPOT_BUS), 
                                   .KBCODE_bus(KBCODE_BUS), .SKSTAT_bus(SKSTAT_BUS), .TRIG0_bus(TRIG0_BUS), .TRIG1_bus(TRIG1_BUS), .TRIG2_bus(TRIG2_BUS), .TRIG3_bus(TRIG3_BUS), 
								   .HDR2_2(HDR2_2), .HDR2_4(HDR2_4), .HDR2_6(HDR2_6), .HDR2_8(HDR2_8), .HDR1_60(HDR1_60), .HDR1_62(HDR1_62), .HDR1_64(HDR1_64),.IRQ_L(IRQ_L));
	 
	assign GPIO_LED_0 = TRIG0_BUS;
    assign GPIO_LED_1 = TRIG1_BUS;
    assign {GPIO_LED_5,GPIO_LED_6,GPIO_LED_7,GPIO_LED_8} = KBCODE_BUS[4:1];

    wire [15:0] cartROMadd;
    assign cartROMadd = (memAdd - 16'h4000);
    
    // Soft Cartridge ROM instantiation
    //memDefender memD(.clka(fphi0),.addra(cartROMadd[14:0]),.douta(data_CART));
    memMario    memM(.clka(fphi0),.addra(cartROMadd[14:0]),.douta(data_CART));
    
    wire [7:0] NMIRES_NMIST, VCOUNT_val; //
    wire [7:0] data_in_b;
    wire write_RAM;

    memoryMap map(.write_RAM(write_RAM),.data_in_b(data_in_b),

                  .addr_RAM(addr_RAM),.addr_BIOS(addr_BIOS),.addr_CART(addr_CART),
                  .latchClk(fphi0X2), .Fclk(fphi0), .clk(fphi0), .rst(rst), .CPU_writeEn(~RW), .CPU_addr(memAdd), 
                  .data_CART_out(data_CART), .CPU_data(extDB),

                  .AUDF1(AUDF1), .AUDC1(AUDC1), .AUDF2(AUDF2), .AUDC2(AUDC2), 
                  .AUDF3(AUDF3), .AUDC3(AUDC3), .AUDF4(AUDF4), .AUDC4(AUDC4), .AUDCTL(AUDCTL),.SKCTL(SKCTL),.IRQEN(IRQEN),     
                  .IRQST_BUS(IRQST_BUS),.POT0_BUS(POT0_BUS), .POT1_BUS(POT1_BUS), .POT2_BUS(POT2_BUS), .POT3_BUS(POT3_BUS),
                  .ALLPOT_BUS(ALLPOT_BUS), .KBCODE_BUS(KBCODE_BUS), .SKSTAT_BUS(SKSTAT_BUS),
                  .TRIG0_BUS(TRIG0_BUS),.TRIG1_BUS(TRIG1_BUS),.TRIG2_BUS(TRIG2_BUS),.TRIG3_BUS(TRIG3_BUS),.RANDOM_BUS(RANDOM_BUS),
                  .STIMER_strobe(STIMER_strobe),.POTGO_strobe(POTGO_strobe),

                  .ANTIC_writeEn(ANTIC_writeEn), .GTIA_writeEn(5'd0),
                  .VCOUNT_in(VCOUNT), .PENH_in(PENH), .PENV_in(PENV), 
                  .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
                  .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
                  .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
                  .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
                  .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
                  .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus),
                  .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
                  .COLPM0_TRIG2_bus(COLPM0_TRIG2_bus), .COLPM1_TRIG3_bus(COLPM1_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus),
                  .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus), .DMACTL(DMACTL), .CHACTL(CHACTL), .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE),
                  .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2),
                  .COLPF3(COLPF3), .COLBK(COLBK), .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
                  .NMIRES_NMIST(NMIRES_NMIST), .VCOUNT(VCOUNT_val),.CONSPK_CONSOL(CONSPK_CONSOL));


    /*-------------------------------------------------------------*/
    // cpu stuff
   
    wire [6:0] currT, currT_b;

    wire [7:0] DB, ADH, ADL, SB;
    
    wire [2:0] activeInt;

    wire [7:0] ALUhold_out;
    wire rstAll,nmiPending,resPending,irqPending;
    wire [7:0] idlContents,A,B,outToPCL,outToPCH,accumVal;
    wire [1:0] currState;
    wire [7:0] second_first_int;
    wire [7:0] OP,opcodeToIR,prevOpcode;
    wire [7:0] Accum,Xreg,Yreg;
    wire [7:0] DBforSR,extAB_b1,SRflags,holdAB,SR_contents;
    wire haltAll;
	top_6502C cpu(.DBforSR(DBforSR),.prevOpcode(prevOpcode),.extAB_b1(extAB_b1),.SR_contents(SR_contents),.holdAB(holdAB),
                .SRflags(SRflags),.opcode(OP),.opcodeToIR(opcodeToIR),.second_first_int(second_first_int),.nmiPending(nmiPending),
                .resPending(resPending),.irqPending(irqPending),.currState(currState),.accumVal(accumVal),
                .outToPCL(outToPCL),.outToPCH(outToPCH),.A(A),.B(B),.idlContents(idlContents),.rstAll(rstAll),.ALUhold_out(ALUhold_out),
                .activeInt(activeInt),.currT(currT),
                
                .DB(DB),.SB(SB),.ADH(ADH),.ADL(ADL),
                .HALT(HALT),.IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .phi0_in(phi0_in),.fastClk(fphi0),
                .RDY(RDY),.extDB(extDB), .phi1_out(phi1_out), .phi2_out(phi2_out),.SYNC(SYNC), .extABH(extABH),.extABL(extABL),  .RW(RW),
                .Accum(Accum),.Xreg(Xreg),.Yreg(Yreg));
           
 /*-------------------------------------------------------------*/
    // chipscope stuff

    
    //need counter to check how many types it's been at an address!
    //sense outToPCH and outToPCL
    
    // wire [7:0] TRIG0,TRIG1,TRIG2,TRIG3,TRIG4,TRIG5,TRIG6,TRIG7,TRIG8,TRIG9,TRIG10,TRIG11,TRIG12,TRIG13,TRIG14,TRIG15;
    
    
    wire chipClk_b;

    clockoneX #(.width(`DIV-3))  test12(CLK_27MHZ_FPGA,chipClk_b);
    
    wire [35:0] CONTROL0, CONTROL1, CONTROL2;
    
    chipscope_ila ila0(
    CONTROL0,
    chipClk_b,
    memAdd[15:8],
    memAdd[7:0],
    extDB,
    {1'b0,currT},
    DB,
    ADH,
    ADL,
    SB,
    {7'd0,phi1_out},
    {RW,activeInt,RDY,IRQ_L,NMI_L,RES_L},
    Accum,
    Xreg,
    SR_contents,
    OP,
    Yreg,
    data_CART2);

    
    chipscope_ila_graphics ila2 (
      .CONTROL(CONTROL2), // INOUT BUS [35:0]
      .CLK(chipClk_b), // IN
      .TRIG0(AN), // IN BUS [3:0]
      .TRIG1(IR), // IN BUS [7:0]
      .TRIG2(currStateANTIC), // IN BUS [1:0]
      .TRIG3({1'b0, ANTIC_writeEn}), // IN BUS [3:0]
      .TRIG4(dlist), // IN BUS [15:0]
      .TRIG5(MSR), // IN BUS [15:0]
      .TRIG6(dBuf_data), // IN BUS [31:0]
      .TRIG7(dBuf_writeEn), // IN BUS [0:0]
      .TRIG8(x), // IN BUS [8:0]
      .TRIG9(y), // IN BUS [7:0]
      .TRIG10(Fphi0), // IN BUS [0:0]
      .TRIG11(IR_rdy), // IN BUS [0:0]
      .TRIG12(MSRdata),
      .TRIG13(address),
      .TRIG14(extDB),
      .TRIG15(ANTIC_writeNMI)
    );

    // extra ila for use...
    chipscope_ila ila1(
    CONTROL1,
    chipClk_b,
    KBCODE_BUS,
    ALLPOT_BUS,
    POT0_BUS,
    POT1_BUS,
    {cIn,cOut},
    {4'd0,keyscan},
    IRQST_BUS,
    IRQEN,
    SKSTAT_BUS,
    SKCTL,
    GRACTL,
    CONSPK_CONSOL,
    {7'd0,STIMER_strobe},
    8'd0,
    8'd0,
    8'd0);
    
    chipscope_icon3 icon(
      .CONTROL0(CONTROL0),
      .CONTROL1(CONTROL1),
      .CONTROL2(CONTROL2)
    );
    

endmodule


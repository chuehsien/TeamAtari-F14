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
`include "Graphics/ANTIC.v"
`include "Graphics/GTIA.v"
`include "Graphics/DVI.v"

`define DIV 8'd4 

module Atari5200(CLK_27MHZ_FPGA, USER_CLK, GPIO_SW_E, GPIO_SW_S, GPIO_SW_N, GPIO_SW_W,
                 GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4,
                 GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8,
                 HDR1_34,HDR1_36,HDR1_38,HDR1_40,HDR1_42,HDR1_44,HDR1_46,HDR1_48,
                 
                 IIC_SDA_VIDEO, IIC_SCL_VIDEO, 
                 
                 HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_10, HDR1_12, HDR1_14, HDR1_16, 
                 HDR1_18, HDR1_20, HDR1_22, HDR1_24, HDR1_26, HDR1_28, HDR1_30, HDR1_32,
                 HDR1_50,HDR1_52,HDR1_54,HDR1_56,
                 HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P,
                 HDR2_42_SM_14_N, HDR2_44_SM_14_P, HDR2_46_SM_12_N, HDR2_48_SM_12_P,
                 HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P,
                 HDR2_58_SM_4_N, HDR2_60_SM_4_P, HDR2_62_SM_9_N, HDR2_64_SM_9_P,
                 
                 DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5,
                 DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0, DVI_XCLK_P, DVI_XCLK_N,
                 DVI_V, DVI_H, DVI_DE, DVI_RESET_B);

	input	 CLK_27MHZ_FPGA, USER_CLK;
	input	 GPIO_SW_E, GPIO_SW_S,  GPIO_SW_N, GPIO_SW_W;
	input  GPIO_DIP_SW1, GPIO_DIP_SW2, GPIO_DIP_SW3, GPIO_DIP_SW4, 
         GPIO_DIP_SW5, GPIO_DIP_SW6, GPIO_DIP_SW7, GPIO_DIP_SW8;
  input  HDR1_34, HDR1_36, HDR1_38, HDR1_40, HDR1_42, HDR1_44, HDR1_46, HDR1_48;
  
  inout  IIC_SDA_VIDEO, IIC_SCL_VIDEO;
    
	output HDR1_2, HDR1_4, HDR1_6, HDR1_8, HDR1_10, HDR1_12, HDR1_14, HDR1_16, 
           HDR1_18, HDR1_20, HDR1_22, HDR1_24, HDR1_26, HDR1_28, HDR1_30, HDR1_32,
	       HDR1_50,HDR1_52,HDR1_54,HDR1_56,
           HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P,
           HDR2_42_SM_14_N, HDR2_44_SM_14_P, HDR2_46_SM_12_N, HDR2_48_SM_12_P,
           HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P,
           HDR2_58_SM_4_N, HDR2_60_SM_4_P, HDR2_62_SM_9_N, HDR2_64_SM_9_P;
           
  output DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6,
         DVI_D5, DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0,
         DVI_XCLK_P, DVI_XCLK_N, DVI_V, DVI_H, DVI_DE, DVI_RESET_B;

	wire writeStart;
	wire writeDone;
	wire initDone;
	wire clearAll;
	wire resetFSM;
  wire HALT, RDY, IRQ_L, NMI_L, RES_L, SO;
  wire phi1_out,phi2_out,SYNC,RW;
  wire [7:0] extABH,extABL,extDB; 
  wire [7:0] extABH_b,extABL_b,extDB_b;
  
  wire phi0_in, fphi0;
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
	
    /*
    triState8 busDriver(extDB,memOut_b,RW);
  
    memTestFull2 mem( 
      .clka(memReadClock), // input clka
      .wea(~RW), // input [0 : 0] wea
      .addra(memAdd), // input [15 : 0] addra
      .dina(extDB), // input [7 : 0] dina
      .douta(memOut_b) // output [7 : 0] douta
    );
    */
    
    assign IRQ_L = 1'b1;
    wire nRES_L,nNMI_L;
    assign RES_L = ~nRES_L;
    //assign NMI_L = ~GPIO_SW_N;
    //assign NMI_L = ~clk60; //VBI every 1/60seconds
    DeBounce #(.N(8)) resB(fphi0,1'b1,GPIO_SW_W,nRES_L);
    //DeBounce #(.N(8)) nmiB(fphi0,1'b1,GPIO_SW_N,nNMI_L);
    //DeBounce #(.N(8)) haltiB(fphi0,1'b1,GPIO_SW_E,HALT);

    // Graphics components
    wire Fphi0;
    wire phi2;
    wire clk_DVI;
    wire clk_half;
    wire rst = nRES_L;
    wire request;
    wire [63:0] doutB;
    wire [11:0] DVI_D;

    reg [14:0] addrB = 15'd0;
    
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
    
    // GTIA to memoryMap wires
    wire [7:0] COLPM3;
    wire [7:0] COLPF0;
    wire [7:0] COLPF1;
    wire [7:0] COLPF2;
    wire [7:0] COLPF3;
    wire [7:0] COLBK;
    wire [7:0] PRIOR;
    wire [7:0] VDELAY;
    wire [7:0] GRACTL;
    wire [7:0] HITCLR;
    wire [7:0] HPOSP0_M0PF_bus;
    wire [7:0] HPOSP1_M1PF_bus;
    wire [7:0] HPOSP2_M2PF_bus;
    wire [7:0] HPOSP3_M3PF_bus;
    wire [7:0] HPOSM0_P0PF_bus;
    wire [7:0] HPOSM1_P1PF_bus;
    wire [7:0] HPOSM2_P2PF_bus;
    wire [7:0] HPOSM3_P3PF_bus;
    wire [7:0] SIZEP0_M0PL_bus;
    wire [7:0] SIZEP1_M1PL_bus;
    wire [7:0] SIZEP2_M2PL_bus;
    wire [7:0] SIZEP3_M3PL_bus;
    wire [7:0] SIZEM_P0PL_bus;
    wire [7:0] GRAFP0_P1PL_bus;
    wire [7:0] GRAFP1_P2PL_bus;
    wire [7:0] GRAFP2_P3PL_bus;
    wire [7:0] GRAFP3_TRIG0_bus;
    wire [7:0] GRAFPM_TRIG1_bus;
    wire [7:0] COLPM0_TRIG2_bus;
    wire [7:0] COLPM1_TRIG3_bus;
    wire [7:0] COLPM2_PAL_bus;
    wire [7:0] CONSPK_CONSOL_bus;
    
    wire [31:0] dBuf_data;
    wire [15:0] dBuf_addr;
    wire dBuf_writeEn;
    
    wire [7:0] DMACTL;
    wire [7:0] CHACTL;
    wire [7:0] HSCROL;
    wire [7:0] VSCROL;
    wire [7:0] PMBASE;
    wire [7:0] CHBASE;
    wire [7:0] WSYNC;
    wire [7:0] NMIEN;
    wire [7:0] NMIRES_NMIST_bus;
    wire [7:0] DLISTL_bus;
    wire [7:0] DLISTH_bus;
    wire [7:0] VCOUNT;
    wire [7:0] PENH;
    wire [7:0] PENV;
    wire [2:0] ANTIC_writeEn;
    
    wire [3:0] AN;
    wire [15:0] address = {extABH, extABL};
    wire charMode;
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

    // Module instantiation
    ANTIC antic(.Fphi0(Fphi0), .LP_L(), .RW(), .rst(rst), .vblank(vblank), .hblank(hblank), .DMACTL(DMACTL), .CHACTL(CHACTL),
                .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE), .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), 
                .DB(extDB), .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
                .address(address), .AN(AN), .halt(HALT), .NMI_L(NMI_L), .RDY(RDY), .REF_L(), .RNMI_L(), .phi0(), 
                .IR_out(IR), .loadIR(), .VCOUNT(VCOUNT), .PENH(PENH), .PENV(PENV), .ANTIC_writeEn(ANTIC_writeEn), 
                .charMode(charMode), .numLines(numLines), .width(width), .height(height),
                .printDLIST(dlist), .currState(currStateANTIC), .MSR(MSR), .loadDLIST_both(), 
                .loadMSR_both(), .IR_rdy(IR_rdy), .mode(mode), .numBytes(), .MSRdata(MSRdata), 
                .DLISTL(DLISTL), .blankCount(), .addressIn(), .loadMSRdata(),
                .charData(), .newDLISTptr(), .loadDLIST(), .DLISTend(DLISTend), 
                .idle(idle), .loadMSRstate(loadMSRstate), .addressOut(addressOut), .haltANTIC(haltANTIC), .rdyANTIC(rdyANTIC));
    
    GTIA gtia(.address(), .AN(AN), .CS(), .DEL(), .OSC(), .RW(), .trigger(), .Fphi0(Fphi0), .rst(rst), .charMode(charMode),
              .DLISTend(DLISTend), .numLines(numLines), .width(width), .height(height),
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
              .vblank(vblank), .hblank(hblank), .x(x), .y(y));
                 

    displayBlockMem dbm(.clka(Fphi0), .wea(dBuf_writeEn), .addra(dBuf_addr), .dina(dBuf_data), .clkb(clk_DVI),
                        .addrb(addrB), .doutb(doutB));
    
    DVI dvi(.clock(clk_DVI), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
            .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
            .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
            .request(request));
    
    // FSM to control DVI reads from port B
    always @(posedge request or posedge nRES_L) begin
      if (nRES_L) begin
        addrB <= 15'd0;
      end
      else begin
        if (addrB >= 15'd30719)
          addrB <= 15'd0;
        else
          addrB <= addrB + 15'd1;
      end
    end

   
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
    wire [7:0] POT0_BUS, POT1_BUS, POT2_BUS, POT3_BUS, POT4_BUS, POT5_BUS, POT6_BUS, POT7_BUS, ALLPOT_BUS, KBCODE_BUS, RANDOM_BUS;
    
    assign HDR1_50 = audio1;
    assign HDR1_52 = audio2;
    assign HDR1_54 = audio3;
    assign HDR1_56 = audio4;
    
    assign {HDR2_34_SM_15_N, HDR2_36_SM_15_P, HDR2_38_SM_6_N, HDR2_40_SM_6_P} = vol1;
    assign {HDR2_48_SM_12_P,HDR2_46_SM_12_N,HDR2_44_SM_14_P,HDR2_42_SM_14_N} = vol2;
    assign {HDR2_50_SM_5_N, HDR2_52_SM_5_P, HDR2_54_SM_13_N,HDR2_56_SM_13_P} = vol3;
    assign {HDR2_64_SM_9_P,HDR2_62_SM_9_N,HDR2_60_SM_4_P,HDR2_58_SM_4_N} = vol4;


    pokeyaudio pokey(.init_L(RES_L),.clk179(fphi0),.clk64(clk64),.clk16(clk16),
                    .AUDF1(AUDF1),.AUDF2(AUDF2),.AUDF3(AUDF3),.AUDF4(AUDF4),
                    .AUDC1(AUDC1),.AUDC2(AUDC2),.AUDC3(AUDC3),.AUDC4(AUDC4),.AUDCTL(AUDCTL),
                    .audio1(audio1),.audio2(audio2),.audio3(audio3),.audio4(audio4),
                    .vol1(vol1),.vol2(vol2),.vol3(vol3),.vol4(vol4),.RANDOM(RANDOM_BUS));
    
      
    wire [15:0] cartROMadd;
    assign cartROMadd = (memAdd - 16'h4000);
    memDefender memD(.clka(memReadClock),.addra(cartROMadd[14:0]),.douta(data_CART));

    memoryMap map(.addr_RAM(addr_RAM),.addr_BIOS(addr_BIOS),.addr_CART(addr_CART),
                  .Fclk(memReadClock), .clk(memReadClock), .rst(rst), .CPU_writeEn(~RW), .CPU_addr(memAdd), 
                  .data_CART_out(data_CART), .CPU_data(extDB),
                  .AUDF1(AUDF1), .AUDC1(AUDC1), .AUDF2(AUDF2), .AUDC2(AUDC2), 
                  .AUDF3(AUDF3), .AUDC3(AUDC3), .AUDF4(AUDF4), .AUDC4(AUDC4), .AUDCTL(AUDCTL),
                  .POT0_BUS(POT0_BUS), .POT1_BUS(POT1_BUS), .POT2_BUS(POT2_BUS), .POT3_BUS(POT3_BUS),
                  .POT4_BUS(POT4_BUS), .POT5_BUS(POT5_BUS), .POT6_BUS(POT6_BUS), .POT7_BUS(POT7_BUS),
                  .ALLPOT_BUS(ALLPOT_BUS), .KBCODE_BUS(KBCODE_BUS), .RANDOM_BUS(RANDOM_BUS),
                  
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
                  .COLPF3(COLPF3), .COLBK(COLBK), .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR));


    /*-------------------------------------------------------------*/
    // cpu stuff

    /*
    DeBounce #(.N(8)) rdyB(fphi0,1'b1,GPIO_DIP_SW1,HALT);
    DeBounce #(.N(8)) irqB(fphi0,1'b1,GPIO_DIP_SW2,IRQ_L);
    DeBounce #(.N(8)) nmiB(fphi0,1'b1,GPIO_DIP_SW3,NMI_L);
    DeBounce #(.N(8)) resB(fphi0,1'b1,GPIO_DIP_SW4,RES_L);
    */
    
   // not invAgain[3:0]({RDY,IRQ_L,NMI_L,RES_L},{nRDY,nIRQ_L,nNMI_L,nRES_L});
	assign SO = 1'b0;
    
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
                .HALT(HALT),.IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in),.fastClk(fastClk),
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
    {6'd0,HALT,haltAll},
    OP,
    Yreg,
    SRcontents);

    
    chipscope_ila_graphics ila2 (
      .CONTROL(CONTROL2), // INOUT BUS [35:0]
      .CLK(chipClk_b), // IN
      .TRIG0(AN), // IN BUS [3:0]
      .TRIG1(IR), // IN BUS [7:0]
      .TRIG2(currStateANTIC), // IN BUS [1:0]
      .TRIG3(mode), // IN BUS [3:0]
      .TRIG4(dlist), // IN BUS [15:0]
      .TRIG5(dBuf_addr), // IN BUS [15:0]
      .TRIG6(dBuf_data), // IN BUS [31:0]
      .TRIG7(dBuf_writeEn), // IN BUS [0:0]
      .TRIG8(x), // IN BUS [8:0]
      .TRIG9(y), // IN BUS [7:0]
      .TRIG10(Fphi0), // IN BUS [0:0]
      .TRIG11(IR_rdy), // IN BUS [0:0]
      .TRIG12(MSRdata),
      .TRIG13(address),
      .TRIG14(extDB),
      .TRIG15(haltANTIC)
    );

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
    
    chipscope_icon3 icon(
      .CONTROL0(CONTROL0),
      .CONTROL1(CONTROL1),
      .CONTROL2(CONTROL2)
    );
    

endmodule


// Top module linking ANTIC, GTIA, display buffer RAM, and DVI output
// last updated: 10/13/2014 2200H

`include "ANTIC.v"
`include "GTIA.v"
`include "memoryMap.v"
`include "DVI.v"

module display(USER_CLK, GPIO_SW_C, IIC_SDA_VIDEO, IIC_SCL_VIDEO,
               DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5,
               DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0, DVI_XCLK_P, DVI_XCLK_N,
               DVI_V, DVI_H, DVI_DE, DVI_RESET_B);
  
  input USER_CLK;
  input GPIO_SW_C;
  
  inout IIC_SDA_VIDEO;
  inout IIC_SCL_VIDEO;

  output DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6,
         DVI_D5, DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0;
  output DVI_XCLK_P, DVI_XCLK_N;
  output DVI_V, DVI_H;
  output DVI_DE;
  output DVI_RESET_B;
  
  wire Fphi0;
  wire phi2;
  wire clk_DVI;
  wire rst;
  wire request;
  wire [63:0] doutB;
  wire [11:0] DVI_D;
  
  reg [5:0] clkdiv;
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
  
  assign Fphi0 = clkdiv[5]; // 3.125 MHz
  assign clk_DVI = clkdiv[1]; // 50 MHz
  assign rst = GPIO_SW_C;
  
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
  wire [7:0] DB;
  wire [15:0] address;
  wire charMode;
  wire vblank, hblank;
  wire [1:0] numLines;
  wire [8:0] width;
  wire [7:0] height;
  
  //TEMP
  wire [7:0] IR;
  wire [1:0] currState;
  wire [3:0] mode;
  wire IR_rdy;
  wire [15:0] dlist;
  wire [7:0] DLISTL;
  wire idle;
  wire [15:0] MSR;
  wire [1:0] loadMSRstate;
  wire DLISTend;

  // Module instantiation
  ANTIC antic(.Fphi0(Fphi0), .LP_L(), .RW(), .rst(rst), .vblank(vblank), .hblank(hblank), .DMACTL(DMACTL), .CHACTL(CHACTL),
              .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE), .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), 
              .DB(DB), .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
              .address(address), .AN(AN), .halt_L(), .NMI_L(), .RDY_L(), .REF_L(), .RNMI_L(), .phi0(), 
              .IR_out(IR), .loadIR(), .VCOUNT(VCOUNT), .PENH(PENH), .PENV(PENV), .ANTIC_writeEn(ANTIC_writeEn), 
              .charMode(charMode), .numLines(numLines), .width(width), .height(height),
              .printDLIST(dlist), .currState(currState), .data(), .MSR(MSR), .loadDLIST_both(), 
              .loadMSR_both(), .IR_rdy(IR_rdy), .mode(mode), .numBytes(), .MSRdata(), 
              .DLISTL(DLISTL), .blankCount(), .addressIn(), .loadMSRdata(),
              .charData(), .newDLISTptr(), .loadDLIST(), .DLISTend(DLISTend), 
              .idle(idle), .loadMSRstate(loadMSRstate));
  
  GTIA gtia(.address(), .AN(AN), .CS(), .DEL(), .OSC(), .RW(), .trigger(), .Fphi0(Fphi0), .rst(rst), .charMode(charMode),
            .DLISTend(DLISTend), .numLines(numLines), .width(width), .height(height),
            .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2), .COLPF3(COLPF3), .COLBK(COLBK),
            .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
            .DB(), .switch(),
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
            .vblank(vblank), .hblank(hblank));
               
  memoryMap map(.Fclk(~Fphi0), .clk(phi2), .rst(rst), .CPU_writeEn(1'b0), .ANTIC_writeEn(ANTIC_writeEn), .GTIA_writeEn(5'd0),
                .CPU_addr(address), .VCOUNT_in(VCOUNT), .PENH_in(PENH), .PENV_in(PENV), .CPU_data(DB), 
                .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
                .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
                .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
                .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
                .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
                .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus),
                .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
                .COLPM0_TRIG2_bus(COLPM0_TRIG2_bus), .COLPM1_TRIG3_bus(COLPM1_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus),
                .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus),
                .DMACTL(DMACTL), .CHACTL(CHACTL), .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE),
                .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2),
                .COLPF3(COLPF3), .COLBK(COLBK), .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
                .NMIRES_NMIST(NMIRES_NMIST));

  displayBlockMem dbm(.clka(Fphi0), .wea(dBuf_writeEn), .addra(dBuf_addr), .dina(dBuf_data), .clkb(clk_DVI),
                      .addrb(addrB), .doutb(doutB));
  
  DVI dvi(.clock(clk_DVI), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
          .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
          .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
          .request(request));
  

  // Chipscope (temporary)
  
  wire [35:0] CONTROL0;
  
  chipscope_icon icon (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
  );
  
  chipscope_ila ila (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(clk_DVI), // IN
    .TRIG0({1'b0, ANTIC_writeEn}), // IN BUS [3:0]
    .TRIG1(IR), // IN BUS [7:0]
    .TRIG2(currState), // IN BUS [1:0]
    .TRIG3(mode), // IN BUS [3:0]
    .TRIG4(dlist), // IN BUS [15:0]
    .TRIG5(COLPF0), // IN BUS [7:0]
    .TRIG6(NMIRES_NMIST_bus), // IN BUS [7:0]
    .TRIG7(NMIRES_NMIST), // IN BUS [7:0]
    .TRIG8(idle), // IN BUS [0:0]
    .TRIG9(IR_rdy) // IN BUS [0:0]
  );
  
  // End Chipscope


  // FSM to control DVI reads from port B
  always @(posedge request or posedge rst) begin
    if (rst) begin
      addrB <= 15'd0;
    end
    else begin
      if (addrB >= 15'd30719)
        addrB <= 15'd0;
      else
        addrB <= addrB + 15'd1;
    end
  end
  
  always @(posedge USER_CLK) begin
    if (clkdiv == 6'd63)
      clkdiv <= 6'd0;
    else
      clkdiv <= clkdiv + 6'd1;
  end
  
endmodule
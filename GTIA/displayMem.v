// Top module linking display buffer RAM and DVI output
// last updated: 10/13/2014 2200H

module displayMem(USER_CLK, GPIO_SW_C, IIC_SDA_VIDEO, IIC_SCL_VIDEO,
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
  
  wire clkA;
  wire clkB;
  wire rst;
  wire request;
  wire [63:0] doutB;
  wire [11:0] DVI_D;
  
  reg [5:0] clkdiv;
  reg [14:0] addrB;
  
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
  
  assign clkA = clkdiv[5]; // 3.125 MHz
  assign clkB = clkdiv[1]; // 50 MHz
  assign rst = ~GPIO_SW_C;
  
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
  
  reg [2:0] AN = 3'b000;

  // Module instantiation
  GTIA gtia(.address(), .AN(AN), .CS(), .DEL(), .OSC(), .RW(), .trigger(), .Fphi0(clkA), .rst(rst), 
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
            .COL(), .CSYNC(), .phi2(), .HALT(), .L(),
            .dBuf_data(dBuf_data), .dBuf_addr(dBuf_addr), .dBuf_writeEn(dBuf_writeEn));
               
  memoryMap map(.clk(clkA), .CPU_writeEn(), .ANTIC_writeEn(), .GTIA_writeEn(),
                .CPU_addr(CPU_addr), .VCOUNT_in(), .PENH_in(), .PENV_in(), .CPU_data(), 
                .NMIRES_NMIST_bus(), .DLISTL_bus(), .DLISTH_bus(),
                .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
                .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
                .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
                .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
                .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus),
                .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
                .COLPM0_TRIG2_bus(COLPM0_TRIG2_bus), .COLPM1_TRIG3_bus(COLPM1_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus),
                .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus),
                .DMACTL(), .CHACTL(), .HSCROL(), .VSCROL(), .PMBASE(),
                .CHBASE(), .WSYNC(), .NMIEN(), .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2),
                .COLPF3(COLPF3), .COLBK(COLBK), .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR));

  displayBlockMem dbm(.clka(clkA), .wea(dBuf_writeEn), .addra(dBuf_addr), .dina(dBuf_data), .clkb(clkB),
                      .addrb(addrB), .doutb(doutB));
  
  DVI dvi(.clock(clkB), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
          .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
          .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
          .request(request));

  // FSM to control DVI reads from port B
  always @(posedge request or posedge rst) begin
    if (rst) begin
      addrB <= 15'd0;
    end
    else begin
      if (addrB == 15'd30719)
        addrB <= 15'd0;
      else
        addrB <= addrB + 15'd1;
    end
  end
  
  always @(posedge USER_CLK or negedge USER_CLK) begin
    if (clkdiv == 6'd63)
      clkdiv <= 6'd0;
    else
      clkdiv <= clkdiv + 6'd1;
  end
  
endmodule
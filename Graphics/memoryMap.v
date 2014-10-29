// Memory mapping module
// Last updated: 10/22/2014 2040H


module memoryMap(Fclk, clk, rst, CPU_writeEn, ANTIC_writeEn, GTIA_writeEn, CPU_addr, VCOUNT_in, PENH_in, PENV_in,
                 CPU_data, NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, HPOSP0_M0PF_bus, HPOSP1_M1PF_bus,
                 HPOSP2_M2PF_bus, HPOSP3_M3PF_bus, HPOSM0_P0PF_bus, HPOSM1_P1PF_bus, HPOSM2_P2PF_bus,
                 HPOSM3_P3PF_bus, SIZEP0_M0PL_bus, SIZEP1_M1PL_bus, SIZEP2_M2PL_bus, SIZEP3_M3PL_bus,
                 SIZEM_P0PL_bus, GRAFP0_P1PL_bus, GRAFP1_P2PL_bus, GRAFP2_P3PL_bus, GRAFP3_TRIG0_bus,
                 GRAFPM_TRIG1_bus, COLPM0_TRIG2_bus, COLPM1_TRIG3_bus, COLPM2_PAL_bus, CONSPK_CONSOL_bus,
                 DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, WSYNC, NMIEN, COLPM3, COLPF0, COLPF1, COLPF2, 
                 COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR, NMIRES_NMIST);
  
  // Control signals
  input Fclk;
  input clk;
  input rst;
  input CPU_writeEn;
  input [2:0] ANTIC_writeEn;
  input [4:0] GTIA_writeEn;
  input [15:0] CPU_addr;
  
  // ANTIC inputs
  input [7:0] VCOUNT_in;
  input [7:0] PENH_in;
  input [7:0] PENV_in;
  
  // ANTIC inouts
  inout [7:0] CPU_data;
  inout [7:0] NMIRES_NMIST_bus;
  inout [7:0] DLISTL_bus;
  inout [7:0] DLISTH_bus;
  
  // GTIA inouts
  inout [7:0] HPOSP0_M0PF_bus;
  inout [7:0] HPOSP1_M1PF_bus;
  inout [7:0] HPOSP2_M2PF_bus;
  inout [7:0] HPOSP3_M3PF_bus;
  inout [7:0] HPOSM0_P0PF_bus;
  inout [7:0] HPOSM1_P1PF_bus;
  inout [7:0] HPOSM2_P2PF_bus;
  inout [7:0] HPOSM3_P3PF_bus;
  inout [7:0] SIZEP0_M0PL_bus;
  inout [7:0] SIZEP1_M1PL_bus;
  inout [7:0] SIZEP2_M2PL_bus;
  inout [7:0] SIZEP3_M3PL_bus;
  inout [7:0] SIZEM_P0PL_bus;
  inout [7:0] GRAFP0_P1PL_bus;
  inout [7:0] GRAFP1_P2PL_bus;
  inout [7:0] GRAFP2_P3PL_bus;
  inout [7:0] GRAFP3_TRIG0_bus;
  inout [7:0] GRAFPM_TRIG1_bus;
  inout [7:0] COLPM0_TRIG2_bus;
  inout [7:0] COLPM1_TRIG3_bus;
  inout [7:0] COLPM2_PAL_bus;
  inout [7:0] CONSPK_CONSOL_bus;
  
  // ANTIC outputs
  output [7:0] DMACTL;
  output [7:0] CHACTL;
  output [7:0] HSCROL;
  output [7:0] VSCROL;
  output [7:0] PMBASE;
  output [7:0] CHBASE;
  output [7:0] WSYNC;
  output [7:0] NMIEN;
  
  // GTIA outputs
  output [7:0] COLPM3;
  output [7:0] COLPF0;
  output [7:0] COLPF1;
  output [7:0] COLPF2;
  output [7:0] COLPF3;
  output [7:0] COLBK;
  output [7:0] PRIOR;
  output [7:0] VDELAY;
  output [7:0] GRACTL;
  output [7:0] HITCLR;
  
  output [7:0] NMIRES_NMIST;
  
  // ANTIC hardware registers
  reg [7:0] DMACTL = 8'h22;       // | $D400 | Write      |                   |
  reg [7:0] CHACTL;       // | $D401 | Write      |                   |
  reg [7:0] DLISTL = 8'h03;       // | $D402 | Write/Read | ANTIC_writeEn 1/2 |
  reg [7:0] DLISTH = 8'hA0;       // | $D403 | Write/Read | ANTIC_writeEn 2   |
  reg [7:0] HSCROL;       // | $D404 | Write      |                   |
  reg [7:0] VSCROL;       // | $D405 | Write      |                   |
  reg [7:0] PMBASE;       // | $D407 | Write      |                   |
  reg [7:0] CHBASE = 8'hf8;       // | $D409 | Write      |                   |
  reg [7:0] WSYNC;        // | $D40A | Write      |                   |
  reg [7:0] VCOUNT;       // | $D40B | Read       | ANTIC_writeEn 3   |
  reg [7:0] PENH;         // | $D40C | Read       | ANTIC_writeEn 4   |
  reg [7:0] PENV;         // | $D40D | Read       | ANTIC_writeEn 5   |
  reg [7:0] NMIEN;        // | $D40E | Write      |                   |
  reg [7:0] NMIRES_NMIST = 8'h00; // | $D40F | Write/Read | ANTIC_writeEn 6   | 
  
  // GTIA hardware registers
  reg [7:0] HPOSP0_M0PF;  // | $D000 | Write/Read | GTIA_writeEn 1  | 
  reg [7:0] HPOSP1_M1PF;  // | $D001 | Write/Read | GTIA_writeEn 2  |
  reg [7:0] HPOSP2_M2PF;  // | $D002 | Write/Read | GTIA_writeEn 3  |
  reg [7:0] HPOSP3_M3PF;  // | $D003 | Write/Read | GTIA_writeEn 4  |
  reg [7:0] HPOSM0_P0PF;  // | $D004 | Write/Read | GTIA_writeEn 5  |
  reg [7:0] HPOSM1_P1PF;  // | $D005 | Write/Read | GTIA_writeEn 6  |
  reg [7:0] HPOSM2_P2PF;  // | $D006 | Write/Read | GTIA_writeEn 7  |
  reg [7:0] HPOSM3_P3PF;  // | $D007 | Write/Read | GTIA_writeEn 8  |
  reg [7:0] SIZEP0_M0PL;  // | $D008 | Write/Read | GTIA_writeEn 9  |
  reg [7:0] SIZEP1_M1PL;  // | $D009 | Write/Read | GTIA_writeEn 10 |
  reg [7:0] SIZEP2_M2PL;  // | $D00A | Write/Read | GTIA_writeEn 11 |
  reg [7:0] SIZEP3_M3PL;  // | $D00B | Write/Read | GTIA_writeEn 12 |
  reg [7:0] SIZEM_P0PL;   // | $D00C | Write/Read | GTIA_writeEn 13 |
  reg [7:0] GRAFP0_P1PL;  // | $D00D | Write/Read | GTIA_writeEn 14 |
  reg [7:0] GRAFP1_P2PL;  // | $D00E | Write/Read | GTIA_writeEn 15 |
  reg [7:0] GRAFP2_P3PL;  // | $D00F | Write/Read | GTIA_writeEn 16 |
  reg [7:0] GRAFP3_TRIG0; // | $D010 | Write/Read | GTIA_writeEn 17 |
  reg [7:0] GRAFPM_TRIG1; // | $D011 | Write/Read | GTIA_writeEn 18 |
  reg [7:0] COLPM0_TRIG2; // | $D012 | Write/Read | GTIA_writeEn 19 |
  reg [7:0] COLPM1_TRIG3; // | $D013 | Write/Read | GTIA_writeEn 20 |
  reg [7:0] COLPM2_PAL;   // | $D014 | Write/Read | GTIA_writeEn 21 |
  reg [7:0] COLPM3;       // | $D015 | Write      |                 |
  reg [7:0] COLPF0 = 8'h5a;       // | $D016 | Write      |                 |   // Pre-initialized for testing, initialize via CPU writes in the future
  reg [7:0] COLPF1 = 8'h38;       // | $D017 | Write      |                 |
  reg [7:0] COLPF2 = 8'h7e;       // | $D018 | Write      |                 |
  reg [7:0] COLPF3 = 8'h00;       // | $D019 | Write      |                 |
  reg [7:0] COLBK = 8'h00;        // | $D01A | Write      |                 |
  reg [7:0] PRIOR = 8'h00;        // | $D01B | Write      |                 |
  reg [7:0] VDELAY;       // | $D01C | Write      |                 |
  reg [7:0] GRACTL;       // | $D01D | Write      |                 |
  reg [7:0] HITCLR;       // | $D01E | Write      |                 |
  reg [7:0] CONSPK_CONSOL;// | $D01F | Write/Read | GTIA_writeEn 22 |  
  
  // Temp
  reg [15:0] tempCount = 16'd0;
  
  wire [7:0] data_out, data_in;
  wire [7:0] data_RAM_out, data_reg_out;
  wire addr_RAM;
  wire write_RAM, write_reg;
  
  wire [15:0] CPU_addr_b;
  wire [7:0] data_RAM_out_b, data_in_b;
  buf memB0[7:0] (data_RAM_out, data_RAM_out_b);
  buf memB1[15:0] (CPU_addr_b, CPU_addr);
  buf memB2[7:0] (data_in_b, data_in);
  
  // Block RAM
  // Read clock is inverted Fphi0, write clock is phi2
  /*
  blk_mem_gen_v7_2 blockRAM (.clka(clk),
                             .wea(write_RAM),
                             .addra(CPU_addr_b),
                             .dina(data_in_b),
                             .clkb(Fclk),
                             .addrb(CPU_addr_b),
                             .doutb(data_RAM_out_b));*/
                             
  blk_mem_gen_v7_2_rom blockROM (.clka(Fclk), // input clka
                                 .addra(CPU_addr_b), // input [15 : 0] addra
                                 .douta(data_RAM_out_b) // output [7 : 0] douta
  );
  
  //memory256x256 mem(.clock(Fclk), .we(write_RAM), .address(CPU_addr), .dataIn(data_in), .dataOut(data_RAM_out));
  
  triStateData tsd(.DB(CPU_data), .DB_out(data_out), .writeEn(CPU_writeEn), .DB_in(data_in));
  
  addrMuxOut amo(.addr_RAM(addr_RAM), .data_RAM_out(data_RAM_out), .data_reg_out(data_reg_out), .data_out(data_out));
  
  addrCheck ac(.addr(CPU_addr), .addr_RAM(addr_RAM));
  
  writeMux wm(.addr_RAM(addr_RAM), .writeEn(CPU_writeEn), .write_RAM(write_RAM), .write_reg(write_reg));


  always @(posedge Fclk or posedge rst) begin
    
    if (rst) begin
      DLISTL <= 8'h03;
      DLISTH <= 8'hA0;
    end
    
    else begin
    
      if (NMIRES_NMIST[7]) begin
        DMACTL <= 8'h02;
        if (tempCount == 16'hFFFF) begin
          COLPF0 <= COLPF0 + 8'd2;
          tempCount <= 16'd0;
        end
        else
          tempCount <= tempCount + 16'd1;
      end
      else begin
        DMACTL <= 8'h22;
      end
    
      // CPU writes to ANTIC registers
      if (write_reg) begin
        case (CPU_addr)
          16'hD400: DMACTL <= data_in;
          16'hD401: CHACTL <= data_in;
          16'hD402: DLISTL <= data_in;
          16'hD403: DLISTH <= data_in;
          16'hD404: HSCROL <= data_in;
          16'hD405: VSCROL <= data_in;
          16'hD407: PMBASE <= data_in;
          16'hD409: CHBASE <= data_in;
          16'hD40A: WSYNC <= data_in;
          16'hD40E: NMIEN <= data_in;
          16'hD40F: NMIRES_NMIST <= data_in;
          16'hD000: HPOSP0_M0PF <= data_in;
          16'hD001: HPOSP1_M1PF <= data_in;
          16'hD002: HPOSP2_M2PF <= data_in;
          16'hD003: HPOSP3_M3PF <= data_in;
          16'hD004: HPOSM0_P0PF <= data_in;
          16'hD005: HPOSM1_P1PF <= data_in;
          16'hD006: HPOSM2_P2PF <= data_in;
          16'hD007: HPOSM3_P3PF <= data_in;
          16'hD008: SIZEP0_M0PL <= data_in;
          16'hD009: SIZEP1_M1PL <= data_in;
          16'hD00A: SIZEP2_M2PL <= data_in;
          16'hD00B: SIZEP3_M3PL <= data_in;
          16'hD00C: SIZEM_P0PL <= data_in;
          16'hD00D: GRAFP0_P1PL <= data_in;
          16'hD00E: GRAFP1_P2PL <= data_in;
          16'hD00F: GRAFP2_P3PL <= data_in;
          16'hD010: GRAFP3_TRIG0 <= data_in;
          16'hD011: GRAFPM_TRIG1 <= data_in;
          16'hD012: COLPM0_TRIG2 <= data_in;
          16'hD013: COLPM1_TRIG3 <= data_in;
          16'hD014: COLPM2_PAL <= data_in;
          16'hD015: COLPM3 <= data_in;
          16'hD016: COLPF0 <= data_in;
          16'hD017: COLPF1 <= data_in;
          16'hD018: COLPF2 <= data_in;
          16'hD019: COLPF3 <= data_in;
          16'hD01A: COLBK <= data_in;
          16'hD01B: PRIOR <= data_in;
          16'hD01C: VDELAY <= data_in;
          16'hD01D: GRACTL <= data_in;
          16'hD01E: HITCLR <= data_in;
          16'hD01F: CONSPK_CONSOL <= data_in;
        endcase
      end
      
      if (ANTIC_writeEn != 3'd0) begin
        case (ANTIC_writeEn)
          3'd1: if (~((write_reg)&(CPU_addr != 16'hD402)))
                  DLISTL <= DLISTL_bus;
          3'd2: if (~((write_reg)&&((CPU_addr == 16'hD402)||(CPU_addr == 16'hD403)))) begin
                  DLISTL <= DLISTL_bus;
                  DLISTH <= DLISTH_bus;
                end
          3'd3: VCOUNT <= VCOUNT_in;
          3'd4: PENH <= PENH_in;
          3'd5: PENV <= PENV_in;
          3'd6: if (~((write_reg)&(CPU_addr != 16'hD40F)))
                  NMIRES_NMIST <= NMIRES_NMIST_bus;
        endcase
      end
      
      if (GTIA_writeEn != 3'd0) begin
        case (GTIA_writeEn)
          5'd1:  if (~((write_reg)&(CPU_addr != 16'hD000)))
                   HPOSP0_M0PF <= HPOSP0_M0PF_bus;
          5'd2:  if (~((write_reg)&(CPU_addr != 16'hD001)))
                   HPOSP1_M1PF <= HPOSP1_M1PF_bus;
          5'd3:  if (~((write_reg)&(CPU_addr != 16'hD002)))
                   HPOSP2_M2PF <= HPOSP2_M2PF_bus;
          5'd4:  if (~((write_reg)&(CPU_addr != 16'hD003)))
                   HPOSP3_M3PF <= HPOSP3_M3PF_bus;
          5'd5:  if (~((write_reg)&(CPU_addr != 16'hD004)))
                   HPOSM0_P0PF <= HPOSM0_P0PF_bus;
          5'd6:  if (~((write_reg)&(CPU_addr != 16'hD005)))
                   HPOSM1_P1PF <= HPOSM1_P1PF_bus;
          5'd7:  if (~((write_reg)&(CPU_addr != 16'hD006)))
                   HPOSM2_P2PF <= HPOSM2_P2PF_bus;
          5'd8:  if (~((write_reg)&(CPU_addr != 16'hD007)))
                   HPOSM3_P3PF <= HPOSM3_P3PF_bus;
          5'd9:  if (~((write_reg)&(CPU_addr != 16'hD008)))
                   SIZEP0_M0PL <= SIZEP0_M0PL_bus;
          5'd10: if (~((write_reg)&(CPU_addr != 16'hD009)))
                   SIZEP1_M1PL <= SIZEP1_M1PL_bus;
          5'd11: if (~((write_reg)&(CPU_addr != 16'hD00A)))
                   SIZEP2_M2PL <= SIZEP2_M2PL_bus;
          5'd12: if (~((write_reg)&(CPU_addr != 16'hD00B)))
                   SIZEP3_M3PL <= SIZEP3_M3PL_bus;
          5'd13: if (~((write_reg)&(CPU_addr != 16'hD00C)))
                   SIZEM_P0PL <= SIZEM_P0PL_bus;
          5'd14: if (~((write_reg)&(CPU_addr != 16'hD00D)))
                   GRAFP0_P1PL <= GRAFP0_P1PL_bus;
          5'd15: if (~((write_reg)&(CPU_addr != 16'hD00E)))
                   GRAFP1_P2PL <= GRAFP1_P2PL_bus;
          5'd16: if (~((write_reg)&(CPU_addr != 16'hD00F)))
                   GRAFP2_P3PL <= GRAFP2_P3PL_bus;
          5'd17: if (~((write_reg)&(CPU_addr != 16'hD010)))
                   GRAFP3_TRIG0 <= GRAFP3_TRIG0_bus;
          5'd18: if (~((write_reg)&(CPU_addr != 16'hD011)))
                   GRAFPM_TRIG1 <= GRAFPM_TRIG1_bus;
          5'd19: if (~((write_reg)&(CPU_addr != 16'hD012)))
                   COLPM0_TRIG2 <= COLPM0_TRIG2_bus;
          5'd20: if (~((write_reg)&(CPU_addr != 16'hD013)))
                   COLPM1_TRIG3 <= COLPM1_TRIG3_bus;
          5'd21: if (~((write_reg)&(CPU_addr != 16'hD014)))
                   COLPM2_PAL <= COLPM2_PAL_bus;
          5'd22: if (~((write_reg)&(CPU_addr != 16'hD01F)))
                   CONSPK_CONSOL <= CONSPK_CONSOL_bus;
        endcase
      end
    end
  end
  
  // Bus outputs from read/write registers
  assign NMIRES_NMIST_bus = (ANTIC_writeEn == 3'd6) ? 8'hzz : NMIRES_NMIST;
  assign DLISTL_bus = ((ANTIC_writeEn == 3'd1)||(ANTIC_writeEn == 3'd2)) ? 8'hzz : DLISTL;
  assign DLISTH_bus = (ANTIC_writeEn == 3'd2) ? 8'hzz : DLISTH;
  
  // Output from registers to CPU
  assign data_reg_out = (CPU_addr == 16'hD400) ? DMACTL :
                        (CPU_addr == 16'hD401) ? CHACTL :
                        (CPU_addr == 16'hD402) ? DLISTL :
                        (CPU_addr == 16'hD403) ? DLISTH :
                        (CPU_addr == 16'hD404) ? HSCROL :
                        (CPU_addr == 16'hD405) ? VSCROL :
                        (CPU_addr == 16'hD407) ? PMBASE :
                        (CPU_addr == 16'hD409) ? CHBASE :
                        (CPU_addr == 16'hD40A) ? WSYNC :
                        (CPU_addr == 16'hD40B) ? VCOUNT :
                        (CPU_addr == 16'hD40C) ? PENH :
                        (CPU_addr == 16'hD40D) ? PENV :
                        (CPU_addr == 16'hD40E) ? NMIEN :
                        (CPU_addr == 16'hD40F) ? NMIRES_NMIST : 
                        (CPU_addr == 16'hD000) ? HPOSP0_M0PF : 
                        (CPU_addr == 16'hD001) ? HPOSP1_M1PF : 
                        (CPU_addr == 16'hD002) ? HPOSP2_M2PF : 
                        (CPU_addr == 16'hD003) ? HPOSP3_M3PF : 
                        (CPU_addr == 16'hD004) ? HPOSM0_P0PF : 
                        (CPU_addr == 16'hD005) ? HPOSM1_P1PF : 
                        (CPU_addr == 16'hD006) ? HPOSM2_P2PF : 
                        (CPU_addr == 16'hD007) ? HPOSM3_P3PF : 
                        (CPU_addr == 16'hD008) ? SIZEP0_M0PL : 
                        (CPU_addr == 16'hD009) ? SIZEP1_M1PL : 
                        (CPU_addr == 16'hD00A) ? SIZEP2_M2PL : 
                        (CPU_addr == 16'hD00B) ? SIZEP3_M3PL : 
                        (CPU_addr == 16'hD00C) ? SIZEM_P0PL : 
                        (CPU_addr == 16'hD00D) ? GRAFP0_P1PL : 
                        (CPU_addr == 16'hD00E) ? GRAFP1_P2PL : 
                        (CPU_addr == 16'hD00F) ? GRAFP2_P3PL : 
                        (CPU_addr == 16'hD010) ? GRAFP3_TRIG0 : 
                        (CPU_addr == 16'hD011) ? GRAFPM_TRIG1 : 
                        (CPU_addr == 16'hD012) ? COLPM0_TRIG2 : 
                        (CPU_addr == 16'hD013) ? COLPM1_TRIG3 : 
                        (CPU_addr == 16'hD014) ? COLPM2_PAL : 
                        (CPU_addr == 16'hD015) ? COLPM3 : 
                        (CPU_addr == 16'hD016) ? COLPF0 : 
                        (CPU_addr == 16'hD017) ? COLPF1 : 
                        (CPU_addr == 16'hD018) ? COLPF2 : 
                        (CPU_addr == 16'hD019) ? COLPF3 : 
                        (CPU_addr == 16'hD01A) ? COLBK : 
                        (CPU_addr == 16'hD01B) ? PRIOR : 
                        (CPU_addr == 16'hD01C) ? VDELAY : 
                        (CPU_addr == 16'hD01D) ? GRACTL : 
                        (CPU_addr == 16'hD01E) ? HITCLR : 
                        (CPU_addr == 16'hD01F) ? CONSPK_CONSOL : 8'hzz;

endmodule

// Tristate driver which splits databus into in/out wires
module triStateData(DB, DB_out, writeEn, DB_in);

  inout [7:0] DB;
  input [7:0] DB_out;
  input writeEn;
  output [7:0] DB_in;
  
  assign DB = (writeEn) ? 8'hzz : DB_out;
  assign DB_in = (writeEn) ? DB : 8'hzz;
    
endmodule

// Address checking module to map to RAM / registers
module addrCheck(addr, addr_RAM);
  
  input [15:0] addr;
  output addr_RAM;
  
  assign addr_RAM = (addr[15:12] == 4'hD) ? 1'b0 : 1'b1;

endmodule

// Mux to select sending output data from RAM / registers
module addrMuxOut(addr_RAM, data_RAM_out, data_reg_out, data_out);

  input addr_RAM;
  input [7:0] data_RAM_out;
  input [7:0] data_reg_out;
  output [7:0] data_out;
  
  assign data_out = addr_RAM ? data_RAM_out : data_reg_out;

endmodule

// Mux to select write enable for RAM / registers
module writeMux(addr_RAM, writeEn, write_RAM, write_reg);

  input addr_RAM;
  input writeEn;
  output write_RAM;
  output write_reg;
  
  assign write_RAM = (writeEn & addr_RAM) ? 1'b1 : 1'b0;
  assign write_reg = (writeEn & ~addr_RAM) ? 1'b1 : 1'b0;

endmodule
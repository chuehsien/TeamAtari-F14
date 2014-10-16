// Memory mapping module
// Last updated: 10/15/2014 2230H

module memoryMap(clk, CPU_writeEn, ANTIC_writeEn, CPU_addr, VCOUNT_in, PENH_in, PENV_in, CPU_data,
                 NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, 
                 CHBASE, WSYNC, NMIEN);
  
  input clk;
  input [3:0] CPU_writeEn;
  input [2:0] ANTIC_writeEn;
  input [3:0] CPU_addr;
  
  input [7:0] VCOUNT_in;
  input [7:0] PENH_in;
  input [7:0] PENV_in;
  
  inout [7:0] CPU_data;
  inout [7:0] NMIRES_NMIST_bus;
  inout [7:0] DLISTL_bus;
  inout [7:0] DLISTH_bus;
  
  output [7:0] DMACTL;
  output [7:0] CHACTL;
  output [7:0] HSCROL;
  output [7:0] VSCROL;
  output [7:0] PMBASE;
  output [7:0] CHBASE;
  output [7:0] WSYNC;
  output [7:0] NMIEN;
  
  // ANTIC hardware registers
  reg [7:0] DMACTL;       // | $D400 | Write      | CPU_writeEn 1  |                 |
  reg [7:0] CHACTL;       // | $D401 | Write      | CPU_writeEn 2  |                 |
  reg [7:0] DLISTL;       // | $D402 | Write/Read | CPU_writeEn 3  | ANTIC_writeEn 1 |
  reg [7:0] DLISTH;       // | $D403 | Write/Read | CPU_writeEn 4  | ANTIC_writeEn 2 |
  reg [7:0] HSCROL;       // | $D404 | Write      | CPU_writeEn 5  |                 |
  reg [7:0] VSCROL;       // | $D405 | Write      | CPU_writeEn 6  |                 |
  reg [7:0] PMBASE;       // | $D407 | Write      | CPU_writeEn 7  |                 |
  reg [7:0] CHBASE;       // | $D409 | Write      | CPU_writeEn 8  |                 |
  reg [7:0] WSYNC;        // | $D40A | Write      | CPU_writeEn 9  |                 |
  reg [7:0] VCOUNT;       // | $D40B | Read       |                | ANTIC_writeEn 3 |
  reg [7:0] PENH;         // | $D40C | Read       |                | ANTIC_writeEn 4 |
  reg [7:0] PENV;         // | $D40D | Read       |                | ANTIC_writeEn 5 |
  reg [7:0] NMIEN;        // | $D40E | Write      | CPU_writeEn 10 |                 |
  reg [7:0] NMIRES_NMIST; // | $D40F | Write/Read | CPU_writeEn 11 | ANTIC_writeEn 6 | 
  
  always @(posedge clk) begin
    // CPU writes to ANTIC registers
    case (CPU_writeEn)
      4'd1:  DMACTL <= CPU_data;
      4'd2:  CHACTL <= CPU_data;
      4'd3:  DLISTL <= CPU_data;
      4'd4:  DLISTH <= CPU_data;
      4'd5:  HSCROL <= CPU_data;
      4'd6:  VSCROL <= CPU_data;
      4'd7:  PMBASE <= CPU_data;
      4'd8:  CHBASE <= CPU_data;
      4'd9:  WSYNC <= CPU_data;
      4'd10: NMIEN <= CPU_data;
      4'd11: NMIRES_NMIST <= CPU_data;
    endcase
  end
  
  // Bus outputs from read/write registers
  assign NMIRES_NMIST_bus = (ANTIC_writeEn == 3'd6) ? 8'hzz : NMIRES_NMIST;
  assign DLISTL_bus = (ANTIC_writeEn == 3'd1) ? 8'hzz : DLISTL;
  assign DLISTH_bus = (ANTIC_writeEn == 3'd2) ? 8'hzz : DLISTH;
  assign CPU_data = (CPU_writeEn != 3'd0) ? 8'hzz : 
                    (CPU_addr == 4'h0) ? DMACTL :
                    (CPU_addr == 4'h1) ? CHACTL :
                    (CPU_addr == 4'h2) ? DLISTL :
                    (CPU_addr == 4'h3) ? DLISTH :
                    (CPU_addr == 4'h4) ? HSCROL :
                    (CPU_addr == 4'h5) ? VSCROL :
                    (CPU_addr == 4'h7) ? PMBASE :
                    (CPU_addr == 4'h9) ? CHBASE :
                    (CPU_addr == 4'hA) ? WSYNC :
                    (CPU_addr == 4'hB) ? VCOUNT :
                    (CPU_addr == 4'hC) ? PENH :
                    (CPU_addr == 4'hD) ? PENV :
                    (CPU_addr == 4'hE) ? NMIEN :
                    (CPU_addr == 4'hF) ? NMIRES_NMIST : 8'hzz;
  
  always @(*) begin
    // ANTIC writes to ANTIC registers
    case (ANTIC_writeEn)
      3'd1: if (CPU_writeEn != 4'd11) 
              DLISTL <= DLISTL_bus;
      3'd2: if (CPU_writeEn != 4'd11) 
              DLISTH <= DLISTH_bus;
      3'd3: VCOUNT <= VCOUNT_in;
      3'd4: PENH <= PENH_in;
      3'd5: PENV <= PENV_in;
      3'd6: if (CPU_writeEn != 4'd11) 
              NMIRES_NMIST <= NMIRES_NMIST_bus;
    endcase
  end

endmodule
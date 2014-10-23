// Test for integrated memory mapping

`include "memoryMap.v"

module intMemTest;
  
  reg Fphi0;
  reg phi2;
  reg [20:0] i;
  
  wire [7:0] NMIRES_NMIST_bus;
  wire [7:0] DLISTL_bus;
  wire [7:0] DLISTH_bus;
  
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

  reg CPU_writeEn;
  reg [15:0] CPU_addr;
  reg [7:0] CPU_data_reg;
  reg [7:0] DLISTL_reg, HPOSP0_M0PF_reg;
  reg [2:0] ANTIC_writeEn;
  reg [4:0] GTIA_writeEn;
  
  wire [7:0] CPU_data;
  
  assign CPU_data = CPU_writeEn ? CPU_data_reg : 8'hzz;
  
  // Sample Registers
  assign DLISTL_bus = (ANTIC_writeEn == 3'd1) ? DLISTL_reg : 8'hzz;
  assign HPOSP0_M0PF_bus = (GTIA_writeEn == 3'd1) ? HPOSP0_M0PF_reg : 8'hzz;
  
  // EXTRAS
  wire addr_RAM;
  
  // Module instantiations
  memoryMap map(.Fclk(Fphi0), .clk(phi2), .CPU_writeEn(CPU_writeEn), .ANTIC_writeEn(ANTIC_writeEn), .GTIA_writeEn(GTIA_writeEn),
                .CPU_addr(CPU_addr), .VCOUNT_in(), .PENH_in(), .PENV_in(), .CPU_data(CPU_data), 
                .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus), 
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
                .COLPF3(COLPF3), .COLBK(COLBK), .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
                
                .addr_RAM(addr_RAM));
  
  task print;
    $display("Fclk %b, clk is %b, CPU_data is %h, CPU_addr is %h, addr_RAM is %b", 
             Fphi0, phi2, CPU_data, CPU_addr, addr_RAM);
  endtask
  
  initial begin
    $display("Begin Mem test.");
    
    // Initialize values
    Fphi0 = 1'b0;
    phi2 = 1'b0;
    
    // Read from address 1 (0x70)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hA000;
    CPU_data_reg = 8'h00;
    ANTIC_writeEn = 3'd0;
    GTIA_writeEn = 5'd0;
    DLISTL_reg = 8'h00;
    HPOSP0_M0PF_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0); 
    
    // Read from address 2 (0x18)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hE001;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Write to address 2
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hE001;
    CPU_data_reg = 8'hDC;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read back from address 2 (0xDC)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hE001;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register DLISTL (0x00)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD402;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Write to register DLISTL
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hD402;
    CPU_data_reg = 8'hAB;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register DLISTL (0xAB)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD402;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // ANTIC write to register DLISTL
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD402;
    CPU_data_reg = 8'h00;
    ANTIC_writeEn = 3'd1;
    DLISTL_reg = 8'hEF;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register DLISTL (0xEF)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD402;
    CPU_data_reg = 8'h00;
    ANTIC_writeEn = 3'd0;
    DLISTL_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register HPOSP0_M0PF (0x56)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD000;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // CPU write to register COLFP0
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hD000;
    CPU_data_reg = 8'h78;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register HPOSP0_M0PF (0x78)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD000;
    CPU_data_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // GTIA write to HPOSP0_M0PF
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD000;
    CPU_data_reg = 8'h00;
    GTIA_writeEn = 5'd1;
    HPOSP0_M0PF_reg = 8'h9A;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register HPOSP0_M0PF (0x9A)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD000;
    CPU_data_reg = 8'h00;
    GTIA_writeEn = 5'd0;
    HPOSP0_M0PF_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    // Read from register COLPF1 (0x4C)
    CPU_writeEn = 1'b0;
    CPU_addr = 16'hD017;
    CPU_data_reg = 8'h00;
    GTIA_writeEn = 5'd0;
    HPOSP0_M0PF_reg = 8'h00;
    
    @(posedge Fphi0); print; @(negedge Fphi0);
    
    $display("Completed Mem test.");
    $finish;
  end
  
  always begin
    forever #10 Fphi0 = ~Fphi0;
  end

  always begin
    forever #20 phi2 = ~phi2;
  end



endmodule
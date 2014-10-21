// Test top module for ANTIC

`include "ANTIC.v"
`include "GTIA.v"
`include "RAM.v"
`include "memoryMap.v"

module testANTIC();

  wire [7:0] CPU_data;

  reg reset;
  reg Fphi0;
  reg [20:0] i;      // Remember to change this accordingly
  
  wire phi2;
  
  wire [2:0] AN;
  wire halt_L;
  wire [15:0] address;
  wire [7:0] DB;
  wire [15:0] dlistptr;
  wire [1:0] curr_state;
  wire [7:0] data;
  wire [7:0] IR;
  wire loadIR;
  
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
  wire [7:0] GRAFPM_TRIG2_bus;
  wire [7:0] GRAFPM_TRIG3_bus;
  wire [7:0] COLPM2_PAL_bus;
  wire [7:0] CONSPK_CONSOL_bus;
  
  wire [1:0] loadDLIST;
  wire [15:0] MSR;
  wire [1:0] loadMSR_both;
  wire IR_rdy;
  wire [3:0] mode;
  wire [6:0] numBytes;
  wire [7:0] MSRdata;
  wire [2:0] ANTIC_writeSel;
  wire [7:0] DLISTL;
  wire [14:0] blankCount;
  wire phi2_mem;
  
  reg CPU_writeEn;
  reg [7:0] writeVal;
  reg write;
  reg [15:0] CPU_addr;
  
  assign CPU_data = write ? writeVal : 8'hzz;
  
  // Clock buffer for memory (use 5 buffers in actual board memory?)
  buf #(1) b1(phi2_mem, phi2);
  
  // Instantiate Modules
  memory256x256 mem(.clock(phi2_mem), .enable(1'b1), .we_L(1'b1), .re_L(halt_L), .address(address), .data(DB));
  
  ANTIC antic(.Fphi0(Fphi0), .LP_L(), .RW(), .rst(reset), .phi2(phi2), .DMACTL(DMACTL), .CHACTL(CHACTL),
              .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE), .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), 
              .DB(DB), .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus),
              .address(address), .AN(AN), .halt_L(halt_L), .NMI_L(), .RDY_L(), .REF_L(), .RNMI_L(), .phi0(), 
              .IR_out(IR), .loadIR(loadIR), .VCOUNT(VCOUNT), .PENH(PENH), .PENV(PENV), .ANTIC_writeEn(ANTIC_writeEn), 
              .charMode(), .printDLIST(dlistptr), .currState(curr_state), .data(data), .MSR(MSR), .loadDLIST_both(loadDLIST), 
              .loadMSR_both(loadMSR_both), .IR_rdy(IR_rdy), .mode(mode), .numBytes(numBytes), .MSRdata(MSRdata), 
              .ANTIC_writeSel(ANTIC_writeSel), .DLISTL(DLISTL), .blankCount(blankCount));
  
  GTIA gtia(.address(), .AN(AN), .CS(), .DEL(), .OSC(), .RW(), .trigger(), .Fphi0(Fphi0), 
            .COLPM3(COLPM3), .COLPF0(COLPF0), .COLPF1(COLPF1), .COLPF2(COLPF2), .COLPF3(COLPF3), .COLBK(COLBK),
            .PRIOR(PRIOR), .VDELAY(VDELAY), .GRACTL(GRACTL), .HITCLR(HITCLR),
            .DB(), .switch(),
            .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
            .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
            .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
            .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
            .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus), 
            .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
            .GRAFPM_TRIG2_bus(GRAFPM_TRIG2_bus), .GRAFPM_TRIG3_bus(GRAFPM_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus), 
            .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus),
            .COL(), .CSYNC(), .phi2(phi2), .HALT(), .L());
               
  memoryMap map(.clk(phi2), .CPU_writeEn(CPU_writeEn), .ANTIC_writeEn(ANTIC_writeEn), .GTIA_writeEn(), // Add GTIA_writeEn
                .CPU_addr(CPU_addr), .VCOUNT_in(VCOUNT), .PENH_in(PENH), .PENV_in(PENV), .CPU_data(CPU_data), 
                .NMIRES_NMIST_bus(NMIRES_NMIST_bus), .DLISTL_bus(DLISTL_bus), .DLISTH_bus(DLISTH_bus), 
                .HPOSP0_M0PF_bus(HPOSP0_M0PF_bus), .HPOSP1_M1PF_bus(HPOSP1_M1PF_bus), .HPOSP2_M2PF_bus(HPOSP2_M2PF_bus),
                .HPOSP3_M3PF_bus(HPOSP3_M3PF_bus), .HPOSM0_P0PF_bus(HPOSM0_P0PF_bus), .HPOSM1_P1PF_bus(HPOSM1_P1PF_bus),
                .HPOSM2_P2PF_bus(HPOSM2_P2PF_bus), .HPOSM3_P3PF_bus(HPOSM3_P3PF_bus), .SIZEP0_M0PL_bus(SIZEP0_M0PL_bus),
                .SIZEP1_M1PL_bus(SIZEP1_M1PL_bus), .SIZEP2_M2PL_bus(SIZEP2_M2PL_bus), .SIZEP3_M3PL_bus(SIZEP3_M3PL_bus),
                .SIZEM_P0PL_bus(SIZEM_P0PL_bus), .GRAFP0_P1PL_bus(GRAFP0_P1PL_bus), .GRAFP1_P2PL_bus(GRAFP1_P2PL_bus),
                .GRAFP2_P3PL_bus(GRAFP2_P3PL_bus), .GRAFP3_TRIG0_bus(GRAFP3_TRIG0_bus), .GRAFPM_TRIG1_bus(GRAFPM_TRIG1_bus),
                .GRAFPM_TRIG2_bus(GRAFPM_TRIG2_bus), .GRAFPM_TRIG3_bus(GRAFPM_TRIG3_bus), .COLPM2_PAL_bus(COLPM2_PAL_bus),
                .CONSPK_CONSOL_bus(CONSPK_CONSOL_bus),
                .DMACTL(DMACTL), .CHACTL(CHACTL), .HSCROL(HSCROL), .VSCROL(VSCROL), .PMBASE(PMBASE),
                .CHBASE(CHBASE), .WSYNC(WSYNC), .NMIEN(NMIEN), .COLPM3(), .COLPF0(), .COLPF1(), .COLPF2(),
                .COLPF3(), .COLBK(), .PRIOR(), .VDELAY(), .GRACTL(), .HITCLR());
  
  task print;
    $display("clk %b, halt_L is %b, curr_state is %b, data is %h, IR is %h, loadIR is %b, IR_rdy is %b, mode is %d, AN is %b, numBytes is %d, blankCount is %d, dlistptr is %h, DLISTL is %h, ANTIC_writeEn is %d, ANTIC_writeSel is %d, loadDLIST is %b, DMACTL is %b, CHBASE is %h, MSR is %h, MSRdata is %h loadMSR is %b", 
             phi2, halt_L, curr_state, data, IR, loadIR, IR_rdy, mode, AN, numBytes, blankCount, dlistptr, DLISTL, ANTIC_writeEn, ANTIC_writeSel, loadDLIST, DMACTL, CHBASE, MSR, MSRdata, loadMSR_both);
  endtask
  
  initial begin
    $display("Begin ANTIC test.");
    
    // Initialize clocks
    Fphi0 = 1'b0;
    //phi2 = 1'b0;
    
    // Load DLISTL
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hD402;
    write = 1'b1;
    writeVal = 8'h00;
    
    @(posedge phi2); @(negedge phi2);
    
    // LOAD DLISTH
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hD403;
    write = 1'b1;
    writeVal = 8'hA0;
    
    @(posedge phi2); @(negedge phi2);
    
    // LOAD CHBASE
    CPU_writeEn = 1'b1;
    CPU_addr = 16'hD409;
    write = 1'b1;
    writeVal = 8'hE0;
    
    @(posedge phi2); @(negedge phi2);
    
    // LOAD DMACTL
    CPU_writeEn = 4'd1;
    CPU_addr = 16'hD400;
    write = 1'b1;
    writeVal = 8'h02;
    
    @(posedge phi2); @(negedge phi2);
    CPU_writeEn = 1'b0;
    write = 1'b0;
    
    // Reset ANTIC FSM
    reset = 1'b1;
    @(posedge phi2); @(negedge phi2);
    reset = 1'b0;

    // Step through display list
    for (i=0; i<100; i=i+1) begin //3000
      print; @(posedge phi2); print; @(negedge phi2);
    end
    
    $display("Completed ANTIC test.");
    $finish;
  end
  
  /*
  always begin
    forever #20  phi2 = ~phi2;
  end
  */
  
  always begin
    forever #10 Fphi0 = ~Fphi0;
  end
  
endmodule
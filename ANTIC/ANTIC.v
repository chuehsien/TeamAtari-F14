// top module for the ANTIC processor.
// last updated: 10/02/2014 2345H

`include "ANTIC_dataTranslate.v"

`define FSMinit		  2'b00
`define FSMload1    2'b01
`define FSMload2    2'b10
`define FSMidle     2'b11
`define DMA_off     1'b0
`define DMA_on      1'b1

module ANTIC(Fphi0, LP_L, RW, rst, phi2, DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, 
             WSYNC, NMIEN, DB, NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, address, AN, 
             halt_L, NMI_L, RDY_L, REF_L, RNMI_L, phi0, IR_out, loadIR, VCOUNT, PENH, PENV, 
             ANTIC_writeEn, printDLIST, cstate, data, MSR, loadMSR_both, loadDLIST_both);

      input Fphi0;
      input LP_L;
      input RW;
      input rst;
      input phi2;
      
      input [7:0] DMACTL;
      input [7:0] CHACTL;
      input [7:0] HSCROL;
      input [7:0] VSCROL;
      input [7:0] PMBASE;
      input [7:0] CHBASE;
      input [7:0] WSYNC;
      input [7:0] NMIEN;
      
      inout [7:0] DB;
      inout [7:0] NMIRES_NMIST_bus;
      inout [7:0] DLISTL_bus;
      inout [7:0] DLISTH_bus;
      
      output [15:0] address;
      output [2:0] AN;
      output halt_L;
      output NMI_L;
      output RDY_L;
      output REF_L;
      output RNMI_L;
      output phi0;
      output [7:0] IR_out;
      output loadIR;
      
      output reg [7:0] VCOUNT = 8'd0;
      output reg [7:0] PENH = 8'd0;
      output reg [7:0] PENV = 8'd0;
      output reg [2:0] ANTIC_writeEn = 3'd0;
      
      // Extras (remove later on)
      output [15:0] printDLIST;
      output [2:0] cstate;
      output [7:0] data;
      output [15:0] MSR;
      output [1:0] loadDLIST_both;
      output [1:0] loadMSR_both;
      
      reg DMA;
      reg ready_L;
      reg loadAddr;
      reg incr = 1'b0;
      reg vblank;
      reg IR_rdy = 1'b0;
      reg [7:0] IR;
      reg [2:0] currState;
      reg [2:0] nextState;
      reg [15:0] addressIn;
      wire [7:0] data;
      wire loadIR;
      wire loadDLISTL = 1'b0;
      wire loadDLISTH = 1'b0;
      wire DLISTend;
      wire DLISTjump;
      wire loadPtr;
      wire loadMSRL;
      wire loadMSRH;
      
      // * Temp:
      assign printDLIST = {DLISTH_bus, DLISTL_bus};
      assign halt_L = ~DMA;
      assign cstate = currState;
      assign IR_out = IR;
      assign loadDLIST_both = {loadDLISTH, loadDLISTL};
      assign loadMSR_both = {loadMSRH, loadMSRL};
      // End Temp *

      // Module instantiations
      AddressBusReg addr(.load(loadAddr), .incr(incr), .addressIn(addressIn), .addressOut(address));
      dataReg dreg(.phi2(phi2), .DMA(DMA), .dataIn(DB), .data(data));
      dataTranslate dt(.IR(IR), .IR_rdy(IR_rdy), .Fphi0(Fphi0), .rst(rst), .vblank(vblank), .DMACTL(DMACTL), .AN(AN), .loadIR(loadIR),
                       .loadDLISTL(loadDLISTL), .loadDLISTH(loadDLISTH), .DLISTjump(DLISTjump), .DLISTend(DLISTend),
                       .loadPtr(loadPtr), .loadMSRL(loadMSRL), .loadMSRH(loadMSRH));
      
      // Update DLISTPTR (JUMP instruction)
      assign DLISTL_bus = loadDLISTL ? IR : 8'hzz;
      assign DLISTH_bus = loadDLISTH ? IR : 8'hzz;
    
      // FSM to initialize
      always @ (posedge phi2) begin
           
        // * TODO: Add vertical blank signal occurrence signal to dataTranslate module
      
        case (currState)
            // Set or clear registers to default state
            `FSMinit:
              begin
                nextState <= `FSMload1;
                
                // Load display list
                addressIn <= {DLISTH_bus, DLISTL_bus};
                loadAddr <= 1'b1;
                DMA <= `DMA_on;
                
                // * Playfield DMA clock reset?
              end
              
            `FSMload1:
              begin
                nextState <= `FSMload2;
                DMA <= `DMA_off;
              end
            
            `FSMload2:
              begin
                if (~loadPtr)
                  incr <= 1'b1; // Increment display list pointer
                IR <= data;
                IR_rdy <= 1'b1;
                
                // Additional display list commands to load (3-byte instruction)
                if (loadIR) begin
                  nextState <= `FSMload1;  
                  DMA <= `DMA_on;
                end
                
                // Pause loading
                else begin
                  nextState <= `FSMidle;
                end
              end
              
            `FSMidle:
              begin              
                // Load next display list instruction
                if (loadIR) begin
                  nextState <= `FSMload1;
                  DMA <= `DMA_on;
                  if (DLISTjump) begin
                    addressIn <= {DLISTH_bus, DLISTL_bus};
                    loadAddr <= 1'b1;
                  end
                end
                
                // Continue to idle
                else begin
                  nextState <= `FSMidle;
                end
              end
        endcase
      end
      
      always @ (negedge phi2) begin
        if (rst)
          currState <= `FSMinit;
        else 
          currState <= nextState;
        
        loadAddr <= 1'b0;
        incr <= 1'b0;
        IR_rdy <= 1'b0;
      end
      
endmodule


module AddressBusReg(load, incr, addressIn, addressOut);

	input load;
  input incr;
  input [15:0] addressIn;
	output reg [15:0] addressOut;
	
  always @ (load or incr) begin
		if (load)
      addressOut <= addressIn;
    else if (incr)
      addressOut <= addressOut + 16'd1;
	end
	
endmodule


module dataReg(phi2, DMA, dataIn, data);

	input phi2;
  input DMA;
	input [7:0] dataIn;
	output reg [7:0] data;
  
	always @(posedge phi2) begin
    if (DMA)
      data <= dataIn;
	end

endmodule

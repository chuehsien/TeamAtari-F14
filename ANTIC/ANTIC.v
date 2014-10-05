// top module for the ANTIC processor.
// last updated: 10/02/2014 2345H

`include "ANTIC_dataTranslate.v"

`define FSMinit1		4'b0000
`define FSMinit2	  4'b0001
`define FSMinit3    4'b0010
`define FSMinit4    4'b0011
`define FSMinit5    4'b0100
`define FSMinit6    4'b0101
`define FSMload1    4'b0110
`define FSMload2    4'b0111
`define FSMidle     4'b1000
`define DMA_off     1'b0
`define DMA_on      1'b1

module ANTIC(Fphi0, LP_L, RW, RST, phi2, DB, address, AN, halt_L, NMI_L, RDY_L,
             REF_L, RNMI_L, phi0, printDLIST, curr_state, data, IR, loadIR,
             loadDLIST_both, CHBASE, MSR, loadMSR_both);

      input Fphi0;
      input LP_L;
      input RW;
      input RST;
      input phi2;
      inout [7:0] DB;
      output [15:0] address;
      output [2:0] AN;
      output halt_L;
      output NMI_L;
      output RDY_L;
      output REF_L;
      output RNMI_L;
      output phi0;
      output [7:0] IR;
      output loadIR;
      output [7:0] CHBASE;
      output [15:0] MSR;
      
      // extras (remove later on)
      output [15:0] printDLIST;
      output [2:0] curr_state;
      output [7:0] data;
      output [1:0] loadDLIST_both;
      output [1:0] loadMSR_both;
      
      // Hardware registers
      reg [7:0] DMACTL;   // $D400
      reg [7:0] CHACTL;   // $D401
      reg [7:0] DLISTL;   // $D402
      reg [7:0] DLISTH;   // $D403
      reg [7:0] HSCROL;   // $D404
      reg [7:0] VSCROL;   // $D405
      reg [7:0] PMBASE;   // $D407
      reg [7:0] CHBASE;   // $D409
      reg [7:0] WSYNC;    // $D40A
      reg [7:0] VCOUNT;   // $D40B
      reg [7:0] PENH;     // $D40C
      reg [7:0] PENV;     // $D40D
      reg [7:0] NMIEN;    // $D40E
      reg [7:0] NMI;      // $D40F
      
      // Internal registers
      reg [15:0] MSR;     // Memory Scan Register
      
      reg DMA;
      reg ready_L;
      reg loadAddr;
      reg incr;
      reg vblank;
      reg IR_rdy;
      reg [7:0] IR;
      reg [3:0] currState;
      reg [3:0] nextState;
      reg [15:0] addressIn;
      
      wire [127:0] registers;
      wire [7:0] data;
      wire loadIR;
      wire loadDLISTL;
      wire loadDLISTH;
      wire DLISTend;
      wire DLISTjump;
      wire loadPtr;
      wire loadMSRL;
      wire loadMSRH;
      
      assign registers = {NMI, NMIEN, PENV, PENH, VCOUNT, WSYNC,
                          CHBASE, 8'd0, PMBASE, 8'd0, VSCROL, HSCROL,
                          DLISTH, DLISTL, CHACTL, DMACTL};
      
      // * Temp:
      assign printDLIST = {DLISTH, DLISTL};
      assign halt_L = ~DMA;
      assign loadDLIST_both = {loadDLISTH, loadDLISTL};
      assign loadMSR_both = {loadMSRH, loadMSRL};
      // End Temp *

      // Module instantiations
      
      AddressBusReg addr(.load(loadAddr), .incr(incr), .addressIn(addressIn), .addressOut(address));
      dataReg dreg(.phi2(phi2), .DMA(DMA), .dataIn(DB), .data(data));
      dataTranslate dt(.IR(IR), .IR_rdy(IR_rdy), .Fphi0(Fphi0), .RST(RST), .vblank(vblank), .AN(AN), .loadIR(loadIR),
                       .loadDLISTL(loadDLISTL), .loadDLISTH(loadDLISTH), .DLISTjump(DLISTjump), .DLISTend(DLISTend),
                       .loadPtr(loadPtr), .loadMSRL(loadMSRL), .loadMSRH(loadMSRH));
    
      // FSM to initialize
      always @ (posedge phi2) begin
  
        // Display list pointer changes (triggered by JUMP instruction in dataTranslate module)
        if (loadDLISTL)
          DLISTL <= IR;
        else if (loadDLISTH)
          DLISTH <= IR;
        
        // Memory Scan Register changes
        if (loadMSRL)
          MSR[7:0] <= IR;
        else if (loadMSRH)
          MSR[15:8] <= IR;
          
        // * TODO: Add vertical blank signal occurrence signal to dataTranslate module
      
        case (currState)
            // Set or clear registers to default state
            `FSMinit1:
              begin
                IR_rdy <= 1'b0;
                incr <= 1'b0;
                nextState <= `FSMinit2;
                VCOUNT <= 8'd0;
                NMIEN <= 8'd0;
                DMACTL <= 8'd0;
                addressIn <= 16'h02F4; // Shadow CHBASE register
                loadAddr <= 1'b1;
                DMA <= `DMA_on;
                // * Playfield DMA clock reset?
              end
            
            `FSMinit2:
              begin
                nextState <= `FSMinit3;
                addressIn <= 16'h0230; // Shadow DLISTL register
                loadAddr <= 1'b1;
              end
            
            `FSMinit3:
              begin
                nextState <= `FSMinit4;
                CHBASE <= data;
                addressIn <= 16'h0231; // Shadow DLISTH register
                loadAddr <= 1'b1;
              end
              
            `FSMinit4:
              begin
                nextState <= `FSMinit5;
                DLISTL <= data;
                DMA <= `DMA_off;
              end
            
            `FSMinit5:
              begin
                nextState <= `FSMinit6;
                DLISTH <= data;
                // * Sync other hardware registers and RAM shadow registers?
              end
              
            `FSMinit6:
              begin
                nextState <= `FSMload1;
                addressIn <= {DLISTH, DLISTL};
                loadAddr <= 1'b1;
                DMA <= `DMA_on;
                // * Sync other hardware registers and RAM shadow registers?
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
                    addressIn <= {DLISTH, DLISTL};
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
        if (RST)
          currState <= `FSMinit1;
        else 
          currState <= nextState;
        
        if (incr) begin
          incr <= 1'b0;
          {DLISTH, DLISTL} <= address;
        end
        
        loadAddr <= 1'b0;
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

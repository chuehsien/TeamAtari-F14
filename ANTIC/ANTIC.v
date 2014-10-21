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
             ANTIC_writeEn, charMode, printDLIST, currState, data, MSR, loadMSR_both, loadDLIST_both,
             IR_rdy, mode, numBytes, MSRdata, ANTIC_writeSel, DLISTL, blankCount);

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
      output charMode;
      output [2:0] ANTIC_writeSel;
      
      // Extras (remove later on)
      output [15:0] printDLIST;
      output [1:0] currState;
      output [7:0] data;
      output [15:0] MSR;
      output [1:0] loadDLIST_both;
      output [1:0] loadMSR_both;
      output IR_rdy;
      output [3:0] mode;
      output [6:0] numBytes;
      output [7:0] MSRdata;
      output [7:0] DLISTL;
      output [14:0] blankCount;
      
      reg DMA;
      reg ready_L;
      reg loadAddr;
      reg incr = 1'b0;
      reg vblank = 1'b0;
      reg IR_rdy = 1'b0;
      reg [7:0] IR;
      reg [1:0] currState;
      reg [2:0] nextState;
      reg [15:0] addressIn;
      reg [15:0] MSR;
      reg [7:0] MSRdata;
      reg MSRdata_rdy = 1'b0;
      reg charLoaded = 1'b0;
      reg [63:0] charData;
      reg [7:0] charByte = 8'd0;
      reg [7:0] DLISTL;
      reg incrDLISTL = 1'b0;
      wire [7:0] data;
      wire loadIR;
      wire loadDLISTL;
      wire loadDLISTH;
      wire DLISTend;
      wire DLISTjump;
      wire loadPtr;
      wire loadMSRL;
      wire loadMSRH;
      wire incrMSR;
      wire loadMSRdata;
      wire charMode;
      wire [1:0] colorSel;
      wire loadChar;
      wire [2:0] ANTIC_writeSel;
      
      // * Temp:
      assign printDLIST = {DLISTH_bus, DLISTL_bus};
      assign halt_L = ~DMA;
      assign IR_out = IR;
      assign loadDLIST_both = {loadDLISTH, loadDLISTL};
      assign loadMSR_both = {loadMSRH, loadMSRL};
      // End Temp *
      
      assign colorSel = MSRdata[7:6];

      // Module instantiations
      AddressBusReg addr(.load(loadAddr), .incr(incr), .addressIn(addressIn), .addressOut(address));
      dataReg dreg(.phi2(phi2), .DMA(DMA), .dataIn(DB), .data(data));
      dataTranslate dt(.IR(IR), .IR_rdy(IR_rdy), .Fphi0(Fphi0), .rst(rst), .vblank(vblank), .DMACTL(DMACTL), .MSRdata_rdy(MSRdata_rdy), 
                       .charData(charData), .colorSel(colorSel), .charLoaded(charLoaded), .AN(AN), .loadIR(loadIR),
                       .loadDLISTL(loadDLISTL), .loadDLISTH(loadDLISTH), .DLISTjump(DLISTjump), .DLISTend(DLISTend),
                       .loadPtr(loadPtr), .loadMSRL(loadMSRL), .loadMSRH(loadMSRH), .incrMSR(incrMSR), .loadMSRdata(loadMSRdata),
                       .mode(mode), .numBytes(numBytes), .charMode(charMode), .loadChar(loadChar), .ANTIC_writeSel(ANTIC_writeSel),
                       .blankCount(blankCount));
      
      // Update DLISTPTR (JUMP instruction)
      assign DLISTL_bus = loadDLISTL ? IR : (incrDLISTL ? (DLISTL + 8'd1) : 8'hzz);
      assign DLISTH_bus = loadDLISTH ? IR : 8'hzz;
    
      // FSM to initialize
      always @ (posedge phi2) begin
           
        // * TODO: Add vertical blank signal occurrence signal to dataTranslate module
        
        // Memory Scan Register changes
        if (loadMSRL)
          MSR[7:0] <= IR;
        else if (loadMSRH)
          MSR[15:8] <= IR;
          
        if (incrMSR)
          MSR <= MSR+1;
      
        case (currState)
            // Set or clear registers to default state
            `FSMinit:
              begin
                nextState <= `FSMload1;
                
                // Load display list
                addressIn <= {DLISTH_bus, DLISTL_bus};
                DLISTL <=  DLISTL_bus;
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
                if (loadMSRdata) begin
                  MSRdata <= data;
                  MSRdata_rdy <= 1'b1;
                end
                
                else if (loadChar) begin
                  case (charByte)
                    8'd0: charData[7:0] <= data;
                    8'd1: charData[15:8] <= data;
                    8'd2: charData[23:16] <= data;
                    8'd3: charData[31:24] <= data;
                    8'd4: charData[39:32] <= data;
                    8'd5: charData[47:40] <= data;
                    8'd6: charData[55:48] <= data;
                    8'd7: charData[63:56] <= data;
                  endcase
                  charByte <= charByte + 8'd1;
                end
                
                else begin
                
                  if (~loadPtr) begin
                    incrDLISTL <= 1'b1;
                    ANTIC_writeEn <= 3'd1;
                    incr <= 1'b1; // Increment display list pointer
                  end
                  else begin
                    if (ANTIC_writeSel == 3'd1)
                      ANTIC_writeEn <= 3'd1;
                    else if (ANTIC_writeSel == 3'd2)
                      ANTIC_writeEn <= 3'd2;
                    else
                      ANTIC_writeEn <= 3'd0;
                  end
                  IR <= data;
                  IR_rdy <= 1'b1;
                end
              
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
                  //if (DLISTjump) begin
                    addressIn <= {DLISTH_bus, DLISTL_bus};
                    loadAddr <= 1'b1;
                  //end
                end
                
                else if (loadMSRdata) begin
                  nextState <= `FSMload1;
                  DMA <= `DMA_on;
                  addressIn <= MSR;
                  loadAddr <= 1'b1;
                end
                
                else if (loadChar) begin
                  nextState <= `FSMidle;
                  if (charByte < 8'd8) begin
                    charLoaded <= 1'b0;
                    MSRdata_rdy <= 1'b0;
                    addressIn <= {CHBASE, MSRdata + charByte};
                    loadAddr <= 1'b1;
                    nextState <= `FSMload1;
                    DMA <= `DMA_on;
                  end
                  else begin
                    charByte <= 8'd0;
                    charLoaded <= 1'b1;
                  end
                end
                
                // Continue to idle
                else begin
                  charLoaded <= 1'b0;
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
        ANTIC_writeEn <= 3'd0;
        if (incrDLISTL) begin
          incrDLISTL <= 1'b0;
          DLISTL <= DLISTL + 8'd1;
        end
        if (loadDLISTL)
          DLISTL <= IR;
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

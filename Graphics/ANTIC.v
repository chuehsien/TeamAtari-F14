// top module for the ANTIC processor.
// last updated: 10/21/2014 2330H

`include "ANTIC_dataTranslate.v"

`define FSMinit     2'b00
`define FSMload1    2'b01
`define FSMload2    2'b10
`define FSMidle     2'b11
`define DMA_off     1'b0
`define DMA_on      1'b1

module ANTIC(Fphi0, LP_L, RW, rst, vblank, hblank, DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, 
             WSYNC, NMIEN, DB, NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, address, AN, 
             halt_L, NMI_L, RDY_L, REF_L, RNMI_L, phi0, IR_out, loadIR, VCOUNT, PENH, PENV, 
             ANTIC_writeEn, charMode, numLines, width, height,
             printDLIST, currState, data, MSR, loadMSR_both, loadDLIST_both,
             IR_rdy, mode, numBytes, MSRdata, DLISTL, blankCount, addressIn, loadMSRdata, 
             charData, newDLISTptr, loadDLIST, DLISTend, idle, loadMSRstate);

      input Fphi0;
      input LP_L;
      input RW;
      input rst;
      input vblank;
      input hblank;
      
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
      output [3:0] AN;
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
      output [1:0] numLines;
      output [8:0] width;
      output [7:0] height;
      
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
      output [15:0] addressIn;
      output loadMSRdata;
      output [63:0] charData;
      output [15:0] newDLISTptr;
      output loadDLIST;
      output DLISTend;
            
      //temp
      output idle;
      output [1:0] loadMSRstate;
      //endtemp
      
      
      // * TODO: Add initialization vectors
      reg DMA = `DMA_off;
      reg loadAddr = 1'b0;
      reg IR_rdy = 1'b0;
      reg [7:0] IR;
      reg [1:0] currState = `FSMinit;
      reg [1:0] nextState;
      reg [15:0] addressIn;
      reg [15:0] MSR;
      reg [7:0] MSRdata;
      reg MSRdata_rdy = 1'b0;
      reg charLoaded = 1'b0;
      reg [63:0] charData;
      reg [7:0] charByte = 8'd0;
      reg [7:0] DLISTL;
      reg incrDLIST = 1'b0;
      reg loadMSRdata_hold = 1'b0;
      reg [15:0] newDLISTptr= 16'd0;
      
      wire [7:0] data;
      wire loadIR;
      wire loadDLISTL;
      wire loadDLISTH;
      wire loadPtr;
      wire loadMSRL;
      wire loadMSRH;
      wire incrMSR;
      wire loadMSRdata;
      wire charMode;
      wire [1:0] colorSel;
      wire loadChar;
      wire loadDLIST;
      wire ANTIC_writeDLIST;
      wire [7:0] data_reverse;
      wire [7:0] MSRdata_reverse;

      
      // * Temp:
      assign printDLIST = {DLISTH_bus, DLISTL_bus};
      assign halt_L = ~DMA;
      assign IR_out = IR;
      assign loadDLIST_both = {loadDLISTH, loadDLISTL};
      assign loadMSR_both = {loadMSRH, loadMSRL};
      // End Temp *
      
      assign colorSel = MSRdata[7:6];

      // Module instantiations
      AddressBusReg addr(.load(loadAddr), .incr(incrDLIST), .addressIn(addressIn), .addressOut(address));
      dataReg dreg(.clk(Fphi0), .DMA(DMA), .dataIn(DB), .data(data));
      dataTranslate dt(.IR(IR), .IR_rdy(IR_rdy), .Fphi0(Fphi0), .rst(rst), .vblank(vblank), .DMACTL(DMACTL), .MSRdata_rdy(MSRdata_rdy), 
                       .charData(charData), .colorSel(colorSel), .charLoaded(charLoaded), .MSRdata_reverse(MSRdata_reverse),
                       .AN(AN), .loadIR(loadIR),
                       .loadDLISTL(loadDLISTL), .loadDLISTH(loadDLISTH),
                       .loadPtr(loadPtr), .loadMSRL(loadMSRL), .loadMSRH(loadMSRH), .incrMSR(incrMSR), .loadMSRdata(loadMSRdata),
                       .mode(mode), .numBytes(numBytes), .charMode(charMode), .loadChar(loadChar),
                       .blankCount(blankCount), .loadDLIST(loadDLIST), .ANTIC_writeDLIST(ANTIC_writeDLIST), .numLines(numLines),
                       .width(width), .height(height),
                       .idle(idle), .loadMSRstate(loadMSRstate), .DLISTend(DLISTend));
      
      // Update DLISTPTR (JUMP instruction)
      assign DLISTL_bus = loadDLIST ? newDLISTptr[7:0] : (incrDLIST ? DLISTL : 8'hzz);
      assign DLISTH_bus = loadDLIST ? newDLISTptr[15:8] : 8'hzz;
      
      // Reverse character bits
      assign data_reverse = {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]};
      assign MSRdata_reverse = {MSRdata[0], MSRdata[1], MSRdata[2], MSRdata[3],
                                MSRdata[4], MSRdata[5], MSRdata[6], MSRdata[7]};
    
      // FSM to initialize
      always @ (posedge Fphi0 or posedge rst) begin
        
        // * TODO: Add all reset vectors (based on initialization vectors
        if (rst) begin
          VCOUNT <= 8'd0;
          PENH <= 8'd0;
          PENV <= 8'd0;
          ANTIC_writeEn <= 3'd0;
          DMA <= `DMA_off;
          loadAddr <= 1'b0;
          IR_rdy <= 1'b0;
          MSRdata_rdy <= 1'b0;
          charLoaded <= 1'b0;
          charByte <= 8'd0;
          incrDLIST <= 1'b0;
          loadMSRdata_hold <= 1'b0;
          newDLISTptr <= 16'd0;
        end
           
        else begin
        
          // * TODO: Add vertical blank occurrence signal to dataTranslate module
          
          // Memory Scan Register changes
          if (loadMSRL)
            MSR[7:0] <= IR;
          else if (loadMSRH)
            MSR[15:8] <= IR;
            
          if (incrMSR)
            MSR <= MSR + 16'd1;
          
          if (loadDLISTL)
            newDLISTptr[7:0] <= IR;
          else if (loadDLISTH)
            newDLISTptr[15:8] <= IR;
          
          if (ANTIC_writeDLIST)
            ANTIC_writeEn <= 3'd2;
          else
            ANTIC_writeEn <= 3'd0;
        
          case (currState)
              `FSMinit:
                begin
                  nextState <= `FSMload1;
                  addressIn <= {DLISTH_bus, DLISTL_bus};
                  DLISTL <=  DLISTL_bus;
                  loadAddr <= 1'b1;
                  DMA <= `DMA_on;
                end
                
              `FSMload1:
                begin
                  nextState <= `FSMload2;
                  DMA <= `DMA_off;
                  IR_rdy <= 1'b0;
                  loadAddr <= 1'b0;
                  incrDLIST <= 1'b0;
                end
              
              `FSMload2:
                begin
                
                  /* Next State Logic */
                
                  // Continue loading instructions
                  if (loadIR) begin
                    nextState <= `FSMload1;  
                    DMA <= `DMA_on;
                  end
                  // Pause loading instruction
                  else
                    nextState <= `FSMidle;
                
                  /* Output Logic */

                  if (loadMSRdata_hold) begin
                    MSRdata <= data;
                    MSRdata_rdy <= 1'b1;
                    loadMSRdata_hold <= 1'b0;
                  end
                  
                  else if (loadChar) begin
                    case (charByte)
                      8'd0: charData[7:0] <= data_reverse;
                      8'd1: charData[15:8] <= data_reverse;
                      8'd2: charData[23:16] <= data_reverse;
                      8'd3: charData[31:24] <= data_reverse;
                      8'd4: charData[39:32] <= data_reverse;
                      8'd5: charData[47:40] <= data_reverse;
                      8'd6: charData[55:48] <= data_reverse;
                      8'd7: charData[63:56] <= data_reverse;
                    endcase
                    charByte <= charByte + 8'd1;
                    if (charByte == 8'd7)
                      charLoaded <= 1'b1;
                  end
                  
                  else begin
                    if (~loadPtr) begin
                      incrDLIST <= 1'b1;
                      DLISTL <= DLISTL + 8'd1;
                      ANTIC_writeEn <= 3'd1;
                    end
                    IR <= data;
                    IR_rdy <= 1'b1;
                  end
                end
                
              `FSMidle:
                begin
                  // Clear previously set control signals
                  IR_rdy <= 1'b0;
                  MSRdata_rdy <= 1'b0;
                  incrDLIST <= 1'b0;
                  
                  // Load next display list instruction
                  if (loadIR) begin
                    nextState <= `FSMload1;
                    DMA <= `DMA_on;
                    addressIn <= {DLISTH_bus, DLISTL_bus};
                    DLISTL <= DLISTL_bus;
                    loadAddr <= 1'b1;
                  end
                  
                  // Load Memory Scan Register data
                  else if (loadMSRdata) begin
                    nextState <= `FSMload1;
                    DMA <= `DMA_on;
                    addressIn <= MSR;
                    loadAddr <= 1'b1;
                    loadMSRdata_hold <= 1'b1;
                  end
                  
                  // Load characters from character set
                  else if (loadChar) begin
                    if (charByte < 8'd8) begin
                      nextState <= `FSMload1;
                      DMA <= `DMA_on;
                      charLoaded <= 1'b0;
                      addressIn <= {CHBASE, 8'h00} + (MSRdata*8) + charByte;
                      loadAddr <= 1'b1;
                    end
                    else begin
                      nextState <= `FSMidle;
                      charByte <= 8'd0;
                    end
                  end
                  
                  // Continue to idle state
                  else begin
                    charLoaded <= 1'b0;
                    nextState <= `FSMidle;
                  end
                end
          endcase
        end
      end
      
      always @ (negedge Fphi0 or posedge rst) begin
        if (rst)
          currState <= `FSMinit;
        else
          currState <= nextState;
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
    else
      addressOut <= addressOut + 16'd1;
	end
	
endmodule


module dataReg(clk, DMA, dataIn, data);

	input clk;
  input DMA;
	input [7:0] dataIn;
	output reg [7:0] data;
  
	always @(posedge clk) begin
    if (DMA)
      data <= dataIn;
	end

endmodule

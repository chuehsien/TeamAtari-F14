// top module for the ANTIC processor.
// last updated: 10/21/2014 2330H

`include "Graphics/ANTIC_dataTranslate.v"

`define FSMinit     2'b00
`define FSMload1    2'b01
`define FSMload2    2'b10
`define FSMidle     2'b11
`define DMA_off     1'b0
`define DMA_on      1'b1

module ANTIC(Fphi0, LP_L, RW, rst, vblank, hblank, RDY, DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, 
             WSYNC, NMIEN, DB, NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, address, AN, 
             halt, NMI_L, RDY, REF_L, RNMI_L, phi0, IR_out, loadIR, VCOUNT, PENH, PENV, 
             ANTIC_writeEn, charMode, numLines, width, height,
             printDLIST, currState, MSR, loadMSR_both, loadDLIST_both,
             IR_rdy, mode, numBytes, MSRdata, DLISTL, blankCount, addressIn, loadMSRdata, 
             charData, newDLISTptr, loadDLIST, DLISTend, idle, loadMSRstate,
             addressOut, haltANTIC, rdyANTIC, colorSel4, ANTIC_writeNMI, incrY);

      input Fphi0;
      input LP_L;
      input RW;
      input rst;
      input vblank;
      input hblank;
      input RDY;
      
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
      output halt;
      output reg NMI_L = 1'b1;
      output REF_L;
      output RNMI_L;
      output phi0;
      output [7:0] IR_out;
      output loadIR;
      
      output [7:0] VCOUNT;
      output reg [7:0] PENH = 8'd0;
      output reg [7:0] PENV = 8'd0;
      output reg [2:0] ANTIC_writeEn = 3'd0;
      output [2:0] charMode;
      output [1:0] numLines;
      output [8:0] width;
      output [7:0] height;
      
      // Extras (remove later on)
      output [15:0] printDLIST;
      output [1:0] currState;
      output [15:0] MSR;
      output [1:0] loadDLIST_both;
      output [1:0] loadMSR_both;
      output IR_rdy;
      output [3:0] mode;
      output [6:0] numBytes;
      output [7:0] MSRdata;
      output [7:0] DLISTL;
      output [3:0] blankCount;
      output [15:0] addressIn;
      output loadMSRdata;
      output [63:0] charData;
      output [15:0] newDLISTptr;
      output loadDLIST;
      output DLISTend;
            
      //temp
      output idle;
      output [1:0] loadMSRstate;
      output [15:0] addressOut;
      output haltANTIC;
      output rdyANTIC;
      output [1:0] colorSel4;
      output ANTIC_writeNMI;
      //endtemp
      
      output incrY;
      
      assign haltANTIC = halt;
      assign rdyANTIC = RDY;
      
      // * TODO: Add initialization vectors
      reg DMA = `DMA_off;
      reg loadAddr = 1'b0;
      reg IR_rdy = 1'b0;
      reg [7:0] IR = 8'd0;
      reg [1:0] currState = `FSMinit;
      reg [1:0] nextState = `FSMinit;
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
      reg init = 1'b0;
      reg [15:0] VBI_count = 16'd0;
      reg ANTIC_initVBI = 1'b0;
      reg VBI_hold = 1'b0;
      reg VBI_hold2 = 1'b0;
      reg [7:0] WSYNC_prev = 8'd0;
      reg WSYNC_halt = 1'b0;
      reg reqBlank = 1'b0;
      reg [15:0] savedMSR = 16'd0;
      
      wire [15:0] addressOut;
      wire [7:0] data;
      wire loadIR;
      wire loadDLISTL;
      wire loadDLISTH;
      wire loadPtr;
      wire loadMSRL;
      wire loadMSRH;
      wire incrMSR;
      wire loadMSRdata;
      wire [1:0] colorSel;
      wire loadChar;
      wire loadDLIST;
      wire ANTIC_writeDLIST;
      wire [7:0] data_reverse;
      wire [7:0] MSRdata_reverse;
      wire DLIST_DMA_en = DMACTL[5];
      wire ANTIC_writeDLI;
      wire ANTIC_writeVBI;
      wire ANTIC_writeNMI;
      wire charSingleColor;
      wire update_WSYNC;
      wire blankScreen;
      wire saveMSR, resetMSR;
      
      // * Temp:
      assign printDLIST = {DLISTH_bus, DLISTL_bus};
      assign halt = DMA|WSYNC_halt;
      assign IR_out = IR;
      assign loadDLIST_both = {loadDLISTH, loadDLISTL};
      assign loadMSR_both = {loadMSRH, loadMSRL};
      // End Temp *
      
      assign address = (DMA & RDY) ? addressOut : 16'hzzzz;
      assign colorSel = MSRdata[7:6];

      // Module instantiations
      AddressBusRegANTIC addr(.clk(Fphi0), .load(loadAddr), .incr(incrDLIST), .addressIn(addressIn), .addressOut(addressOut));
      dataTranslate dt(.IR(IR), .IR_rdy(IR_rdy), .Fphi0(Fphi0), .rst(rst|(~DLIST_DMA_en)), .vblank(vblank), .DMACTL(DMACTL), .MSRdata_rdy(MSRdata_rdy), 
                       .charData(charData), .colorSel(colorSel), .charLoaded(charLoaded), .MSRdata_reverse(MSRdata_reverse),
                       .DMA(DMA), .RDY(RDY), .reqBlank(reqBlank), .AN(AN), .loadIR(loadIR),
                       .loadDLISTL(loadDLISTL), .loadDLISTH(loadDLISTH),
                       .loadPtr(loadPtr), .loadMSRL(loadMSRL), .loadMSRH(loadMSRH), .incrMSR(incrMSR), .loadMSRdata(loadMSRdata),
                       .mode(mode), .numBytes(numBytes), .charMode(charMode), .loadChar(loadChar),
                       .blankCount(blankCount), .loadDLIST(loadDLIST), .ANTIC_writeDLIST(ANTIC_writeDLIST), .numLines(numLines),
                       .width(width), .height(height), .ANTIC_writeDLI(ANTIC_writeDLI), .ANTIC_writeVBI(ANTIC_writeVBI),
                       .ANTIC_writeNMI(ANTIC_writeNMI),
                       .idle(idle), .loadMSRstate(loadMSRstate), .DLISTend(DLISTend), .charSingleColor(charSingleColor),
                       .colorSel4(colorSel4), .update_WSYNC(update_WSYNC), .VCOUNT(VCOUNT), .blankScreen(blankScreen),
                       .saveMSR(saveMSR), .resetMSR(resetMSR), .incrY(incrY));
      
      // Update DLISTPTR (JUMP instruction)
      assign DLISTL_bus = loadDLIST ? newDLISTptr[7:0] : (incrDLIST ? DLISTL : 8'hzz);
      assign DLISTH_bus = loadDLIST ? newDLISTptr[15:8] : 8'hzz;
      
      assign NMIRES_NMIST_bus = (ANTIC_writeDLI&(NMIEN[7])) ? 8'h80 : (((ANTIC_writeVBI|ANTIC_initVBI)&(NMIEN[6])) ? 8'h40 : 8'hzz);
      
      // Reverse character bits
      assign data_reverse = {DB[0], DB[1], DB[2], DB[3], DB[4], DB[5], DB[6], DB[7]};
      assign MSRdata_reverse = {MSRdata[0], MSRdata[1], MSRdata[2], MSRdata[3],
                                MSRdata[4], MSRdata[5], MSRdata[6], MSRdata[7]};
    
      // FSM to initialize
      always @ (posedge Fphi0 or posedge rst) begin
        
        // * TODO: Add all reset vectors (based on initialization vectors
        if (rst) begin
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
          IR <= 8'd0;
          init <= 1'b0;
          VBI_count <= 16'd0;
          ANTIC_initVBI <= 1'b0;
          NMI_L <= 1'b1;
          VBI_hold <= 1'b0;
          VBI_hold2 <= 1'b0;
          nextState <= `FSMinit;
          WSYNC_prev <= 8'd0;
          WSYNC_halt <= 1'b0;
          reqBlank <= 1'b0;
          savedMSR <= 16'd0;
        end
        
        // Wait for CPU initialization to complete
        else begin
          
          if (~init) begin //(init&blankScreen)) begin
            if (DLIST_DMA_en) begin
              init <= 1'b1;
              ANTIC_writeEn <= 3'd0;
              ANTIC_initVBI <= 1'b0;
              NMI_L <= 1'b1;
              VBI_hold <= 1'b0;
              VBI_hold2 <= 1'b0;
              reqBlank <= 1'b1;
            end
            
            // Initialization VBI
            if (VBI_count == 16'd65535) begin
              if (NMIEN[6]) begin
                ANTIC_writeEn <= 3'd6;
                ANTIC_initVBI <= 1'b1;
                VBI_count <= 16'd0;
                NMI_L <= 1'b1;
                VBI_hold <= 1'b1;
              end
              else
                VBI_count <= 16'd0;
            end
            else if (VBI_hold) begin
              ANTIC_writeEn <= 3'd0;
              ANTIC_initVBI <= 1'b0;
              NMI_L <= 1'b0;
              VBI_hold <= 1'b0;
              VBI_hold2 <= 1'b1;
            end
            else if (VBI_hold2) begin
              NMI_L <= 1'b0;
              VBI_hold2 <= 1'b0;
            end
            else begin
              VBI_count <= VBI_count + 16'd1;
              NMI_L <= 1'b1;
              VBI_hold <= 1'b0;
            end
              
          end
          
          else if (reqBlank) begin
            if (blankScreen)
              reqBlank <= 1'b0;
          end
           
          else begin
          
            // * TODO: Add vertical blank occurrence signal to dataTranslate module
            
            if (~DLIST_DMA_en) begin
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
              IR <= 8'd0;
              init <= 1'b0;
              VBI_count <= 16'd0;
              ANTIC_initVBI <= 1'b0;
              NMI_L <= 1'b1;
              VBI_hold <= 1'b0;
              VBI_hold2 <= 1'b0;
              nextState <= `FSMinit;
              WSYNC_prev <= WSYNC;
              WSYNC_halt <= 1'b0;
              reqBlank <= 1'b0;
            end
            
            else if (~(DMA&(~RDY))) begin
            
              ANTIC_writeEn <= 3'd0;

              if (update_WSYNC)
                WSYNC_prev <= WSYNC;
                
              if (WSYNC_prev != WSYNC)
                WSYNC_halt <= 1'b1;
              else
                WSYNC_halt <= 1'b0;

              if (ANTIC_writeDLIST&ANTIC_writeNMI) begin
                ANTIC_writeEn <= 3'd5;
                VBI_hold <= 1'b1;
              end
              else if (ANTIC_writeDLIST) begin
                ANTIC_writeEn <= 3'd2;
              end
              else if (ANTIC_writeNMI) begin
                ANTIC_writeEn <= 3'd6;
                VBI_hold <= 1'b1;
              end
              
              if (VBI_hold) begin
                NMI_L <= 1'b0;
                VBI_hold <= 1'b0;
                VBI_hold2 <= 1'b1;
              end
              else if (VBI_hold2) begin
                NMI_L <= 1'b0;
                VBI_hold2 <= 1'b0;
              end
              else
                NMI_L <= 1'b1;
              
              // Memory Scan Register changes
              if (loadMSRL)
                MSR[7:0] <= IR;
              else if (loadMSRH)
                MSR[15:8] <= IR;
                
              if (saveMSR)
                savedMSR <= MSR;
              
              if (resetMSR)
                MSR <= savedMSR;
                
              if (incrMSR)
                MSR <= MSR + 16'd1;
              
              if (loadDLISTL)
                newDLISTptr[7:0] <= IR;
              else if (loadDLISTH)
                newDLISTptr[15:8] <= IR;
            
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
                    //DMA <= `DMA_off;
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
                    else begin
                      nextState <= `FSMidle;
                      DMA <= `DMA_off;
                    end
                  
                    /* Output Logic */

                    if (loadMSRdata_hold) begin
                      MSRdata <= DB;
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
                        if (ANTIC_writeNMI) begin
                          ANTIC_writeEn <= 3'd4;
                          VBI_hold <= 1'b1;
                        end
                        else
                        ANTIC_writeEn <= 3'd1;
                      end
                      IR <= DB;
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
                        if (charSingleColor)
                          addressIn <= {CHBASE, 8'h00} + (MSRdata[5:0]*8) + charByte;
                        else
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
        end
      end
      
      always @ (negedge Fphi0 or posedge rst) begin
        if (rst)
          currState <= `FSMinit;
        else
          currState <= nextState;
      end
      
endmodule


module AddressBusRegANTIC(clk, load, incr, addressIn, addressOut);

  input clk;
	input load;
  input incr;
  input [15:0] addressIn;
	output reg [15:0] addressOut;
	
  always @ (negedge clk) begin
		if (load)
      addressOut <= addressIn;
    else if (incr)
      addressOut <= addressOut + 16'd1;
    else
      addressOut <= addressOut;
  end
	
endmodule

// top module for the ANTIC processor.
// last updated: 10/01/2014 1500H

`define FSMinit1		2'b00
`define FSMinit2	  2'b01
`define FSMinit3    2'b10
`define FSMnorm     2'b11
`define DMA_off     1'b0
`define DMA_on      1'b1

module ANTIC(F_phi0, LP_L, RW, RST, phi2, DB, address, AN, halt_L, NMI_L, RDY_L, REF_L, RNMI_L, phi0, printDLIST, cstate, data);

      input F_phi0;
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
      // extras
      output [15:0] printDLIST;
      output [1:0] cstate;
      output [7:0] data;
      
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
      
      reg DMA;
      reg ready_L;
      reg loadAddr;
      reg [1:0] curr_state;
      reg [1:0] next_state;
      reg [15:0] addressIn;
      wire [127:0] registers;
      wire [7:0] data;
      
      // * Temp:
      assign printDLIST = {DLISTH, DLISTL};
      assign halt_L = ~DMA;
      assign cstate = curr_state;
      // End Temp *
      
      assign registers = {NMI, NMIEN, PENV, PENH, VCOUNT, WSYNC,
                          CHBASE, 8'd0, PMBASE, 8'd0, VSCROL, HSCROL,
                          DLISTH, DLISTL, CHACTL, DMACTL};

      // Module instantiations
      
      AddressBusReg addr(.load(loadAddr), .incr(1'b0), .addressIn(addressIn), .addressOut(address));
      dataReg dreg(.phi2(phi2), .DMA(DMA), .dataIn(DB), .data(data));
      dataTranslate dt(.data(data), .phi2(phi2), .AN(AN));
    
      // FSM to initialize
      always @ (posedge phi2) begin

        case (curr_state)
            // Set or clear registers to default state
            `FSMinit1:
              begin
                next_state <= `FSMinit2;
                VCOUNT <= 8'd0;
                NMIEN <= 8'd0;
                DMACTL <= 8'd0;
                addressIn <= 16'h0230; // Shadow DLISTL register
                loadAddr <= 1'b1;
                DMA <= `DMA_on;
                // * Playfield DMA clock reset?
              end
            
            `FSMinit2:
              begin
                next_state <= `FSMinit3;
                
                addressIn <= 16'h0231; // Shadow DLISTH register
                loadAddr <= 1'b1;
              end
              
            `FSMinit3:
              begin
                next_state <= `FSMnorm;
                DLISTL <= data;
                DMA <= `DMA_off;
              end
            
            `FSMnorm:
              begin
                next_state <= `FSMnorm;
                DLISTH <= data;
                
                
                // * Sync hardware registers and RAM shadow registers?
                // * Other DMA operations?
              end
        endcase
      end
      
      always @ (negedge phi2) begin
        if (RST)
          curr_state <= `FSMinit1;
        else 
          curr_state <= next_state;
        
        loadAddr <= 1'b0;
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
      addressOut <= addressOut + 1'b1;
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


// To translate display list commands into AN[2:0] bits to GTIA
module dataTranslate(data, phi2, AN);
  
  input [7:0] data;
  input phi2;
  output reg [2:0] AN;
  
  reg [3:0] mode;
  
  // 1. Retrieve data from RAM via DMA
  // 2. Evaluate retrieved data
  // 3. Output bits to AN
  always @ (posedge phi2) begin
    
    mode <= data[3:0];
    case (mode)
    
      // Mode 0: Blank Lines
      4'h0:
        begin
          
          // Number of blank lines = data[6:4]
          
          // DLI modifier bit = data[7]
          
        end
      
      // Mode 1: Jump
      4'h1:
        begin
          
          // Jump to address (used for crossing over 1K boundary)
          if (data[6] == 1'b0)
            ;
            
          // Jump to address & wait for vertical blank (used to end the Display List)
          else if (data[6] == 1'b1)
            ;
          
        end
      
      // Mode 2: Character, 32/40/48 bytes per mode line, 8 TV scan lines per mode line, 1.5 color
      4'h2:
        begin
        
        end
      
      // Mode 3: Character, 32/40/48 bytes per mode line, 10 TV scan lines per mode line, 1.5 color
      4'h3:
        begin
        
        end
      
      // Mode 4: Character, 32/40/48 bytes per mode line, 8 TV scan lines per mode line, 5 color      
      4'h4:
        begin
        
        end
      
      // Mode 5: Character, 32/40/48 bytes per mode line, 16 TV scan lines per mode line, 5 color
      4'h5:
        begin
        
        end
      
      // Mode 6: Character, 16/20/24 bytes per mode line, 8 TV scan lines per mode line, 5 color      
      4'h6:
        begin
        
        end
        
      // Mode 7: Character, 16/20/24 bytes per mode line, 16 TV scan lines per mode line, 5 color  
      4'h7:
        begin
        
        end
      
      // Mode 8: Map, 8/10/12 bytes per mode line, 8 TV scan lines per mode line, 4 color
      4'h8:
        begin
        
        end
      
      // Mode 9: Map, 8/10/12 bytes per mode line, 4 TV scan lines per mode line, 2 color
      4'h9:
        begin
        
        end
      
      // Mode 10: Map, 16/20/24 bytes per mode line, 4 TV scan lines per mode line, 4 color
      4'hA:
        begin
        
        end
      
      // Mode 11: Map, 16/20/24 bytes per mode line, 2 TV scan lines per mode line, 2 color
      4'hB:
        begin
        
        end
      
      // Mode 12: Map, 16/20/24 bytes per mode line, 1 TV scan lines per mode line, 2 color
      4'hC:
        begin
        
        end
    
      // Mode 13: Map, 32/40/48 bytes per mode line, 2 TV scan lines per mode line, 4 color
      4'hD:
        begin
        
        end
      
      // Mode 14: Map, 32/40/48 bytes per mode line, 1 TV scan lines per mode line, 4 color
      4'hE:
        begin
        
        end
      
      // Mode 15: Map, 32/40/48 bytes per mode line, 1 TV scan lines per mode line, 1.5 color
      4'hF:
        begin
        
        end
      
    endcase
  
  end
  

endmodule





// Top module to display output to DVI
// last updated: 10/13/2014 1800H
// Adapted from Team Dragonforce

`include "Graphics/DVI_IIC.v"
`include "Graphics/DVI_ODDR.v"
`include "Graphics/DVI_syncgen.v"

`define init 1'b0
`define idle 1'b1

module DVI(clock, reset, data, SDA, SCL, DVI_V, DVI_H, DVI_D, DVI_XCLK_P,
                DVI_XCLK_N, DVI_DE, DVI_RESET_B, request);

  input clock;
  input reset;
  input [63:0] data;
  
  inout SDA;
  inout SCL;
  
  output DVI_V, DVI_H;
  output [11:0] DVI_D;
  output DVI_XCLK_P, DVI_XCLK_N;
  output DVI_DE;
  output DVI_RESET_B;
  output reg request = 1'b0;
  
  wire reset;
  wire IIC_done;
  wire border;
  wire vs, hs;
  
  reg offset = 1'b1;
  reg next_offset = 1'b0;
  reg state = `init;
  reg sync_reset = 1'b1;
  
  assign DVI_RESET_B = ~reset;

  // Instantiate modules
  DVI_ODDR oddr(.data(data), .offset(offset), .border(border), .clock(clock),
                .hs(hs), .vs(vs), .DVI_XCLK_P(DVI_XCLK_P), .DVI_XCLK_N(DVI_XCLK_N),
                .DVI_DE(DVI_DE), .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D));
  
  SyncGen sync(.clock(clock), .rst(sync_reset|reset), .vs(vs), .hs(hs), .border(border));    // * TODO: Reset triggered when new data frame arrives

  IIC_init init(.clk(clock), .reset(reset), .pclk_gt_65MHz(1'b0),
                .SDA(SDA), .SCL(SCL), .done(IIC_done));
  
  // DVI output FSM
  always @(posedge clock or posedge reset) begin
    if (reset) begin
      state <= `init;
      offset <= 1'b1;
      sync_reset <= 1'b1;
	 end
    else begin
      case (state)
        `init:
          begin
            if (IIC_done) begin
              state <= `idle;
              sync_reset <= 1'b0;
            end
          end
        
        `idle:
          begin
            offset <= next_offset;
          end
      endcase
    end
  end
  
  // Data request and offset FSM
  always @(negedge clock or posedge reset) begin
    if (reset) begin
      next_offset <= 1'b0;
      request <= 1'b0;
    end
    
    else begin
      if (border) begin
        request <= 1'b0;
        next_offset <= offset;
      end
      else begin
        if (offset) begin
          next_offset <= 1'b0;
          request <= 1'b1;
        end
        else begin
          request <= 1'b0;
          next_offset <= 1'b1;
        end
      end
    end
	end
  
endmodule

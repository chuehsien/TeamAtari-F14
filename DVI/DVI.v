// Top module to display output to DVI
// last updated: 10/07/2014 0230H
// Adapted from Team Dragonforce

`include "DVI_ODDR.v"
`include "DVI_syncgen.v"
`include "DVI_IIC.v"

`define init 1'b0
`define idle 1'b1

module DVI(USER_CLK, GPIO_SW_C, IIC_SDA_VIDEO, IIC_SCL_VIDEO, DVI_V, DVI_H,
           DVI_D, DVI_XCLK_P, DVI_XCLK_N, DVI_DE, DVI_RESET_B);

	input USER_CLK;
	input GPIO_SW_C;
  inout IIC_SDA_VIDEO;
	inout IIC_SCL_VIDEO;
	output DVI_V, DVI_H;
	output [11:0] DVI_D;
	output DVI_XCLK_P, DVI_XCLK_N;
	output DVI_DE;
	output DVI_RESET_B;
	
  wire reset;
  wire clock;
  wire iic_done;
	wire border;
	wire vs, hs;
  
  reg state;
  
  assign clock = USER_CLK;
  assign reset = ~GPIO_SW_C;
	assign DVI_RESET_B = GPIO_SW_C;

  // Instantiate modules
  DVI_ODDR oddr(.border(border), .clock(clock), .hs(hs), .vs(vs), .x(x), .y(y),
                .DVI_XCLK_P(DVI_XCLK_P), .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE),
                .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D));
                //.data(data), .offset(offset)
  
  SyncGen sync(.clock(clock), .rst(reset), .vs(vs), .hs(hs), .border(border));    // * TODO: Reset triggered when new data frame arrives

	IIC_init init(.clock(clock), .reset(reset), .pclock_gt_65MHz(1'b0),
                .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO), .done(IIC_done));
  
  // DVI output FSM
  always @(posedge clock or posedge reset) begin
    
    if (reset)
      state <= `init;

    else begin
      case (state)
        `init:
          begin
            if (IIC_done)
              state <= `idle;
          end
        
        `idle:
          begin
            // Clock data in from source
          end
      endcase
    end
  end
  
endmodule           



/* Init state 
	assign dvi_xclock_p = 0;
	assign dvi_xclock_n = 0;
	assign dvi_de = 0;
	assign dvi_vs = 0;
	assign dvi_hs = 0;
	assign dvi_d = 0;
*/



	// wire [63:0]	data;			// From frame_dma of SimpleDMAReadController.v
	// wire		data_ready;		// From frame_dma of SimpleDMAReadController.v
	// wire		fifo_empty_0a;		// From frame_dma of SimpleDMAReadController.v

  // reg fifo_empty_1a = 1;
  // reg offset = 0; /* 0 if reading the first half of the 8 bytes for colors
                     // 1 if reading the second half of the 8 bytes for colors */
  // reg next_offset = 0;
  // reg request = 0;
  
/* 	always @(*) begin
		if (offset == 1) begin
			next_offset = 0;
			request = 1;
		end
		else begin
			request = 0;
			next_offset = 1;
		end
		if (border) begin
			request = 0;
			next_offset = offset;
		end	
	end

	always @ (posedge clock or posedge reset) begin
		if (reset) begin
			offset <= 0;
			fifo_empty_1a <= 1;
		end
		else begin
			offset <= next_offset;
			fifo_empty_1a <= fifo_empty_0a;
		end
	end */

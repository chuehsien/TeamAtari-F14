// Top module to display output to DVI
// last updated: 10/07/2014 1800H
// Adapted from Team Dragonforce

`include "DVI_ODDR.v"
`include "DVI_syncgen.v"
`include "DVI_IIC.v"

`define init 1'b0
`define idle 1'b1

module DVI(USER_CLK, GPIO_SW_C, IIC_SDA_VIDEO, IIC_SCL_VIDEO, DVI_V, DVI_H, DVI_D11, 
           DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5, DVI_D4, DVI_D3, DVI_D2, 
           DVI_D1, DVI_D0, DVI_XCLK_P, DVI_XCLK_N, DVI_DE, DVI_RESET_B);

  input USER_CLK;
  input GPIO_SW_C;
  inout IIC_SDA_VIDEO;
  inout IIC_SCL_VIDEO;
  output DVI_V, DVI_H;
  output DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5, DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0;
  output DVI_XCLK_P, DVI_XCLK_N;
  output DVI_DE;
  output DVI_RESET_B;

  wire reset;
  wire clock;
  wire IIC_done;
  wire border;
  wire vs, hs;
  wire [11:0] DVI_D;
  
  reg state;
  reg [1:0] count;
  
  assign clock = count[1];
  assign reset = ~GPIO_SW_C;
  assign DVI_RESET_B = GPIO_SW_C;

  assign DVI_D11 = DVI_D[11];
  assign DVI_D10 = DVI_D[10];
  assign DVI_D9 = DVI_D[9];
  assign DVI_D8 = DVI_D[8];
  assign DVI_D7 = DVI_D[7];
  assign DVI_D6 = DVI_D[6];
  assign DVI_D5 = DVI_D[5];
  assign DVI_D4 = DVI_D[4];
  assign DVI_D3 = DVI_D[3];
  assign DVI_D2 = DVI_D[2];
  assign DVI_D1 = DVI_D[1];
  assign DVI_D0 = DVI_D[0];

  // Instantiate modules
  DVI_ODDR oddr(.border(border), .clock(clock), .hs(hs), .vs(vs),
                .DVI_XCLK_P(DVI_XCLK_P), .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE),
                .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D));
                //.data(data), .offset(offset)
  
  SyncGen sync(.clock(clock), .rst(reset), .vs(vs), .hs(hs), .border(border));    // * TODO: Reset triggered when new data frame arrives

  IIC_init init(.clk(clock), .reset(reset), .pclk_gt_65MHz(1'b0),
                .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO), .done(IIC_done));
  
  always @(posedge USER_CLK) begin
    if (count == 2'b11)
      count <= 2'b00;
    else
      count <= count + 2'd1;
  end
  
  // DVI output FSM
  always @(posedge clock or posedge reset) begin
    
    if (reset) begin
      state <= `init;
	 end

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

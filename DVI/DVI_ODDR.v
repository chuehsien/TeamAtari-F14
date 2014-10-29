// Dedicated Dual Data Rate Output (ODDR) modules for DVI
// last updated: 10/07/2014 1800H

module DVI_ODDR(data, offset, border, clock, hs, vs, DVI_XCLK_P, DVI_XCLK_N, DVI_DE, DVI_V, DVI_H, DVI_D);

  input [63:0] data;
  input offset;
  input border;
  input clock;
  input hs, vs;
  output DVI_XCLK_P;
  output DVI_XCLK_N;
  output DVI_DE;
  output DVI_V;
  output DVI_H;
  output [11:0] DVI_D;
  
  `include "DVI_parameters.v"
  
  reg [7:0] red, green, blue;
  
  wire dvi_xclk_p_nodly, dvi_xclk_n_nodly;
  wire [7:0] red_p, green_p, blue_p;
  wire first_pixel, second_pixel;
  
  assign first_pixel = ~offset;
	assign second_pixel = offset;
  
  // Pixel assignment
  assign red_p   = (border) ? 8'h00 : (first_pixel) ? data[23:16] : (second_pixel) ? data[55:48] : 8'h00;
	assign green_p = (border) ? 8'h00 : (first_pixel) ?  data[15:8] : (second_pixel) ? data[47:40] : 8'h00;
	assign blue_p  = (border) ? 8'h00 : (first_pixel) ?   data[7:0] : (second_pixel) ? data[39:32] : 8'h00;
  
  // FSM to clock in RGB pixels
  always @(posedge clock) begin
		red <= red_p;
		green <= green_p;
		blue <= blue_p;
	end
  
  // ODDR module instantiations
  ODDR ODDR_DVI_XCLK_P(.C(clock), .Q(dvi_xclk_p_nodly), .D1(1'b1), .D2(1'b0), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_XCLK_N(.C(clock), .Q(dvi_xclk_n_nodly), .D1(1'b0), .D2(1'b1), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_DE(.C(clock), .Q(DVI_DE), .D1(~border), .D2(~border), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_VS(.C(clock), .Q(DVI_V), .D1(vs), .D2(vs), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_HS(.C(clock), .Q(DVI_H), .D1(hs), .D2(hs), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D0(.C(clock), .Q(DVI_D[0]), .D1(green[0]), .D2(red[4]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D1(.C(clock), .Q(DVI_D[1]), .D1(green[1]), .D2(red[5]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D2(.C(clock), .Q(DVI_D[2]), .D1(green[2]), .D2(red[6]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D3(.C(clock), .Q(DVI_D[3]), .D1(green[3]), .D2(red[7]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D4(.C(clock), .Q(DVI_D[4]), .D1(green[4]), .D2(blue[0]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D5(.C(clock), .Q(DVI_D[5]), .D1(green[5]), .D2(blue[1]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D6(.C(clock), .Q(DVI_D[6]), .D1(green[6]), .D2(blue[2]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D7(.C(clock), .Q(DVI_D[7]), .D1(green[7]), .D2(blue[3]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D8(.C(clock), .Q(DVI_D[8]), .D1(red[0]), .D2(blue[4]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D9(.C(clock), .Q(DVI_D[9]), .D1(red[1]), .D2(blue[5]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D10(.C(clock), .Q(DVI_D[10]), .D1(red[2]), .D2(blue[6]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D11(.C(clock), .Q(DVI_D[11]), .D1(red[3]), .D2(blue[7]), .R(1'b0), .S(1'b0), .CE(1'b1));
  
  buf b1(DVI_XCLK_P, dvi_xclk_p_nodly);
  buf b2(DVI_XCLK_N, dvi_xclk_n_nodly);
  
endmodule
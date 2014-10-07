// Dedicated Dual Data Rate Output (ODDR) modules for DVI
// last updated: 10/07/2014 0300H

module DVI_ODDR(border, clock, hs, vs, x, y, DVI_XCLK_P, DVI_XCLK_N, DVI_DE, DVI_V, DVI_H, DVI_D);

  //input [63:0] data;
  //input offset;
  
  input border;
  input clock;
  input hs, vs;
  input x, y;       // TEMP
  output DVI_XCLK_P;
  output DVI_XCLK_N;
  output DVI_DE;
  output DVI_V;
  output DVI_H;
  output [11:0] DVI_D;
  
  `include "DVI_parameters.v"
  
  reg [7:0] red, green, blue;
  
  /*
  wire [7:0] red_p, green_p, blue_p;
  wire first_pixel, second_pixel;
  
  // Actual pixel read from data, temporarily disabled
  
  assign first_pixel = (offset == 1'b0);
	assign second_pixel = (offset == 1'b1);
  
  // Pixel assignment
  assign red_p   = (border) ? 8'h00 : (second_pixel) ? data[63:56] : (first_pixel) ? data[31:24] : 8'hff;
	assign green_p = (border) ? 8'h00 : (second_pixel) ? data[55:48] : (first_pixel) ? data[23:16] : 8'h00;
	assign blue_p  = (border) ? 8'hff : (second_pixel) ? data[47:40] : (first_pixel) ? data[15:8] : 8'h00;
  
  // FSM to clock in RGB pixels
  always @(negedge clock) begin
		red <= red_p;
		green <= green_p;
		blue <= blue_p;
	end
  */
  
  // Temporary Test Module
  // Display 100% saturation color bars
  always @(negedge clock) begin
    // Check if within vertical active video range
    if (y >= YBPORCH && y < YFPORCH) begin
      // Check if within the active horizontal range, then
      // display different colors every 80 pixels
      // Display white bar
      if (x >= XBPORCH && x < (XBPORCH+80)) begin
        red <= 8'hFF;
        green <= 8'hFF;
        blue <= 8'hFF;
      end
      // Display yellow bar
      else if (x >= (XBPORCH+80) && x < (XBPORCH+160)) begin
        red <= 8'hFF;
        green <= 8'hFF;
        blue <= 8'h00;
      end
      // Display cyan bar
      else if (x >= (XBPORCH+160) && x < (XBPORCH+240)) begin
        red <= 8'h00;
        green <= 8'hFF;
        blue <= 8'hFF;
      end
      // Display green bar
      else if (x >= (XBPORCH+240) && x < (XBPORCH+320)) begin
        red <= 8'h00;
        green <= 8'hFF;
        blue <= 8'h00;
      end
      // Display magenta bar
      else if (x >= (XBPORCH+320) && x < (XBPORCH+400)) begin
        red <= 8'hFF;
        green <= 8'h00;
        blue <= 8'hFF;
      end
      // Display red bar
      else if (x >= (XBPORCH+400) && x < (XBPORCH+480)) begin
        red <= 8'hFF;
        green <= 8'h00;
        blue <= 8'h00;
      end
      // Display blue bar
      else if (x >= (XBPORCH+480) && x < (XBPORCH+560)) begin
        red <= 8'h00;
        green <= 8'h00;
        blue <= 8'hFF;
      end
      // Display black bar
      else if (x >= (XBPORCH+560) && x < (XBPORCH+640)) begin
        red <= 8'h00;
        green <= 8'h00;
        blue <= 8'h00;
      end
      // Beyond active horizontal range; Display black
      else begin
        red <= 8'h00;
        green <= 8'h00;
        blue <= 8'h00;
      end
    end
    // Beyond active vertical range; Display black
    else begin
      red <= 8'h00;
      green <= 8'h00;
      blue <= 8'h00;
    end
  end
  
  // ODDR module instantiations
  ODDR ODDR_DVI_XCLK_P(.C(clock), .Q(DVI_XCLK_P), .D1(1'b1), .D2(1'b0), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_XCLK_N(.C(clock), .Q(DVI_XCLK_N), .D1(1'b0), .D2(1'b1), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_DE(.C(clock), .Q(DVI_DE), .D1(~border), .D2(~border), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_VS(.C(clock), .Q(DVI_V), .D1(vs), .D2(vs), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_HS(.C(clock), .Q(DVI_H), .D1(hs), .D2(hs), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D0(.C(clock), .Q(DVI_D[0]), .D1(blue[0]), .D2(green[4]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D1(.C(clock), .Q(DVI_D[1]), .D1(blue[1]), .D2(green[5]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D2(.C(clock), .Q(DVI_D[2]), .D1(blue[2]), .D2(green[6]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D3(.C(clock), .Q(DVI_D[3]), .D1(blue[3]), .D2(green[7]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D4(.C(clock), .Q(DVI_D[4]), .D1(blue[4]), .D2(red[0]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D5(.C(clock), .Q(DVI_D[5]), .D1(blue[5]), .D2(red[1]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D6(.C(clock), .Q(DVI_D[6]), .D1(blue[6]), .D2(red[2]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D7(.C(clock), .Q(DVI_D[7]), .D1(blue[7]), .D2(red[3]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D8(.C(clock), .Q(DVI_D[8]), .D1(green[0]), .D2(red[4]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D9(.C(clock), .Q(DVI_D[9]), .D1(green[1]), .D2(red[5]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D10(.C(clock), .Q(DVI_D[10]), .D1(green[2]), .D2(red[6]), .R(1'b0), .S(1'b0), .CE(1'b1));
  ODDR ODDR_DVI_D11(.C(clock), .Q(DVI_D[11]), .D1(green[3]), .D2(red[7]), .R(1'b0), .S(1'b0), .CE(1'b1));
  
endmodule
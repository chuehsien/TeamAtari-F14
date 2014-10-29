// Synchronization module for DVI
// last updated: 10/07/2014 0300H

module SyncGen(clock, rst, vs, hs, border, x, y);

  input clock;
  input rst;
  output vs, hs;
  output border;
  output [11:0] x, y;

  `include "DVI_parameters.v"
  
  reg [11:0] x = 12'd0;
  reg [11:0] y = 12'd0;
  
  always @(posedge clock or posedge rst) begin

    // Reset the x & y coordinates
    if (rst) begin
      x <= 12'd0;
      y <= 12'd0;
    end
    
    else begin
      // x-coordinate is beyond horizontal screen limit
      if (x >= (XRES + XFPORCH + XSYNC + XBPORCH)) begin
        x <= 12'd0;
        // y-coordinate is beyond vertical screen limit
        if (y >= (YRES + YFPORCH + YSYNC + YBPORCH))
          y <= 12'd0;
        else
          y <= y + 12'd1;
      end
      else
        x <= x + 12'd1;
    end
  end

  assign hs = (x >= (XRES + XFPORCH)) && (x < (XRES + XFPORCH + XSYNC));
  assign vs = (y >= (YRES + YFPORCH)) && (y < (YRES + YFPORCH + YSYNC));
  assign border = (x < (XBPORCH+LMARGIN)) || (x >= (XBPORCH+LMARGIN+XDISPLAY)) || 
              (y < (YBPORCH+TMARGIN)) || (y >= (YBPORCH+TMARGIN+YDISPLAY));

endmodule

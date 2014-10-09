// Synchronization module for DVI
// last updated: 10/07/2014 0300H

module SyncGen(clock, rst, vs, hs, border);

  input clock;
  input rst;
  output reg vs, hs;
  output reg border;

  `include "DVI_parameters.v"
  
  reg [11:0] x, y;
  
  always @(posedge clock) begin

    // Reset the x & y coordinates
    if (rst) begin
      x <= 0;
      y <= 0;
    end
    
    else begin
      // x-coordinate is beyond horizontal screen limit
      if (x >= (XRES + XFPORCH + XSYNC + XBPORCH)) begin 
        x <= 0;
        // y-coordinate is beyond vertical screen limit
        if (y >= (YRES + YFPORCH + YSYNC + YBPORCH))
          y <= 0;
        else
          y <= y + 1;
      end
      else
        x <= x + 1;
    end
  end

  always @(*) begin
    hs = (x >= (XRES + XFPORCH)) && (x < (XRES + XFPORCH + XSYNC));
    vs = (y >= (YRES + YFPORCH)) && (y < (YRES + YFPORCH + YSYNC));
    border = (x <= (XBPORCH+LMARGIN)) || (x > (XBPORCH+LMARGIN+XDISPLAY)) || (y <= (YBPORCH+TMARGIN)) || (y > (YBPORCH+TMARGIN+YDISPLAY));
  end

endmodule

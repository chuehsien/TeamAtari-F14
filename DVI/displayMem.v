// Top module linking display buffer RAM and DVI output
// last updated: 10/13/2014 2200H

module displayMem(USER_CLK, GPIO_SW_C, IIC_SDA_VIDEO, IIC_SCL_VIDEO,
                  DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6, DVI_D5,
                  DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0, DVI_XCLK_P, DVI_XCLK_N,
                  DVI_V, DVI_H, DVI_DE, DVI_RESET_B);
  
  input USER_CLK;
  input GPIO_SW_C;
  
  inout IIC_SDA_VIDEO;
  inout IIC_SCL_VIDEO;

  output DVI_D11, DVI_D10, DVI_D9, DVI_D8, DVI_D7, DVI_D6,
         DVI_D5, DVI_D4, DVI_D3, DVI_D2, DVI_D1, DVI_D0;
  output DVI_XCLK_P, DVI_XCLK_N;
  output DVI_V, DVI_H;
  output DVI_DE;
  output DVI_RESET_B;
  
  wire clkA;
  wire clkB;
  wire rst;
  wire request;
  wire [63:0] doutB;
  wire [11:0] DVI_D;
  wire [31:0] dinA;
  
  reg [2:0] clkdiv = 3'd0;
  reg weA = 1'b0;
  reg [15:0] addrA = 16'd0;
  reg [23:0] RGB = 24'd0;
  reg [14:0] addrB = 15'd0;
  reg [9:0] count = 10'd0;
  reg incrAddrA = 1'b0;
  
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
  
  assign clkA = clkdiv[2]; // 25MHz
  assign clkB = clkdiv[1]; // 50MHz
  assign rst = GPIO_SW_C;
  
  assign dinA = {8'd0, RGB};
  
  // Chipscope temp wires
  wire [35:0] CONTROL0;
  wire [11:0] x, y;
  wire border;

  // Module instantiation
  displayBlockMem dbm(.clka(clkA), .wea(weA), .addra(addrA), .dina(dinA), .clkb(clkB),
                      .addrb(addrB), .doutb(doutB));
  
  DVI dvi(.clock(clkB), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
          .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
          .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
          .request(request), .x(x), .y(y), .border(border));

  // Chipscope (x, y, border, request, addrB)
  
  chipscope_icon icon (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
  );
  
  chipscope_ila_dvi ila (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(clkB), // IN
    .TRIG0(x), // IN BUS [11:0]
    .TRIG1(y), // IN BUS [11:0]
    .TRIG2(border), // IN BUS [0:0]
    .TRIG3(request), // IN BUS [0:0]
    .TRIG4(addrB), // IN BUS [14:0]
    .TRIG5(doutB) // IN BUS [63:0]
  );
  
  
  // End Chipscope


  // FSM to control DVI reads from port B
  always @(posedge request or posedge rst) begin
    if (rst) begin
      addrB <= 15'd0;
    end
    else begin
      if (addrB == 15'd30719)
        addrB <= 15'd0;
      else
        addrB <= addrB + 15'd1;
    end
  end
  
  // Temporary, to set color test bars in display memory
  always @(posedge clkA or posedge rst) begin
    if (rst) begin
      weA <= 1'b0;
      count <= 10'd0;
      incrAddrA <= 1'b0;
    end
    else begin
      if (addrA < 16'd61439) begin

        // Display White
        if (addrA < 7680)
          RGB <= 24'hFFFFFF;
        // Display Grey
        else if ((addrA >= 7680)&&(addrA < (7680*2)))
          RGB <= 24'hEBEBEB;
        // Display Yellow
        else if ((addrA >= (7680*2))&&(addrA < (7680*3)))
          RGB <= 24'hFFFF00;
        // Display Cyan
        else if ((addrA >= (7680*3))&&(addrA < (7680*4)))
          RGB <= 24'h00FFFF;
        // Display Green
        else if ((addrA >= (7680*4))&&(addrA < (7680*5)))
          RGB <= 24'h00FF00;
        // Display Magenta
        else if ((addrA >= (7680*5))&&(addrA < (7680*6)))
          RGB <= 24'hFF00FF;
        // Display Red
        else if ((addrA >= (7680*6))&&(addrA < (7680*7)))
          RGB <= 24'hFF0000;
        // Display Blue
        else
          RGB <= 24'h0000FF;
        
        /*
        if (count == 10'd319)
          count <= 10'd0;
        else
          count <= count + 10'd1;
        */
        
        weA <= 1'b1;
        incrAddrA <= 1'b1;
      end
      else begin
        weA <= 1'b0;
        incrAddrA <= 1'b0;
      end
    end
  end
  
  always @(negedge clkA or posedge rst) begin
  
    if (rst)
      addrA <= 16'd0;
      
    else begin
      if (incrAddrA)
        addrA <= addrA + 16'd1;
      else
        addrA <= 16'd0;
    end
  end
  
  always @(posedge USER_CLK) begin
    if (clkdiv == 3'd7)
      clkdiv <= 3'd0;
    else
      clkdiv <= clkdiv + 3'd1;
  end
  
endmodule
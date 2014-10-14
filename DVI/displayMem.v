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
  
  reg [2:0] clkdiv;
  reg weA;
  reg [15:0] addrA;
  reg [23:0] RGB;
  reg [14:0] addrB;
  reg [9:0] count;
  
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
  assign rst = ~GPIO_SW_C;
  
  assign dinA = {8'd0, RGB};

  // Module instantiation
  displayBlockMem dbm(.clka(clkA), .wea(weA), .addra(addrA), .dina(dinA), .clkb(clkB),
                      .addrb(addrB), .doutb(doutB));
  
  DVI dvi(.clock(clkB), .reset(rst), .data(doutB), .SDA(IIC_SDA_VIDEO), .SCL(IIC_SCL_VIDEO),
          .DVI_V(DVI_V), .DVI_H(DVI_H), .DVI_D(DVI_D), .DVI_XCLK_P(DVI_XCLK_P), 
          .DVI_XCLK_N(DVI_XCLK_N), .DVI_DE(DVI_DE), .DVI_RESET_B(DVI_RESET_B),
          .request(request));

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
      addrA <= 16'd0;
      weA <= 1'b0;
      count <= 10'd0;
    end
    else begin
      if (addrA < 16'd61440) begin

        // Display White
        if (count < 10'd40)
          RGB <= 24'hFFFFFF;
        // Display Grey
        else if ((count >= 10'd40)&&(count < 10'd80))
          RGB <= 24'hEBEBEB;
        // Display Yellow
        else if ((count >= 10'd80)&&(count < 10'd120))
          RGB <= 24'hFFFF00;
        // Display Cyan
        else if ((count >= 10'd120)&&(count < 10'd160))
          RGB <= 24'h00FFFF;
        // Display Green
        else if ((count >= 10'd160)&&(count < 10'd200))
          RGB <= 24'h00FF00;
        // Display Magenta
        else if ((count >= 10'd200)&&(count < 10'd240))
          RGB <= 24'hFF00FF;
        // Display Red
        else if ((count >= 10'd240)&&(count < 10'd280))
          RGB <= 24'hFF0000;
        // Display Blue
        else
          RGB <= 24'h0000FF;
        
        if (count == 10'd319)
          count <= 10'd0;
        else
          count <= count + 10'd1;
        
        weA <= 1'b1;
        addrA <= addrA + 16'd1;
      end
      else begin
        weA <= 1'b0;
      end
    end
  end
  
  always @(posedge USER_CLK) begin
    if (clkdiv == 3'd7)
      clkdiv <= 3'd0;
    else
      clkdiv <= clkdiv + 3'd1;
  end
  
endmodule
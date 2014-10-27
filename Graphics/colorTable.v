// Color table module
// Last updated: 10/21/2014 2330H

`include "colorDef.v"

module colorTable(colorData, RGB);

  input [7:0] colorData;
  output reg [23:0] RGB;
  
  wire [3:0] color = colorData[7:4];
  wire [2:0] lum = colorData[3:1];
  
  always @(*) begin
  
    case (color)
    
      `color_grey:
        begin
          case (lum)
            `lum_0: RGB <= 24'h000000;
            `lum_1: RGB <= 24'h404040;
            `lum_2: RGB <= 24'h6c6c6c;
            `lum_3: RGB <= 24'h909090;
            `lum_4: RGB <= 24'hb0b0b0;
            `lum_5: RGB <= 24'hc8c8c8;
            `lum_6: RGB <= 24'hdcdcdc;
            `lum_7: RGB <= 24'hececec;
          endcase
        end
        
      `color_gold:
        begin
          case (lum)
            `lum_0: RGB <= 24'h444400;
            `lum_1: RGB <= 24'h646410;
            `lum_2: RGB <= 24'h848424;
            `lum_3: RGB <= 24'ha0a034;
            `lum_4: RGB <= 24'hb8b840;
            `lum_5: RGB <= 24'hd0d050;
            `lum_6: RGB <= 24'he8e85c;
            `lum_7: RGB <= 24'hfcfc68;
          endcase
        end
      
      `color_orange:
        begin
          case (lum)
            `lum_0: RGB <= 24'h702800;
            `lum_1: RGB <= 24'h844414;
            `lum_2: RGB <= 24'h985c28;
            `lum_3: RGB <= 24'hac783c;
            `lum_4: RGB <= 24'hbc8c4c;
            `lum_5: RGB <= 24'hcca05c;
            `lum_6: RGB <= 24'hdcb468;
            `lum_7: RGB <= 24'hecc878;
          endcase
        end
      
      `color_red_orange:
        begin
          case (lum)
            `lum_0: RGB <= 24'h841800;
            `lum_1: RGB <= 24'h983418;
            `lum_2: RGB <= 24'hac5030;
            `lum_3: RGB <= 24'hc06848;
            `lum_4: RGB <= 24'hd0805c;
            `lum_5: RGB <= 24'he09470;
            `lum_6: RGB <= 24'heca880;
            `lum_7: RGB <= 24'hfcbc94;
          endcase
        end
      
      `color_pink:
        begin
          case (lum)
            `lum_0: RGB <= 24'h880000;
            `lum_1: RGB <= 24'h9c2020;
            `lum_2: RGB <= 24'hb03c3c;
            `lum_3: RGB <= 24'hc05858;
            `lum_4: RGB <= 24'hd07070;
            `lum_5: RGB <= 24'he08888;
            `lum_6: RGB <= 24'heca0a0;
            `lum_7: RGB <= 24'hfcb4b4;
          endcase
        end
      
      `color_purple:
        begin
          case (lum)
            `lum_0: RGB <= 24'h78005c;
            `lum_1: RGB <= 24'h8c2074;
            `lum_2: RGB <= 24'ha03c88;
            `lum_3: RGB <= 24'hb0589c;
            `lum_4: RGB <= 24'hc070b0;
            `lum_5: RGB <= 24'hd084c0;
            `lum_6: RGB <= 24'hdc9cd0;
            `lum_7: RGB <= 24'hecb0e0;
          endcase
        end
      
      `color_purple_blue:
        begin
          case (lum)
            `lum_0: RGB <= 24'h480078;
            `lum_1: RGB <= 24'h602090;
            `lum_2: RGB <= 24'h783ca4;
            `lum_3: RGB <= 24'h8c58b8;
            `lum_4: RGB <= 24'ha070cc;
            `lum_5: RGB <= 24'hb484dc;
            `lum_6: RGB <= 24'hc49cec;
            `lum_7: RGB <= 24'hd4b0fc;
          endcase
        end
      
      `color_blue:
        begin
          case (lum)
            `lum_0: RGB <= 24'h140084;
            `lum_1: RGB <= 24'h302098;
            `lum_2: RGB <= 24'h4c3cac;
            `lum_3: RGB <= 24'h6858c0;
            `lum_4: RGB <= 24'h7c70d0;
            `lum_5: RGB <= 24'h9488e0;
            `lum_6: RGB <= 24'ha8a0ec;
            `lum_7: RGB <= 24'hbcb4fc;
          endcase
        end
      
      `color_blue1:
        begin
          case (lum)
            `lum_0: RGB <= 24'h000088;
            `lum_1: RGB <= 24'h1c209c;
            `lum_2: RGB <= 24'h3840b0;
            `lum_3: RGB <= 24'h505cc0;
            `lum_4: RGB <= 24'h6874d0;
            `lum_5: RGB <= 24'h7c8ce0;
            `lum_6: RGB <= 24'h90a4ec;
            `lum_7: RGB <= 24'ha4b8fc;
          endcase
        end
      
      `color_light_blue:
        begin
          case (lum)
            `lum_0: RGB <= 24'h00187c;
            `lum_1: RGB <= 24'h1c3890;
            `lum_2: RGB <= 24'h3854a8;
            `lum_3: RGB <= 24'h5070bc;
            `lum_4: RGB <= 24'h6888cc;
            `lum_5: RGB <= 24'h7c9cdc;
            `lum_6: RGB <= 24'h90b4ec;
            `lum_7: RGB <= 24'ha4c8fc;
          endcase
        end
      
      `color_turquoise:
        begin
          case (lum)
            `lum_0: RGB <= 24'h002c5c;
            `lum_1: RGB <= 24'h1c4c78;
            `lum_2: RGB <= 24'h386890;
            `lum_3: RGB <= 24'h5084ac;
            `lum_4: RGB <= 24'h689cc0;
            `lum_5: RGB <= 24'h7cb4d4;
            `lum_6: RGB <= 24'h90cce8;
            `lum_7: RGB <= 24'ha4e0fc;
          endcase
        end
      
      `color_green_blue:
        begin
          case (lum)
            `lum_0: RGB <= 24'h003c2c;
            `lum_1: RGB <= 24'h1c5c48;
            `lum_2: RGB <= 24'h387c64;
            `lum_3: RGB <= 24'h509c80;
            `lum_4: RGB <= 24'h68b494;
            `lum_5: RGB <= 24'h7cd0ac;
            `lum_6: RGB <= 24'h90e4c0;
            `lum_7: RGB <= 24'ha4fcd4;
          endcase
        end
      
      `color_green:
        begin
          case (lum)
            `lum_0: RGB <= 24'h003c00;
            `lum_1: RGB <= 24'h205c20;
            `lum_2: RGB <= 24'h407c40;
            `lum_3: RGB <= 24'h5c9c5c;
            `lum_4: RGB <= 24'h74b474;
            `lum_5: RGB <= 24'h8cd08c;
            `lum_6: RGB <= 24'ha4e4a4;
            `lum_7: RGB <= 24'hb8fcb8;
          endcase
        end
      
      `color_yellow_green:
        begin
          case (lum)
            `lum_0: RGB <= 24'h143800;
            `lum_1: RGB <= 24'h345c1c;
            `lum_2: RGB <= 24'h507c38;
            `lum_3: RGB <= 24'h6c9850;
            `lum_4: RGB <= 24'h84b468;
            `lum_5: RGB <= 24'h9ccc7c;
            `lum_6: RGB <= 24'hb4e490;
            `lum_7: RGB <= 24'hc8fca4;
          endcase
        end
      
      `color_orange_green:
        begin
          case (lum)
            `lum_0: RGB <= 24'h2c3000;
            `lum_1: RGB <= 24'h4c501c;
            `lum_2: RGB <= 24'h687034;
            `lum_3: RGB <= 24'h848c4c;
            `lum_4: RGB <= 24'h9ca864;
            `lum_5: RGB <= 24'hb4c078;
            `lum_6: RGB <= 24'hccd488;
            `lum_7: RGB <= 24'he0ec9c;
          endcase
        end
      
      `color_light_green:
        begin
          case (lum)
            `lum_0: RGB <= 24'h442800;
            `lum_1: RGB <= 24'h644818;
            `lum_2: RGB <= 24'h846830;
            `lum_3: RGB <= 24'ha08444;
            `lum_4: RGB <= 24'hb89c58;
            `lum_5: RGB <= 24'hd0b46c;
            `lum_6: RGB <= 24'he8cc7c;
            `lum_7: RGB <= 24'hfce08c;
          endcase
        end
    
    endcase

  end

endmodule

module KB_modify (keycode_latch, KBCODE_4_1);

    input [3:0] keycode_latch;
    
    output [3:0] KBCODE_4_1;
    
    reg [3:0] KBCODE_4_1_reg;
    
    assign KBCODE_4_1 = KBCODE_4_1_reg;
    
    always @ (keycode_latch)
        case (keycode_latch)
            4'h0: KBCODE_4_1_reg = 4'b0000;
            4'h1: KBCODE_4_1_reg = 4'b0011;
            4'h2: KBCODE_4_1_reg = 4'b0010;
            4'h3: KBCODE_4_1_reg = 4'b0001;
            4'h4: KBCODE_4_1_reg = 4'b1100;
            4'h5: KBCODE_4_1_reg = 4'b1111;
            4'h6: KBCODE_4_1_reg = 4'b1110;
            4'h7: KBCODE_4_1_reg = 4'b1101;
            4'h8: KBCODE_4_1_reg = 4'b1000;
            4'h9: KBCODE_4_1_reg = 4'b1011;
            4'ha: KBCODE_4_1_reg = 4'b1010;
            4'hb: KBCODE_4_1_reg = 4'b1001;
            4'hc: KBCODE_4_1_reg = 4'b0100;
            4'hd: KBCODE_4_1_reg = 4'b0111;
            4'he: KBCODE_4_1_reg = 4'b0110;
            4'hf: KBCODE_4_1_reg = 4'b0101;
        endcase

        /* 
            Key     keycode_latch       KBCODE bits
            <none>  0000                0000
            #       3                   0001
            0       2                   0010
            *       1                   0011
            3       7                   1101
            2       6                   1110
            1       5                   1111
            START   4                   1100
            6       B                   1001
            5       A                   1010
            4       9                   1011
            PAUSE   8                   1000
            9       F                   0101
            8       E                   0110
            7       D                   0111
            RESET   C                   0100
        */

endmodule
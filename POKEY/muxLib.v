module demux (A, sel, Y);
    input A;
    input [1:0] sel;
    output [3:0] Y;
    
    reg [3:0] Y;
    
    always @ (A or sel) begin
        case (sel)
            2'b00: Y = {~A, ~A, ~A, A};
            2'b01: Y = {~A, ~A, A, ~A};
            2'b10: Y = {~A, A, ~A, ~A};
            2'b11: Y = {A, ~A, ~A, ~A};
				
				/*2'b00: Y = {A, A, A, A};
            2'b01: Y = {A, A, A, A};
            2'b10: Y = {A, A, A, A};
            2'b11: Y = {A, A, A, A};*/
				
				/*2'b00: Y = {~A, ~A, ~A, ~A};
            2'b01: Y = {~A, ~A, ~A, ~A};
            2'b10: Y = {~A, ~A, ~A, ~A};
            2'b11: Y = {~A, ~A, ~A, ~A};*/
				
            default: Y = {~A, ~A, ~A, ~A};
        endcase
    end

endmodule

module testDemux;
    reg A;
    reg [1:0] sel;
    wire [3:0] Y;
    
    demux demux_mod(A, sel, Y);
    
    initial begin
        A = 1'b0;
        sel = 2'b00;
        #10;
        $display("Y is: %b\n", Y);
        A = 1'b1;
        sel = 2'b00;
        #10;
        $display("Y is: %b\n", Y);
        A = 1'b0;
        sel = 2'b01;
        #10;
        $display("Y is: %b\n", Y);
        A = 1'b0;
        sel = 2'b10;
        #10;
        $display("Y is: %b\n", Y);
        A = 1'b0;
        sel = 2'b11;
        #10;
        $display("Y is: %b\n", Y);
        $finish;
    end
    
    
endmodule


module mux (Y, sel, A);
    
    input [3:0] Y;
    input [1:0] sel;
    output A;
    
    reg A;
    
    always @ (Y or sel) begin
        case (sel)
            2'b00: A = Y[0];
            2'b01: A = Y[1];
            2'b10: A = Y[2];
            2'b11: A = Y[3];
        endcase
    end


endmodule


module testMux;
    
    reg [3:0] Y;
    reg [1:0] sel;
    wire A;
    
    mux mux_mod(Y, sel, A);
    
    initial begin
        
        Y = 4'b0101;
        sel = 2'b00;
        #10;
        $display("A is : %b", A);
        Y = 4'b0101;
        sel = 2'b01;
        #10;
        $display("A is : %b", A);
        Y = 4'b0101;
        sel = 2'b10;
        #10;
        $display("A is : %b", A);
        Y = 4'b0101;
        sel = 2'b11;
        #10;
        $display("A is : %b", A);
        $finish;

    end

endmodule
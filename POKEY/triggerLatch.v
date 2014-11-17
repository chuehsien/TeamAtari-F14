module trig_latch (side_but, bottom_latch);

    input [1:0] side_but;
    
    output bottom_latch;
    
    
    reg bottom_latch_reg;
    
    assign bottom_latch = bottom_latch_reg;
    
    always @ (posedge side_but[0]) begin
        bottom_latch_reg <= 1'b1;
    end




endmodule
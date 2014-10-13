

module plaFSM(phi1,phi2,RDY,nextT, rst,brkNow,
                currT,intHandled, rstAll);
                

    input phi1,phi2,RDY,rst,brkNow;
    input [6:0] nextT;
    
    output reg[6:0] currT = `emptyT;
    output reg  intHandled, rstAll = 1'b0;
        
    //internal
    reg [2:0] currState, nextState = `FSMinit;
    reg [6:0] prevT = `emptyT;
    
    always @ (*) begin
        
        
        case (currState) 
            `FSMinit: begin
                if (nextT == `Tone) begin //finished BRK setup sequence
                    intHandled = 1'b1;
                    nextState = `FSMfetch;
                end
                else begin
                    intHandled = 1'b0;
                    nextState = currState;
                end
                
                //rstAll = (currT != `Ttwo) ? 1'b0:1'b1;
            end
            
            `FSMfetch: begin
                intHandled = 1'b0;
                if (brkNow) begin //timing issues. new opcode havent clock in.
                    nextState = `FSMexecBrk;
                end
                else nextState = `FSMexecNorm;
                
                //rstAll = 1'b0;
            end
            
            `FSMexecNorm: begin
                intHandled = 1'b0;
                
                if (nextT == `Tone || nextT == `T1NoBranch ||
                    nextT == `T1BranchNoCross || nextT == `T1BranchCross)
                    nextState = `FSMfetch;
                    
                else nextState = currState;
                
                
                //rstAll = 1'b0;
            end
            
            `FSMexecBrk: begin
                if (nextT == `Tone || nextT == `T1NoBranch ||
                    nextT == `T1BranchNoCross || nextT == `T1BranchCross) begin
                    nextState = `FSMfetch;
                    intHandled = 1'b1;
                end    
                else begin
                    nextState = currState;
                    intHandled = 1'b0;
                end
 
                //rstAll = 1'b0;
            end
        endcase

    end

    always @ (posedge phi1) begin
        if (RDY) begin
            
            if (rst) begin
                currT <= `Ttwo; //T2 of BRK.    
                currState <= `FSMinit;
                rstAll <= 1'b1;
                
            end
            else begin
                currT <= nextT;
                currState <= nextState;
                rstAll <= 1'b0;
            end
        end
    
    end
    
    /* not needed since fsmstate and Tstate doesnt change on phi2 ticks.
        always @ (posedge phi2) begin
        end
    */
endmodule

    
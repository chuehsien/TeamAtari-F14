

module plaFSM(haltAll,currState,phi1,phi2,RDY,nextT, rst,brkNow,
                currT,intHandled, rstAll);
                
    output [1:0] currState;
    input haltAll,phi1,phi2,RDY,rst,brkNow;
    input [6:0] nextT;
    
    output reg[6:0] currT = `emptyT;
    output reg  intHandled, rstAll = 1'b0;
        
    //internal
    reg [1:0] currState, nextState = `FSMinit;
    reg [6:0] prevT = `emptyT;
    reg nextIntHandled = 1'b0;
    always @ (*) begin
        
         nextState = `FSMinit;
         nextIntHandled = 1'b0;
        case (currState) 
            `FSMinit: begin
                nextIntHandled = 1'b0;
                if (nextT == `Tone) begin //finished BRK setup sequence
                    nextState = `FSMfetch;
                    nextIntHandled = 1'b1;
                end
                else begin 
                    nextState = currState;
                end
                
                //rstAll = (currT != `Ttwo) ? 1'b0:1'b1;
            end
            
            `FSMfetch: begin
                nextIntHandled = 1'b0;
                if (brkNow) begin //timing issues. new opcode havent clock in.
                    nextState = `FSMexecBrk;
                end
                else nextState = `FSMexecNorm;
                
                //rstAll = 1'b0;
            end
            
            `FSMexecNorm: begin
                nextIntHandled = 1'b0;
                
                if (nextT == `Tone || nextT == `T1NoBranch ||
                    nextT == `T1BranchNoCross || nextT == `T1BranchCross)
                    nextState = `FSMfetch;
                    
                else nextState = currState;
                
                
                //rstAll = 1'b0;
            end
            
            `FSMexecBrk: begin
                nextIntHandled = 1'b0;
                
                if (nextT == `Tzero) begin
                    nextIntHandled = 1'b1;
                end    
                else if (nextT == `Tone) begin
                    nextState = `FSMfetch;
                end
                else begin
                    nextState = currState;
                end
            end    
            default: begin
                    nextState = `FSMinit;
                    nextIntHandled = 1'b0;
            end
                
                
                //rstAll = 1'b0;
            
        endcase

    end

    always @ (posedge phi1) begin
        if (~haltAll) begin
            
            if (rst) begin
                currT <= `Ttwo; //T2 of BRK.    
                currState <= `FSMinit;
                rstAll <= 1'b1;
                intHandled <= nextIntHandled;
            end
            else begin
                currT <= nextT;
                currState <= nextState;
                rstAll <= 1'b0;
                intHandled <= nextIntHandled;
            end
        end
        else begin
                currT <= currT;
                currState <= currState;
                rstAll <= rstAll;
                intHandled <= intHandled;
        end
        
    
    end
    
    /* not needed since fsmstate and Tstate doesnt change on phi2 ticks.
        always @ (posedge phi2) begin
        end
    */
endmodule

    

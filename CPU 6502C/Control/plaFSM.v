/*
This is the top FSM modules which implements the opcode -> controlSignal state machine.
*/
 

`include "Control/FSMstateDef.v"
`include "Control/controlDef.v"
`include "Control/TDef.v"

module plaFSM(phi1,phi2,nmi,irq,rst,RDY, opcode, statusReg, 
                controlSigs, SYNC, T1next, nmiHandled, irqHandled, rstHandled, rstAll);
     
`include "Control/controlMods.v"               
    input phi1,phi2,nmi,irq,rst,RDY; //RDY is external input
    input [7:0] opcode, statusReg;
    output [62:0] controlSigs;
    output SYNC, T1next; //T1now is to signal predecode register to load in value.
    output nmiHandled, irqHandled, rstHandled, rstAll;
    
    wire phi1,phi2,nmi,irq,rst,RDY;
    wire [7:0] opcode;
    wire [7:0] statusReg;
    reg [62:0] controlSigs;
    reg SYNC;
    reg rstAll;
    wire T1next;
    reg nmiHandled, irqHandled, rstHandled;
    reg [2:0] active_interrupt;
    
    //internal variables. open_T and open_control are just holders, since u cant leave task outputs empty
    //reg [7:0] opcode;
    reg [62:0] curr_P1controlSigs, curr_P2controlSigs;
    reg [62:0] next_P1controlSigs, next_P2controlSigs;
    
    reg [2:0]       curr_state,next_state;
    reg [6:0]       curr_T,next_T,open_T;
    reg [7:0]       activeOpcode,nextOpcode;

    reg [2:0]       dummy_state; //just to hold intermediate values;
    reg [62:0]      dummy_control, open_control;
    reg [6:0]       dummy_T;
    reg [7:0]      leftOverSig; //to perform last SBAC/SBX/SBY controls in T2 of next instruction.
    //reg [3:0]      interruptArray; //from bit 0-3 : rst,nmi,irq,brk.
    
    reg rstNow;
    
    wire interruptPending;
    
    assign T1next = (next_T == `Tone || next_T == `T1NoBranch || 
                next_T == `T1BranchNoCross || next_T == `T1BranchCross); //might be wrong!
                      
    assign interruptPending = nmi|irq;
    /*
    //may not need this chunk if predecode logic handled it.
    always @ (curr_state) begin
        opcode = (interruptPending && (curr_state == `FSMFetch | curr_state == `FSMstall)) ? opcodeIn : 8'd00; //simulate a brk instruction.
    end
    */
    
    //wire loadIR;
   //and #(1,1) andgate(loadIR, phi1,RDY,T1now); 
    
    
    //always @ (posedge loadIR) begin
    // clock in new opcode - not required in full setup.
    //    opcode <= opcodeIn;
    //end
    
    always @ (curr_T)
        
    begin
        
        dummy_control = `emptyControl;
        dummy_T = `emptyT;
        dummy_state = 3'bxxx;
    
        rstHandled = 1'b0;
        nmiHandled = 1'b0;
        irqHandled = 1'b0;
        
        
        if (RDY) begin
            case(curr_state)
                `FSMinit: begin 
             
                //this is somewhat the prefetch stage, only for first cycle
                //when does the right opcode appear? not here. opcode is loaded when ticked into FSMfetch.
                
    
                    //get controls for the next T state.
                    
                    getControlsBrk(~phi1,~phi2,active_interrupt,curr_T,dummy_T, open_control);
                    
                    getControlsBrk(phi1,phi2,active_interrupt,dummy_T, open_T,next_P1controlSigs);  
                    getControlsBrk(~phi1,~phi2,active_interrupt,dummy_T, open_T,next_P2controlSigs); 
                    
                    next_T = dummy_T;

                    nextOpcode = 8'h00;
                    
                    if (curr_T == `Tone) SYNC = 1'd1;
                    else SYNC = 1'd0;
                    
                    if (dummy_T == `Tone) begin
                        //went one cycle and finished brk!
                        next_state = `FSMfetch;
                        active_interrupt = `NONE;
                        rstHandled = 1'b1;
                    end
                    else begin
                        next_state = curr_state;
                    end

                end

                `FSMfetch: begin
                    if (phi1) SYNC <= 1'd1;
                    //figure out which kind of instruction it is.
                    instructionType(opcode, dummy_state); //timing issues. new opcode havent clock in.
                    nextOpcode = opcode;
                    //entering new instruction, will always begin from T2.
                    if (dummy_state == `execNorm) begin
                        //get controls for the next T.

                        getControlsNorm(phi1,phi2,opcode, `Ttwo, open_T, next_P1controlSigs);
                        getControlsNorm(~phi1,~phi2,opcode, `Ttwo, open_T , next_P2controlSigs);
                        
                        

                    end
                    else if (dummy_state == `execRMW) begin
                        //get controls for the next T.
                        //getControlsRMW(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                        
                        getControlsRMW(phi1,phi2,statusReg,opcode, `Ttwo, open_T, next_P1controlSigs); // get next T
                        getControlsRMW(~phi1,~phi2,statusReg,opcode, `Ttwo, open_T , next_P2controlSigs); //get controls for new T
                       
                    end
                    else if (dummy_state == `execBranch) begin
                        //get controls for the next T.
                        //getControlsBranch(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                        
                        getControlsBranch(phi1,phi2,statusReg,opcode, `Ttwo, open_T, next_P1controlSigs); // get next T
                        getControlsBranch(~phi1,~phi2,statusReg,opcode, `Ttwo, open_T , next_P2controlSigs); //get controls for new T
                        
                        
                    end
                    else if (dummy_state == `execBrk) begin
                        //get controls for the next T.
                        //getControlsBrk(phi1,phi2,interruptArray,curr_T, dummy_T, open_control);
                        
                        getControlsBrk(phi1,phi2,active_interrupt,`Ttwo, open_T,next_P1controlSigs); //get next T 
                        getControlsBrk(~phi1,~phi2,active_interrupt,`Ttwo, open_T,next_P2controlSigs); //get controls for new T
                        
                    end
                    
                    next_state = dummy_state; //will go to either norm, rmw, or branch.
                    next_T = `Ttwo;

                end
                
/*                 `FSMstall: begin
                    if (phi1) SYNC <= 1'd0;
                    instructionType(opcode, dummy_state); //timing issues. new opcode havent clock in.
                    
                    if (RDY) begin
                        next_state <= dummy_state; //will go to either norm, rmw, or branch.
                        //get controlSigs for newstate;
                        getControls(phi1,phi2,dummy_state, opcode, curr_T, dummy_T,open_control); //get next state
                        getControls(phi1,phi2,dummy_state, opcode, dummy_T,open_T , dummy_control); //get controls for the next state
                        next_T <= dummy_T;
                        next_controlSigs <= dummy_control;
                    end
                    
                    else begin
                        next_state <= curr_state;
                        next_T <= curr_T;
                        next_controlSigs <= `controlStall;
                    end
                    
                end */
                
                `execNorm: begin //all fixed cycle instructions except BRK
                    if (phi1) SYNC = 1'd0;
                    //get controls for the next T.
                    getControlsNorm(phi1,phi2,opcode, curr_T, dummy_T, open_control);
                    
                    getControlsNorm(phi1,phi2,opcode, dummy_T, open_T, next_P1controlSigs);
                    getControlsNorm(~phi1,~phi2,opcode, dummy_T, open_T , next_P2controlSigs);
                    nextOpcode = opcode;
             
                    next_T = dummy_T;                   
                    
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state <= `FSMfetch;
                        
                    else next_state <= curr_state;
                               
                end
                
                `execBrk: begin //used to handle all interrupts
                    if (phi1) SYNC = 1'd0;

                    //get controls for the next T.
                    getControlsBrk(phi1,phi2,active_interrupt,curr_T, dummy_T, open_control);
                    
                    getControlsBrk(phi1,phi2,active_interrupt,dummy_T, open_T,next_P1controlSigs); //get next T 
                    getControlsBrk(~phi1,~phi2,active_interrupt,dummy_T, open_T,next_P2controlSigs); //get controls for new T
                    nextOpcode = opcode;
                    
                    next_T = dummy_T;
                    
                    if (dummy_T == `Tone) begin
                        next_state = `FSMfetch;
                        //done handling int, inform interrupt controller
                        if (active_interrupt == `RST_i) rstHandled = 1'b1;
                        if (active_interrupt == `IRQ_i) irqHandled = 1'b1;
                        if (active_interrupt == `NMI_i) nmiHandled = 1'b1;
                        
                        active_interrupt = `NONE;
                    end
                        
                    else next_state = curr_state;
                    
                    
                          
                end
                
                `execRMW: begin
                    if (phi1) SYNC = 1'd0;
                    //get controls for the next T.
                    getControlsRMW(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                    
                    getControlsRMW(phi1,phi2,statusReg,opcode, dummy_T, open_T, next_P1controlSigs); // get next T
                    getControlsRMW(~phi1,~phi2,statusReg,opcode, dummy_T, open_T , next_P2controlSigs); //get controls for new T
                    nextOpcode = opcode;
                    
                    next_T = dummy_T;
                    
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state = `FSMfetch;
                    else next_state = curr_state;              
                    
                end 

                `execBranch: begin
                    if (phi1) SYNC = 1'd0;
                    //get controls for the next T.
                    getControlsBranch(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                    
                    getControlsBranch(phi1,phi2,statusReg,opcode, dummy_T, open_T, next_P1controlSigs); // get next T
                    getControlsBranch(~phi1,~phi2,statusReg,opcode, dummy_T, open_T , next_P2controlSigs); //get controls for new T
                    nextOpcode = opcode;
                    
                    next_T = dummy_T;
                                           
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state = `FSMfetch;
                    else next_state = curr_state;
                    
                end

            endcase
            
            // handle leftover instructions (SBAC, SBX, SBY)
            findLeftOverSig(activeOpcode,next_T, leftOverSig);
            
            if (next_T == `Ttwo && phi1) begin
                next_P1controlSigs[leftOverSig] = 1'b1;
            end
        
            if (next_T == `Tzero || next_T == `TzeroNoCrossPg || next_T == `TzeroCrossPg) begin
                //check for interrupts
                //hierarchy of interrupts
                if (active_interrupt == `NONE) begin
                    if (rst) active_interrupt = `RST_i;
                    else if (nmi) active_interrupt = `NMI_i;
                    else if (irq) active_interrupt = `IRQ_i;
                    else active_interrupt = `NONE;
                end
            end
        
        end
     
            
    end
        
    always @ (negedge rst) begin
        if (~rst) rstNow = 1'b1;
    end
    //registers state variables
    always @ (posedge phi1) begin
        if (rstNow) begin
            curr_state <= `FSMinit; 
            SYNC <= 1'd0;
            //set up reset sequence

            active_interrupt = `RST_i;
           // interruptArray = 4'd0;
            //interruptArray[`RST_i] = 1'b1;              
            //get controls for the first state (T1) of the reset cycle.
            getControlsBrk(phi1,phi2,active_interrupt,`Ttwo,open_T ,curr_P1controlSigs);
            getControlsBrk(~phi1,~phi2,active_interrupt,`Ttwo,open_T ,curr_P2controlSigs);
            
            //interruptArray <= 4'b1; // set rst bit
            activeOpcode <= 8'b00;
            controlSigs <= curr_P1controlSigs;
            curr_T <= `Ttwo;
            rstNow <= 1'b0;
            rstAll <= 1'b1;
            
        end
        
        else begin
        rstAll <= 1'b0;
            curr_state <= next_state;
            curr_T <= next_T;
            
            controlSigs <= next_P1controlSigs;
            curr_P2controlSigs <= next_P2controlSigs;
            activeOpcode <= nextOpcode;
            
            //controlSigs <= curr_P1controlSigs;
        end
    end
    
    always @ (posedge phi2) begin
        begin	
            //curr_state <= curr_state;       // no state transitions on phi2 
            //curr_T <= curr_T;
            controlSigs <= curr_P2controlSigs;
        end
    end  
endmodule

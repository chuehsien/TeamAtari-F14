/*
This is the top FSM modules which implements the opcode -> controlSignal state machine.
*/
 

`include "Control/FSMstateDef.v"
`include "Control/TDef.v"


module plaFSM(phi1,phi2,nmi,irq,rst,RDY,ACR, opcode, statusReg,loadOpcode, 
                controlSigs, SYNC, T1now, nmiHandled, irqHandled, rstHandled, rstAll,activeOpcode);
     
    `include "Control/controlMods.v"      
    input phi1,phi2,nmi,irq,rst,RDY,ACR; //RDY is external input
    input [7:0] opcode, statusReg;
    input loadOpcode;
    output [79:0] controlSigs;
    output SYNC, T1now; //T1now is to signal predecode register to load in value.
    output nmiHandled, irqHandled, rstHandled, rstAll;
    output [7:0] activeOpcode;
    
    wire phi1,phi2,nmi,irq,rst,RDY,ACR;
    wire [7:0] opcode;
    wire [7:0] statusReg;
    wire loadOpcode;
    reg [79:0] controlSigs;
    reg SYNC;
    wire T1now;
    reg nmiHandled, irqHandled, rstHandled,rstAll;
    reg [7:0] activeOpcode;
    reg [2:0] active_interrupt;
    
    //internal variables. open_T and open_control are just holders, since u cant leave task outputs empty
    //reg [7:0] opcode;
    reg [79:0] curr_P1controlSigs, curr_P2controlSigs;
    reg [79:0] next_P1controlSigs, next_P2controlSigs;
    
    reg [2:0]       curr_state,next_state;
    reg [6:0]       curr_T,next_T,open_T;
    reg [7:0]       nextOpcode;

    reg [2:0]       dummy_state; //just to hold intermediate values;
    reg [79:0]      dummy_control, open_control;
    reg [6:0]       dummy_T;
    reg [7:0]      leftOverSig; //to perform last SBAC/SBX/SBY controls in T2 of next instruction.
    //reg [3:0]      interruptArray; //from bit 0-3 : rst,nmi,irq,brk.
    
    reg rstNow;
    
    //wire interruptPending;
    
    assign T1now = (curr_T == `Tone || curr_T == `T1NoBranch || 
                curr_T == `T1BranchNoCross || curr_T == `T1BranchCross); //might be wrong!
                      
    //assign interruptPending = nmi|irq;
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

    // loadOpcode triggers the fsm to redecide the next state (after fetch), based on this new opcode,.
    always @ (curr_T or loadOpcode or ACR) //ACR affects branch paths
         
    begin
        
        dummy_control = `emptyControl;
        dummy_T = `emptyT;
        dummy_state = 3'bxxx;
    
        next_P1controlSigs = `emptyControl;
        next_P2controlSigs = `emptyControl;
        rstHandled = 1'b0;
        nmiHandled = 1'b0;
        irqHandled = 1'b0;
        
        
        if (RDY) begin
        
            if (active_interrupt == `NONE && curr_state == `FSMfetch) begin
                if (rst) active_interrupt = `RST_i;
                else if (nmi) active_interrupt = `NMI_i;
                else if (irq) active_interrupt = `IRQ_i;
                else active_interrupt = `NONE;
            end
            
            
            case(curr_state)
                `FSMinit: begin 
             
                //this is somewhat the prefetch stage, only for first cycle
                //when does the right opcode appear? not here. opcode is loaded when ticked into FSMfetch.
                
    
                    //get controls for the next T state.

                    getControlsBrk(1'b1,1'b0,active_interrupt,curr_T,dummy_T, open_control);
                    
                    getControlsBrk(1'b1,1'b0,active_interrupt,dummy_T, open_T,next_P1controlSigs);  
                    getControlsBrk(1'b0,1'b1,active_interrupt,dummy_T, open_T,next_P2controlSigs);
                    
                    
                    
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
                    
                    //for fetch state, always wait for new opcode to come in at the phi2 tick.
                    //so, only decide the next controlSigs on phi2.
                    
                    //if (phi2) begin
                    //figure out which kind of instruction it is.
                    instructionType(opcode, dummy_state); //timing issues. new opcode havent clock in.
                    nextOpcode = opcode;
                    //entering new instruction, will always begin from T2.
                    
                        if (dummy_state == `execNorm) begin
                            //get controls for the next T.
                            
                            getControlsNorm(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C],opcode, `Ttwo, open_T, next_P1controlSigs);
                            getControlsNorm(1'b0,1'b1,statusReg[`status_D],ACR,statusReg[`status_C],opcode, `Ttwo, open_T , next_P2controlSigs);

                        end
                        else if (dummy_state == `execRMW) begin
                            //get controls for the next T.
                            //getControlsRMW(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                            
                            getControlsRMW(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C],opcode, `Ttwo, open_T, next_P1controlSigs); // get next T
                            getControlsRMW(1'b0,1'b1,statusReg[`status_D],ACR,statusReg[`status_C],opcode, `Ttwo, open_T , next_P2controlSigs); //get controls for new T
                           
                        end
                        else if (dummy_state == `execBranch) begin
                            //get controls for the next T.
                            //getControlsBranch(phi1,phi2,statusReg, opcode, curr_T, dummy_T , open_control);
                            
                            getControlsBranch(1'b1,1'b0,ACR,statusReg,opcode, `Ttwo, open_T, next_P1controlSigs); // get next T
                            getControlsBranch(1'b0,1'b1,ACR,statusReg,opcode, `Ttwo, open_T , next_P2controlSigs); //get controls for new T
                            
                            
                        end
                        else if (dummy_state == `execBrk) begin
                            //get controls for the next T.
                            //getControlsBrk(phi1,phi2,interruptArray,curr_T, dummy_T, open_control);
                            
                            getControlsBrk(1'b1,1'b0,active_interrupt,`Ttwo, open_T,next_P1controlSigs); //get next T 
                            getControlsBrk(1'b0,1'b1,active_interrupt,`Ttwo, open_T,next_P2controlSigs); //get controls for new T
                            
                        end
                        
                        next_state = dummy_state; //will go to either norm, rmw, or branch.
                        next_T = `Ttwo;
                   // end
                    

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
       
                    getControlsNorm(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C],activeOpcode, curr_T, dummy_T, open_control);
                    
                    getControlsNorm(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C],activeOpcode, dummy_T, open_T, next_P1controlSigs);
                    getControlsNorm(1'b0,1'b1,statusReg[`status_D],ACR,statusReg[`status_C],activeOpcode, dummy_T, open_T , next_P2controlSigs);

                    nextOpcode = activeOpcode;
             
                    next_T = dummy_T;                   
                    
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state <= `FSMfetch;
                        
                    else next_state <= curr_state;
                               
                end
                
                `execBrk: begin //used to handle all interrupts
                    if (phi1) SYNC = 1'd0;

                    //get controls for the next T.
                    getControlsBrk(1'b1,1'b0,active_interrupt,curr_T, dummy_T, open_control);
                    
                    getControlsBrk(1'b1,1'b0,active_interrupt,dummy_T, open_T,next_P1controlSigs); //get next T 
                    getControlsBrk(1'b0,1'b1,active_interrupt,dummy_T, open_T,next_P2controlSigs); //get controls for new T
                    nextOpcode = activeOpcode;
                    
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
                    getControlsRMW(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C], activeOpcode, curr_T, dummy_T , open_control);
                    
                    getControlsRMW(1'b1,1'b0,statusReg[`status_D],ACR,statusReg[`status_C],activeOpcode, dummy_T, open_T, next_P1controlSigs); // get next T
                    getControlsRMW(1'b0,1'b1,statusReg[`status_D],ACR,statusReg[`status_C],activeOpcode, dummy_T, open_T , next_P2controlSigs); //get controls for new T
                    nextOpcode = activeOpcode;
                    
                    next_T = dummy_T;
                    
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state = `FSMfetch;
                    else next_state = curr_state;              
                    
                end 

                `execBranch: begin
                    if (phi1) SYNC = 1'd0;
                    //get controls for the next T.
                    getControlsBranch(1'b1,1'b0,ACR,statusReg, activeOpcode, curr_T, dummy_T , open_control);
                    
                    getControlsBranch(1'b1,1'b0,ACR,statusReg,activeOpcode, dummy_T, open_T, next_P1controlSigs); // get next T
                    getControlsBranch(1'b0,1'b1,ACR,statusReg,activeOpcode, dummy_T, open_T , next_P2controlSigs); //get controls for new T
                    nextOpcode = activeOpcode;
                    
                    next_T = dummy_T;
                                           
                    if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
                        dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
                        next_state = `FSMfetch;
                    else next_state = curr_state;
                    
                end

            endcase
            
            if (next_T == `Ttwo) begin
                // handle leftover instructions (SBAC, SBX, SBY)
                findLeftOverSig(activeOpcode,leftOverSig);
                if (leftOverSig !== `NO_SIG) next_P1controlSigs[leftOverSig] = 1'b1;
            end
        
            //if (next_T == `Tzero || next_T == `TzeroNoCrossPg || next_T == `TzeroCrossPg) begin
                //check for interrupts
                //hierarchy of interrupts
             /*   if (!(irqHandled || nmiHandled || rstHandled) && //if not recently finished handling
                     active_interrupt == `NONE &&
                     curr_state == `FSMfetch) begin
                    if (rst) active_interrupt = `RST_i;
                    else if (nmi) active_interrupt = `NMI_i;
                    else if (irq) active_interrupt = `IRQ_i;
                    else active_interrupt = `NONE;
                end*/
            //end
        
        end
     
            
    end
        
    always @ (rst) begin
        if (rst) rstNow = 1'b1;
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
            getControlsBrk(1'b1,1'b0,active_interrupt,`Ttwo,open_T ,curr_P1controlSigs);
            getControlsBrk(1'b0,1'b1,active_interrupt,`Ttwo,open_T ,curr_P2controlSigs);
            
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

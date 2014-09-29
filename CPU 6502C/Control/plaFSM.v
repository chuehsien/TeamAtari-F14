/*
This is the top FSM modules which implements the opcode -> controlSignal state machine.
*/
 
`include "FSMstateDef.v"
`include "controlDef.v"
`include "TDef.v"
	

module plaFSM(phi1,phi2,resetFSM,RDY, opcode, statusReg, 
				controlSigs, SYNC);
					
	input phi1,phi2, resetFSM, RDY; //RDY is external input
	input [7:0] statusReg, opcode;
	output [61:0] controlSigs;
	output SYNC;
	
	wire phi1,phi2,resetFSM,RDY;
	wire [7:0] opcode;
	reg [61:0] controlSigs, next_controlSigs;
	reg 		SYNC;
	
	//internal variables
	reg [2:0] 		curr_state,next_state;
	reg [6:0]		curr_T,next_T;
	reg [7:0]		currOpcode;

	reg [2:0] 		dummy_state; //just to hold intermediate values;
	reg [61:0]		dummy_control;
	reg [6:0]		dummy_T;
	
	always @ ( phi1 or phi2 or resetFSM or RDY)

		begin
		
			case(curr_state)
				`FSMinit: begin //this is somewhat the prefetch stage, only for first cycle
				//when does the right opcode appear? not here. opcode is loaded when ticked into FSMfetch.
				//this is NOP T2 phi1 controls.
					dummy_control = 61'd0;
					dummy_control[`S_S] = 1'b1;
					dummy_control[`DB_ADD] = 1'b1;
					dummy_control[`SB_ADD] = 1'b1;
					dummy_control[`SUMS] = 1'b1;
					dummy_control[`DAA] = 1'b1;
					dummy_control[`ADD_SB7] = 1'b1;
					dummy_control[`ADD_SB0to6] = 1'b1;
					dummy_control[`DSA] = 1'b1;
					dummy_control[`SB_DB] = 1'b1;
					dummy_control[`ADH_PCH] = 1'b1;
					dummy_control[`PCH_ADH] = 1'b1;
					dummy_control[`I_PC] = 1'b1;
					dummy_control[`PCL_ADL] = 1'b1;
					dummy_control[`ADL_PCL] = 1'b1;
					
					next_T <= `Tone;
					next_state <= `FSMfetch;
					next_controlSigs <= dummy_control;
					if (phi1) SYNC <= 1'd0;
				end
				`FSMfetch: begin
					if (phi1) SYNC <= 1'd1;
					//figure out which kind of instruction it is.
					instructionType(opcode, dummy_state); //timing issues. new opcode havent clock in.
					
					if (RDY) begin
						next_state <= dummy_state; //will go to either norm, rmw, or branch.
						//get controlSigs for newstate;
						getControls(phi1,phi2,dummy_state, opcode, currT, dummy_T, dummy_control);
						next_T <= dummy_T;
						next_controlSigs <= dummy_control;
					end
					
					else begin
						next_state <= `FSMstall;
						next_T <= currT;
						next_controlSigs <= `controlStall;
					end
					
				end
				
				`FSMstall: begin
					if (phi1) SYNC <= 1'd1;
					instructionType(opcode, dummy_state); //timing issues. new opcode havent clock in.
					
					if (RDY) begin
						next_state <= dummy_state; //will go to either norm, rmw, or branch.
						//get controlSigs for newstate;
						getControls(phi1,phi2,dummy_state, opcode, currT, dummy_T, dummy_control);
						next_T <= dummy_T;
						next_controlSigs <= dummy_control;
					end
					
					else begin
						next_state <= curr_state;
						next_T <= currT;
						next_controlSigs <= `controlStall;
					end
					
				end
				
				`execNorm: begin
					if (phi1) SYNC <= 1'd0;
					getControlsNorm(phi1,phi2,opcode, currT, dummy_T, dummy_control);
					if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
						dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
						next_state <= `FSMfetch;
						
					else next_state <= curr_state;
					
					next_T <= dummy_T;
					next_controlSigs <= dummy_control;				
				end
				`execRMW: begin
					if (phi1) SYNC <= 1'd0;
					getControlsRMW(phi1,phi2,statusReg, opcode, currT, dummy_T, dummy_control);
					if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
						dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
						next_state <= `FSMfetch;
					else next_state <= curr_state;				
					next_T <= dummy_T;
					next_controlSigs <= dummy_control;
				end	
				`execBranch: begin
					if (phi1) SYNC <= 1'd0;
					getControlsBranch(phi1,phi2,statusReg, opcode, currT, dummy_T, dummy_control);
					if (dummy_T == `Tone || dummy_T == `T1NoBranch ||
						dummy_T == `T1BranchNoCross || dummy_T == `T1BranchCross)
						next_state <= `FSMfetch;
					else next_state <= curr_state;
					
					next_T <= dummy_T;
					next_controlSigs <= dummy_control;
				end
			
			endcase	
		
		end
	
	//registers state variables
	always @ (posedge phi1) begin
		if (resetFSM) begin
			curr_state <= `FSMinit;	
			curr_T <= `Tzero;
			controlSigs <= `controlStall;
		end
		
		else begin
			curr_state <= next_state;
			curr_T <= next_T;
			controlSigs <= next_controlSigs;
		end
	end
	
	always @ (posedge phi2) begin
		if (resetFSM) begin
			curr_state <= `FSMinit;
			curr_T <= `Tzero;
			controlSigs <= `controlStall;
		end
		else begin
			curr_state <= curr_state;		// no state transitions on phi2	
			curr_T <= curr_T;
			controlSigs <= next_controlSigs;
		end
	end // always 
endmodule
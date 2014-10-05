`include "Control/opcodeDef.v"
`include "Control/controlDef.v"
`include "Control/TDef.v"
task DEY;

	input [6:0] T;
	input phi1,phi2;
	output [79:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [79:0] controlSigs;
	
	begin
		controlSigs = 80'd0;
		case (T)

			
			`Tone: begin
		newT = `Ttwo;
				if (phi1) begin
				//YSB,SS,DBADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,ADHPCH,PCHADH,PCLADL,ADLPCL
					controlSigs[`Y_SB] = 1'b1;
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHADH,PCLADL
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
				end
			
			end
			
			`Ttwo: begin
		newT = `Tone;
				if (phi1) begin
					//SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,ADHPCH,PCHADH,#IPC,~IPC,PCLADL,ADLPCL
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,#DSA,~DSA,PCHADH,#IPC,~IPC,PCLADL
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
				end
			
			end
		endcase

	end
	
endtask

	

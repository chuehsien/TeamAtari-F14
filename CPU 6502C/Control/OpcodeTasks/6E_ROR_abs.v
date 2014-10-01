`include "Control/opcodeDef.v"
`include "Control/controlDef.v"
`include "Control/TDef.v"
task ROR_abs;

	input [6:0] T;
	input phi1,phi2;
	output [62:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [62:0] controlSigs;
	
	begin
		controlSigs = 63'd0;
		case (T)
 			`Tzero:begin
            newT = `Tone;
            controlSigs[`nRW] = 1'b1;
				if (phi1) begin
				//SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHPCH,#IPC,~IPC,PCLPCL
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,#DSA,~DSA,PCHADH,#IPC,~IPC,PCLADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			end 
			`Tone:begin
		newT = `Ttwo;
				if (phi1) begin
				//SS,DBADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
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
					controlSigs[`DL_DB] = 1'b1;
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
		newT = `Tthree;
				if (phi1) begin
					//SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,ADHPCH,PCHADH,PCLADL,ADLPCL
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
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,#DSA,~DSA,PCHADH,PCLADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			
			end
			`Tthree: begin
		newT = `Tfour;
				if(phi1) begin
				//SS,DBADD,0ADD,SUMS,#DAA,~DAA,#DSA,~DSA,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,DL/ADH
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
					
				end	
			end
			
			`Tfour:begin
		newT = `Tfive;
			if (phi1) begin
			//SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADH
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
			end
			else if (phi2) begin
			//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			end
			
			`Tfive:begin
            newT = `Tzero;
            controlSigs[`nRW] = 1'b1;
			if (phi1) begin
			//SS,DBADD,SBADD,SRS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SRS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			else if (phi2) begin
			//SRS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,#IPC,~IPC
					controlSigs[`SRS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
			end
			end
			
		endcase

	end
	
endtask

	

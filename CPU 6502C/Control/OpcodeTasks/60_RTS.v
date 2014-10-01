`include "Control/TDef.v"
task RTS;

	input [6:0] T;
	input phi1,phi2;
	output [62:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [62:0] controlSigs;
	
	begin
		controlSigs = 63'd0;
		case (T)
			 `Tzero: begin
		newT = `Tone;
				if (phi1) begin
				//SS,DBADD,0ADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,ADHPCH,ADLPCL,DL/ADH,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
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

			`Tone: begin
		newT = `Ttwo;
				if (phi1) begin
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
				//SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHADH,PCLADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
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
				//SADL,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH17,DL/DB
					controlSigs[`S_ADL] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			
			end
			`Tthree:begin
		newT = `Tfour;
			if (phi1) begin
				//SADL,SS,ADLADD,0ADD,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH17,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`S_ADL] = 1'b1;
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
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
	
			`Tfour:begin
		newT = `Tfive;
			if (phi1) begin
				//SS,ADLADD,0ADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDSB7,ADDSB06,ADDADL,#DSA,~DSA,#IPC,~IPC,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			
			`Tfive:begin
		newT = `Tzero;
			if (phi1) begin
				//SBS,DBADD,0ADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`SB_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,DL/ADH,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
		endcase

	end
	
endtask

	

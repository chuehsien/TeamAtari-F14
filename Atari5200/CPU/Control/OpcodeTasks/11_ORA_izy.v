task ORA_izy;

	input [6:0] T;
	input phi1,phi2;
	input carry;
	
	output [66:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [66:0] controlSigs;
	
	begin
		controlSigs = 67'd0;
		case (T)
			 `TzeroCrossPg: begin
			newT = `Tone;
				if (phi1) begin
				//SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBADH,PCHPCH,#IPC,~IPC,PCLPCL
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_ADH] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
                    controlSigs[`nADL_ABL] = 1'b1;
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
		
			`TzeroNoCrossPg: begin
			newT = `Tone;
				if (phi1) begin
				//SS,DBADD,0ADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADH,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
                    controlSigs[`I_ADDC] = 1'b1;
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
                    controlSigs[`I_ADDC] = 1'b1;
				end
			end 
		
			`Tone: begin
			newT = `Ttwo;
				if (phi1) begin
				//SS,DBADD,SBADD,ORS,#DAA,~DAA,#DSA,~DSA,ACSB,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`ORS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`AC_SB] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
				else if (phi2) begin
				//ORS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHADH,PCLADL
					controlSigs[`ORS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
                    controlSigs[`FLAG_ALU] = 1'b1;
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
					//SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,DL/ADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH0] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`DL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			
			end
			`Tthree:begin
			newT = `Tfour;
			if (phi1) begin
				//SS,ADLADD,0ADD,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH0] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
                    controlSigs[`I_ADDC] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
                    controlSigs[`I_ADDC] = 1'b1;
                    controlSigs[`nADH_ABH] = 1'b1;
			end
            end
			`Tfour:begin
			if (carry) newT = `Tfive;
			else newT = `TzeroNoCrossPg;
			if (phi1) begin
				//YSB,SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`Y_SB] = 1'b1;
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
					controlSigs[`DL_DB] = 1'b1;
                    controlSigs[`nADH_ABH] = 1'b1;
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
			end
			`Tfive:begin
			newT = `TzeroCrossPg;
			if (phi1) begin
				//SS,DBADD,0ADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADH,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
                    controlSigs[`I_ADDC] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBADH,#IPC,~IPC
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_ADH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
                    controlSigs[`I_ADDC] = 1'b1;
                    controlSigs[`nADL_ABL] = 1'b1;
			end
            end
		endcase

	end
	
endtask

	

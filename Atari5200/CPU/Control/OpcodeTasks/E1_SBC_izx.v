task SBC_izx;

	input [6:0] T;
	input phi1,phi2,statusC,decMode;
	output [66:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [66:0] controlSigs;
	
	begin
		controlSigs = 67'd0;
		case (T)
			 `Tzero: begin
		newT = `Tone;
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
			
			`Tone: begin
		newT = `Ttwo;
				if (phi1) begin
				//SS,nDBADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,ACSB,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_L_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					if (!decMode) controlSigs[`nDSA] = 1'b1;
                    if (statusC) controlSigs[`I_ADDC] = 1'b1;
					controlSigs[`AC_SB] = 1'b1;
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
					if (!decMode) controlSigs[`nDSA] = 1'b1;
                    if (statusC) controlSigs[`I_ADDC] = 1'b1;
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
				//SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,DL/ADL
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH0] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`DL_ADL] = 1'b1;
				end
			
			end
			`Tthree:begin
		newT = `Tfour;
			if (phi1) begin
				//XSB,SS,ADLADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADL
					controlSigs[`X_SB] = 1'b1;
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH0] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADL] = 1'b1;
			end
			else if (phi2) begin

					controlSigs[`nADH_ABH] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			end
			`Tfour:begin
		newT = `Tfive;
			if (phi1) begin

					controlSigs[`I_ADDC] = 1'b1;
					controlSigs[`nADH_ABH] = 1'b1;
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

					controlSigs[`I_ADDC] = 1'b1;
					controlSigs[`nADH_ABH] = 1'b1;
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
			if (phi1) begin

					controlSigs[`nADH_ABH] = 1'b1;
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
					controlSigs[`DL_DB] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,DL/ADH
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
			end
			end
			
		endcase

	end
	
endtask

	

task STY_abs;

	input [6:0] T;
	input phi1,phi2;
	output [61:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	wire [6:0] T;
	wire phi1,phi2;
	reg [61:0] controlSigs;
	
	always @ (*) begin
		controlSigs = 62'd0;
		case (T)
			 `Tzero: begin
		newT = `Tone;
				if (phi1) begin
				//YSB,SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,SBDB,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADH
					controlSigs[`Y_SB] = 1'b1;
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`I_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,#DSA,~DSA,PCHADH,#IPC,~IPC,PCLADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`I_PC] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			end 
		
			`Tone: begin
		newT = `Ttwo;
				if (phi1) begin
				//SS,DBADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,SBDB,PCHADH,PCLADL
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`DSA] = 1'b1;
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
					controlSigs[`DAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
				end
				else if (phi2) begin
				//SUMS,#DAA,~DAA,#DSA,~DSA,PCHADH,PCLADL,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
				end
			
			end
			`Tthree:begin
		newT = `Tzero;
			if (phi1) begin
				//SS,DBADD,0ADD,SUMS,#DAA,~DAA,#DSA,~DSA,ADHPCH,PCHADH,PCLADL,ADLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`PCH_ADH] = 1'b1;
					controlSigs[`PCL_ADL] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
			end
			else if (phi2) begin
				//SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,SBDB,DL/ADH
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`DAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`DSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
			end
	
		endcase

	end
	
endtask

	

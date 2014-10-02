`include "Control/opcodeDef.v"
`include "Control/controlDef.v"
`include "Control/TDef.v"
task ROL_zp;

	input [6:0] T;
	input phi1,phi2;
	output [62:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [62:0] controlSigs;
	
	begin
		controlSigs = 63'd0;
    
    case (T)
    
      (`Tzero) : begin
        controlSigs[`nRW] = 1'b1;
		newT = `Tone;
        if (phi1) begin
          //SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,ADDADL,#DSA,~DSA,SBDB,PCHPCH,#IPC,~IPC,PCLPCL
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
        end
        else if(phi2) begin
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
      
      (`Tone) : begin 
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
        else if(phi2) begin

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
      
      (`Ttwo) : begin
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
        
        else if(phi2) begin
          //SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,DL/ADL
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH0] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`DL_ADL] = 1'b1;
        end
        
      end
      
      (`Tthree) : begin
		newT = `Tfour;
      
        if (phi1) begin
          //SS,ADLADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH0,0ADH17,PCHPCH,#IPC,~IPC,PCLPCL,DL/ADL
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
        
        else if(phi2) begin
          //SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,SBDB,#IPC,~IPC,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
        end
        
      end
      
      (`Tfour) : begin
		newT = `Tzero;
        controlSigs[`nRW] = 1'b1;
        if (phi1) begin
          //SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,SBDB,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
        end
        
        else if(phi2) begin
          //SUMS,#DAA,~DAA,ADDSB7,ADDSB06,ADDADL,#DSA,~DSA,SBDB,#IPC,~IPC
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`SB_DB] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
        end
        
      end
    
    
    endcase

	end
	
endtask

	

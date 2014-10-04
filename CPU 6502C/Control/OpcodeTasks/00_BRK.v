`include "Control/opcodeDef.v"
`include "Control/controlDef.v"
`include "Control/TDef.v"
task BRK;

	input [6:0] T;
	input phi1,phi2;
    input [2:0] active_interrupt;
	output [62:0] controlSigs;
	output [6:0] newT;
	reg [6:0] newT;

	
	reg [62:0] controlSigs;
	
	begin
		controlSigs = 63'd0;
    
    case (T)
    
      (`Tzero) : begin
		newT = `Tone;
        controlSigs[`SET_I] = 1'b1;
        if (phi1) begin
            if (active_interrupt == `RST_i) begin
                controlSigs[`O_ADL1] = 1'b1; //create address fffd
            end
            
            //do nothing for irq/brk, fetching address ffff.
            
            if (active_interrupt == `NMI_i) begin
                controlSigs[`O_ADL2] = 1'b1;//create address fffb
            end
            
            
          //SS,DBADD,0ADD,SUMS,#DAA,~DAA,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
        end
        else if(phi2) begin
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
      
      (`Tone) : begin 
		newT = `Ttwo;
		
        if (phi1) begin
          //SS,DBADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,ADHPCH,ADLPCL,DL/ADH,DL/DB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`ADH_PCH] = 1'b1;
					controlSigs[`ADL_PCL] = 1'b1;
					controlSigs[`DL_ADH] = 1'b1;
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
          //SADL,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH17,PCHDB
					controlSigs[`S_ADL] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`PCH_DB] = 1'b1;
        end
        
      end
      
      (`Tthree) : begin
		newT = `Tfour;
		if (active_interrupt !== `RST_i) controlSigs[`nRW] = 1'b1;
        if (phi1) begin
          //SADL,SS,ADLADD,SBADD,SUMS,#DAA,~DAA,#DSA,~DSA,0ADH17,PCHPCH,PCHDB,#IPC,~IPC,PCLPCL
					controlSigs[`S_ADL] = 1'b1;
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`O_ADH1to7] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`PCH_DB] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
        end
        else if(phi2) begin
          //SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,PCLDB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_DB] = 1'b1;
        end
      end
      
      (`Tfour) : begin
		newT = `Tfive;
		if (active_interrupt !== `RST_i) controlSigs[`nRW] = 1'b1;
        if (phi1) begin
          //SS,ADLADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLDB,PCLPCL
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_DB] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
        end
          
        else if(phi2) begin
          //SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,#IPC,~IPC,PDB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
                    controlSigs[`P_DB] = 1'b1;
        end
      end
      
      (`Tfive) : begin
		newT = `Tsix;
        if (active_interrupt !== `RST_i) controlSigs[`nRW] = 1'b1;
        if (phi1) begin
          //SS,ADLADD,SBADD,SUMS,#DAA,~DAA,ADDADL,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL,PDB
					controlSigs[`S_S] = 1'b1;
					controlSigs[`ADL_ADD] = 1'b1;
					controlSigs[`SB_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_ADL] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
                    controlSigs[`P_DB] = 1'b1;
        end
        else if(phi2) begin
            //place interrupt vector address onto ADH,ADL here.
            if (active_interrupt == `RST_i) begin
                controlSigs[`O_ADL0] = 1'b1;
                controlSigs[`O_ADL1] = 1'b1; //create address fffc
            end
            if (active_interrupt == `IRQ_i || active_interrupt == `NONE) begin
                controlSigs[`O_ADL0] = 1'b1;//create address fffe
            end
            if (active_interrupt == `NMI_i) begin
                controlSigs[`O_ADL0] = 1'b1;
                controlSigs[`O_ADL2] = 1'b1;//create address fffa
            end
            
            //SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,#IPC,~IPC
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
        end
      end
      
      (`Tsix) : begin
		newT = `Tzero;
		
        if (phi1) begin
            if (active_interrupt ==`RST_i) begin
                controlSigs[`O_ADL0] = 1'b1;
                controlSigs[`O_ADL1] = 1'b1; //create address fffc
            end
            if (active_interrupt == `IRQ_i || active_interrupt == `BRK_i) begin
                controlSigs[`O_ADL0] = 1'b1;//create address fffe
            end
            if (active_interrupt == `NMI_i) begin
                controlSigs[`O_ADL0] = 1'b1;
                controlSigs[`O_ADL2] = 1'b1;//create address fffa
            end
          //SBS,DBADD,0ADD,SUMS,#DAA,~DAA,ADDSB7,ADDSB06,#DSA,~DSA,PCHPCH,#IPC,~IPC,PCLPCL
					controlSigs[`SB_S] = 1'b1;
					controlSigs[`DB_ADD] = 1'b1;
					controlSigs[`O_ADD] = 1'b1;
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`ADD_SB7] = 1'b1;
					controlSigs[`ADD_SB0to6] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`PCH_PCH] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`PCL_PCL] = 1'b1;
        end
        else if(phi2) begin
            if (active_interrupt == `RST_i) begin
                controlSigs[`O_ADL1] = 1'b1; //create address fffd
            end
            
            //do nothing for irq/brk, fetching address ffff.
            
            if (active_interrupt == `NMI_i) begin
                controlSigs[`O_ADL2] = 1'b1;//create address fffb
            end
            
            
            //SUMS,#DAA,~DAA,#DSA,~DSA,#IPC,~IPC,DL/DB
					controlSigs[`SUMS] = 1'b1;
					controlSigs[`nDAA] = 1'b1;
					controlSigs[`nDSA] = 1'b1;
					controlSigs[`nI_PC] = 1'b1;
					controlSigs[`DL_DB] = 1'b1;
        end
      end
    
    
    endcase

	end
	
endtask

	

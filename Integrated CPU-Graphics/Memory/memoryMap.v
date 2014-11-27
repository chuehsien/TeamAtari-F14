// Memory mapping module
// Last updated: 10/22/2014 2040H




module memoryMap(


                write_RAM,data_in_b,
                             
                addr_RAM,addr_BIOS,addr_CART,
                Fclk, clk, rst, CPU_writeEn, ANTIC_writeEn, GTIA_writeEn, CPU_addr, 

                 VCOUNT_in, PENH_in, PENV_in,
                 POT0_BUS, POT1_BUS, POT2_BUS, POT3_BUS, POT4_BUS, POT5_BUS, POT6_BUS, POT7_BUS, ALLPOT_BUS, KBCODE_BUS, RANDOM_BUS, SERIN_BUS, IRQST_BUS, SKSTAT_BUS,
                 TRIG0_BUS,TRIG1_BUS,TRIG2_BUS,TRIG3_BUS,
                 data_CART_out,

                 M0PF, M1PF, M2PF, M3PF, P0PF, P1PF, P2PF, P3PF, M0PL, M1PL, 
                 M2PL, M3PL, P0PL, P1PL, P2PL, P3PL, TRIG0, TRIG1, TRIG2, TRIG3, 
                 PAL, CONSOL,

                 CPU_data, NMIRES_NMIST_bus, DLISTL_bus, DLISTH_bus, 
                 
                 COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,
                 HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
                 SIZEP0, SIZEP1, SIZEP2, SIZEP3, SIZEM, COLPM0, COLPM1, COLPM2, CONSPK,
                 
                 DMACTL, CHACTL, HSCROL, VSCROL, PMBASE, CHBASE, WSYNC, NMIEN, COLPM3, COLPF0, COLPF1, COLPF2, 
                 COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,

                 AUDF1, AUDC1, AUDF2, AUDC2, AUDF3, AUDC3, AUDF4, AUDC4, AUDCTL, 
                 SKREST, SEROUT, SERIN, IRQEN, SKCTL,CONSPK_CONSOL,

                 POTGO_strobe, STIMER_strobe
                 );
  output write_RAM;
  output [7:0] data_in_b;
  
  output addr_RAM,addr_BIOS,addr_CART;
  // Control signals
  input Fclk;
  input clk;
  input rst;
  input CPU_writeEn;
  input [2:0] ANTIC_writeEn;
  input [4:0] GTIA_writeEn;
  input [15:0] CPU_addr;
  

  input [7:0] POT0_BUS, POT1_BUS, POT2_BUS, POT3_BUS, POT4_BUS, POT5_BUS, POT6_BUS, POT7_BUS, ALLPOT_BUS, KBCODE_BUS, RANDOM_BUS, SERIN_BUS, IRQST_BUS, SKSTAT_BUS;
  input [7:0] TRIG0_BUS,TRIG1_BUS,TRIG2_BUS,TRIG3_BUS;
  input [7:0] data_CART_out;


  // ANTIC inputs
  input [7:0] VCOUNT_in;
  input [7:0] PENH_in;
  input [7:0] PENV_in;
  
  // GTIA inputs
  input [7:0] M0PF, M1PF, M2PF, M3PF, P0PF, P1PF, P2PF, P3PF, M0PL, M1PL, 
              M2PL, M3PL, P0PL, P1PL, P2PL, P3PL, TRIG0, TRIG1, TRIG2, TRIG3, 
              PAL, CONSOL;
  
  // ANTIC inouts
  inout [7:0] CPU_data;
  inout [7:0] NMIRES_NMIST_bus;
  inout [7:0] DLISTL_bus;
  inout [7:0] DLISTH_bus;
  
  // GTIA outputs
  output [7:0] COLPM3, COLPF0, COLPF1, COLPF2, COLPF3, COLBK, PRIOR, VDELAY, GRACTL, HITCLR,
               HPOSP0, HPOSP1, HPOSP2, HPOSP3, HPOSM0, HPOSM1, HPOSM2, HPOSM3,
               SIZEP0, SIZEP1, SIZEP2, SIZEP3, SIZEM, COLPM0, COLPM1, COLPM2, CONSPK;
  
  // ANTIC outputs
  output [7:0] DMACTL;
  output [7:0] CHACTL;
  output [7:0] HSCROL;
  output [7:0] VSCROL;
  output [7:0] PMBASE;
  output [7:0] CHBASE;
  output [7:0] WSYNC;
  output [7:0] NMIEN;
  
  //outputs to POKEY
  output [7:0] AUDF1, AUDC1, AUDF2, AUDC2, AUDF3, AUDC3, AUDF4, AUDC4, AUDCTL, SKREST, SEROUT, SERIN, IRQEN , SKCTL,CONSPK_CONSOL;

  //STROBE SIGNALS
  output POTGO_strobe, STIMER_strobe;

  // ANTIC hardware registers
  reg [7:0] DMACTL;       // | $D400 | Write      |                   |
  reg [7:0] CHACTL;       // | $D401 | Write      |                   |
  reg [7:0] DLISTL;       // | $D402 | Write/Read | ANTIC_writeEn 1/2 |
  reg [7:0] DLISTH;       // | $D403 | Write/Read | ANTIC_writeEn 2   |
  reg [7:0] HSCROL;       // | $D404 | Write      |                   |
  reg [7:0] VSCROL;       // | $D405 | Write      |                   |
  reg [7:0] PMBASE;       // | $D407 | Write      |                   |
  reg [7:0] CHBASE;       // | $D409 | Write      |                   |
  reg [7:0] WSYNC;        // | $D40A | Write      |                   |
  reg [7:0] VCOUNT;       // | $D40B | Read       | ANTIC_writeEn 3   |
  reg [7:0] PENH;         // | $D40C | Read       | ANTIC_writeEn 4   |
  reg [7:0] PENV;         // | $D40D | Read       | ANTIC_writeEn 5   |
  reg [7:0] NMIEN;        // | $D40E | Write      |                   |
  reg [7:0] NMIRES_NMIST; // | $D40F | Write/Read | ANTIC_writeEn 6   | 
  
  // GTIA hardware registers (WRITE)
  reg [7:0] HPOSP0;  // | $C000 |
  reg [7:0] HPOSP1;  // | $C001 |
  reg [7:0] HPOSP2;  // | $C002 |
  reg [7:0] HPOSP3;  // | $C003 |
  reg [7:0] HPOSM0;  // | $C004 |
  reg [7:0] HPOSM1;  // | $C005 |
  reg [7:0] HPOSM2;  // | $C006 |
  reg [7:0] HPOSM3;  // | $C007 |
  reg [7:0] SIZEP0;  // | $C008 |
  reg [7:0] SIZEP1;  // | $C009 |
  reg [7:0] SIZEP2;  // | $C00A |
  reg [7:0] SIZEP3;  // | $C00B |
  reg [7:0] SIZEM;   // | $C00C |
  reg [7:0] GRAFP0;  // | $C00D |
  reg [7:0] GRAFP1;  // | $C00E |
  reg [7:0] GRAFP2;  // | $C00F |
  reg [7:0] GRAFP3;  // | $C010 |
  reg [7:0] GRAFPM;  // | $C011 |
  reg [7:0] COLPM0;  // | $C012 |
  reg [7:0] COLPM1;  // | $C013 |
  reg [7:0] COLPM2;  // | $C014 |
  reg [7:0] COLPM3;  // | $C015 |
  reg [7:0] COLPF0;  // | $C016 |
  reg [7:0] COLPF1;  // | $C017 |
  reg [7:0] COLPF2;  // | $C018 |
  reg [7:0] COLPF3;  // | $C019 |
  reg [7:0] COLBK;   // | $C01A |
  reg [7:0] PRIOR;   // | $C01B |
  reg [7:0] VDELAY;  // | $C01C |
  reg [7:0] GRACTL;  // | $C01D |
  reg [7:0] HITCLR;  // | $C01E |
  reg [7:0] CONSPK;  // | $C01F |
  
  //POKEY hardware registers

  reg [7:0] AUDF1; 	//Audio Channel 1 Frequency 	Write 	$D200 	53760 			
  //reg [7:0] POT0 ;	//Potentiometer (Paddle) 0 	    Read 	$D200 	53760 	PADDL0 	$0270 	624
  reg [7:0] AUDC1; 	//Audio Channel 1 Control 	    Write 	$D201 	53761 			
  //reg [7:0] POT1 ;	//Potentiometer (Paddle) 1 	    Read 	$D201 	53761 	PADDL1 	$0271 	625
  reg [7:0] AUDF2; 	//Audio Channel 2 Frequency 	Write 	$D202 	53762 			
  //reg [7:0] POT2 ;	//Potentiometer (Paddle) 2 	    Read 	$D202 	53762 	PADDL2 	$0272 	626
  reg [7:0] AUDC2; 	//Audio Channel 2 Control 	    Write 	$D203 	53763 			
  //reg [7:0] POT3 ;	//Potentiometer (Paddle) 3 	    Read 	$D203 	53763 	PADDL3 	$0273 	627
  reg [7:0] AUDF3; 	//Audio Channel 3 Frequency 	Write 	$D204 	53764 			
  //reg [7:0] POT4 ;	//Potentiometer (Paddle) 4 	    Read 	$D204 	53764 	PADDL4 	$0274 	628
  reg [7:0] AUDC3; 	//Audio Channel 3 Control 	    Write 	$D205 	53765 			
 // reg [7:0] POT5 ;	//Potentiometer (Paddle) 5  	Read 	$D205 	53765 	PADDL5 	$0275 	629
  reg [7:0] AUDF4; 	//Audio Channel 4 Frequency 	Write 	$D206 	53766 			
  //reg [7:0] POT6 ;	//Potentiometer (Paddle) 6 	    Read 	$D206 	53766 	PADDL6 	$0276 	630
  reg [7:0] AUDC4; 	//Audio Channel 4 Control 	    Write 	$D207 	53767 			
  //reg [7:0] POT7 ;	//Potentiometer (Paddle) 7 	    Read 	$D207 	53767 	PADDL7 	$0277 	631
  reg [7:0] AUDCTL; 	//Audio Control 	            Write 	$D208 	53768 			
  //reg [7:0] ALLPOT;	//Read 8 Line POT Port State 	Read 	$D208 	53768 			
  reg [7:0] STIMER; 	//Start Timers 	                Write 	$D209 	53769 			
  //reg [7:0] KBCODE; 	//Keyboard Code 	            Read 	$D209 	53769 	CH 	$02FC 	764
  reg [7:0] SKREST; 	//Reset Serial Status (SKSTAT) 	Write 	$D20A 	53770 			
  //reg [7:0] RANDOM; 	//Random Number Generator 	    Read 	$D20A 	53770 			
  reg [7:0] POTGO ;	//Start POT Scan Sequence 	    Write 	$D20B 	53771 			
  reg [7:0] SEROUT;	//Serial Port Data Output 	    Write 	$D20D 	53773 			
  //reg [7:0] SERIN ;	//Serial Port Data Input 	    Read 	$D20D 	53773 			
  reg [7:0] IRQEN ;	//Interrupt Request Enable 	    Write 	$D20E 	53774 	POKMSK 	$10 	16
  //reg [7:0] IRQST ;	//IRQ Status 	                Read 	$D20E 	53774 			
  reg [7:0] SKCTL ;	//Serial Port Control 	        Write 	$D20F 	53775 	SSKCTL 	$0232 	562
  //reg [7:0] SKSTAT; 	//Serial Port Status 	        Read 	$D20F 	53775 			
    
  
  
  
  wire [7:0] data_out, data_in;
  wire [7:0] data_RAM_out, data_BIOS_out,data_CART_out,data_reg_out;
  wire addr_RAM,addr_BIOS,addr_CART;
  wire write_RAM, write_reg;
  
  wire write_RAM_latch, write_reg_latch;
  //sigLatchWclk latchRAMwrites(~clk,latchClk,write_RAM_latch,write_RAM);
  //sigLatchWclk latchregwrites(~clk,latchClk,write_reg_latch,write_reg);
  assign write_RAM = write_RAM_latch;
  assign write_reg = write_reg_latch;
    




  wire [15:0] CPU_addr_b;
  wire [7:0] data_RAM_out_b,data_BIOS_out_b, data_in_b;
  buf memB0[7:0] (data_RAM_out, data_RAM_out_b);
  buf memB1[15:0] (CPU_addr_b, CPU_addr);
  buf memB2[7:0] (data_in_b, data_in);
  buf memB3[7:0] (data_BIOS_out, data_BIOS_out_b);
  
  // Block RAM
  // Read clock is inverted Fphi0, write clock is phi2
  
  memRAM blockRAM (.clka(clk),
                             .wea(write_RAM),
                             .addra(CPU_addr_b[13:0]),
                             .dina(data_in_b),
                             .douta(data_RAM_out_b));

  //memory256x256 mem(.clock(Fclk), .we(write_RAM), .address(CPU_addr), .dataIn(data_in), .dataOut(data_RAM_out));
  memBios bios(.clka(clk),.addra(CPU_addr_b[10:0]),.douta(data_BIOS_out_b));

    
  triStateData tsd(.DB(CPU_data), .DB_out(data_out), .writeEn(CPU_writeEn), .DB_in(data_in));
  
  addrMuxOut amo(.addr_RAM(addr_RAM), .data_RAM_out(data_RAM_out), 
                 .addr_BIOS(addr_BIOS), .data_BIOS_out(data_BIOS_out), 
                 .addr_CART(addr_CART), .data_CART_out(data_CART_out), 
                .data_reg_out(data_reg_out), .data_out(data_out));
  
  addrCheck ac(.addr(CPU_addr), .addr_RAM(addr_RAM),.addr_BIOS(addr_BIOS),.addr_CART(addr_CART));
  
  writeMux wm(.addr_RAM(addr_RAM), .writeEn(CPU_writeEn), .write_RAM(write_RAM_latch), .write_reg(write_reg_latch));


  always @(posedge Fclk or posedge rst) begin
  
    if (rst) begin    
      DMACTL <= 8'd0;
      CHACTL <= 8'd0;
      DLISTL <= 8'd0;
      DLISTH <= 8'd0;
      HSCROL <= 8'd0;
      VSCROL <= 8'd0;
      PMBASE <= 8'd0;
      CHBASE <= 8'd0;
      WSYNC <= 8'd0;
      NMIEN <= 8'd0;
      NMIRES_NMIST <= 8'd0;
      HPOSP0 <= 8'd0;
      HPOSP1 <= 8'd0;
      HPOSP2 <= 8'd0;
      HPOSP3 <= 8'd0;
      HPOSM0 <= 8'd0;
      HPOSM1 <= 8'd0;
      HPOSM2 <= 8'd0;
      HPOSM3 <= 8'd0;
      SIZEP0 <= 8'd0;
      SIZEP1 <= 8'd0;
      SIZEP2 <= 8'd0;
      SIZEP3 <= 8'd0;
      SIZEM <= 8'd0;
      GRAFP0 <= 8'd0;
      GRAFP1 <= 8'd0;
      GRAFP2 <= 8'd0;
      GRAFP3 <= 8'd0;
      GRAFPM <= 8'd0;
      COLPM0 <= 8'd0;
      COLPM1 <= 8'd0;
      COLPM2 <= 8'd0;
      COLPM3 <= 8'd0;
      COLPF0 <= 8'd0;
      COLPF1 <= 8'd0;
      COLPF2 <= 8'd0;
      COLPF3 <= 8'd0;
      COLBK <= 8'd0;
      PRIOR <= 8'd0;
      VDELAY <= 8'd0;
      GRACTL <= 8'd0;
      HITCLR <= 8'd0;
      CONSPK <= 8'd0;

      AUDF1   <= 8'd0;
      AUDC1   <= 8'd0;
      AUDF2   <= 8'd0;
      AUDC2   <= 8'd0;
      AUDF3   <= 8'd0;
      AUDC3   <= 8'd0;
      AUDF4   <= 8'd0;
      AUDC4   <= 8'd0;
      AUDCTL  <= 8'd0;
      STIMER  <= 8'd0;
      SKREST  <= 8'd0;
      POTGO   <= 8'd0;
      SEROUT  <= 8'd0;
      IRQEN   <= 8'd0;
      SKCTL   <= 8'd0;
    end
    
    else begin
  
      if (write_reg) begin
        case (CPU_addr)
      // CPU writes to POKEY registers
          16'hE800: AUDF1 <= data_in;
                 
          //16'hD200: POT0 	Potentiometer (Paddle) 0 	Read 	$D200 	53760 	PADDL0 	$0270 	624
          16'hE801: AUDC1 	 <= data_in;
          //16'hD201: POT1 	Potentiometer (Paddle) 1 	Read 	$D201 	53761 	PADDL1 	$0271 	625
          16'hE802: AUDF2 	 <= data_in;
          //16'hD202: POT2 	Potentiometer (Paddle) 2 	Read 	$D202 	53762 	PADDL2 	$0272 	626
          16'hE803: AUDC2 	 <= data_in;
          //16'hD203: POT3 	Potentiometer (Paddle) 3 	Read 	$D203 	53763 	PADDL3 	$0273 	627
          16'hE804: AUDF3 	 <= data_in;
          //16'hD204: POT4 	Potentiometer (Paddle) 4 	Read 	$D204 	53764 	PADDL4 	$0274 	628
          16'hE805: AUDC3 	 <= data_in;
          //16'hD205: POT5 	Potentiometer (Paddle) 5 	Read 	$D205 	53765 	PADDL5 	$0275 	629
          16'hE806: AUDF4 	 <= data_in;
          //16'hD206: POT6 	Potentiometer (Paddle) 6 	Read 	$D206 	53766 	PADDL6 	$0276 	630
          16'hE807: AUDC4 	 <= data_in;
          //16'hD207: POT7 	Potentiometer (Paddle) 7 	Read 	$D207 	53767 	PADDL7 	$0277 	631
          16'hE808: AUDCTL 	 <= data_in;
          //16'hD208: ALLPOT 	Read 8 Line POT Port State 	Read 	$D208 	53768 			
          16'hE809: STIMER 	 <= data_in;
          //16'hD209: KBCODE 	Keyboard Code 	Read 	$D209 	53769 	CH 	$02FC 	764
          16'hE80A: SKREST 	 <= data_in;
          //16'hD20A: RANDOM 	Random Number Generator 	Read 	$D20A 	53770 			
          16'hE80B: POTGO 	 <= data_in;
          16'hE80D: SEROUT 	 <= data_in;
          //16'hD20D: SERIN 	Serial Port Data Input 	Read 	$D20D 	53773 			
          16'hE80E: IRQEN 	 <= data_in;
          //16'hD20E: IRQST 	IRQ Status 	Read 	$D20E 	53774 			
          16'hE80F: SKCTL 	 <= data_in;
          //16'hD20F: SKSTAT 	Serial Port Status 	Read 	$D20F 	53775 			
                    
        
        
          // CPU writes to ANTIC registers
          16'hD400: DMACTL <= data_in;
          16'hD401: CHACTL <= data_in;
          16'hD402: DLISTL <= data_in;
          16'hD403: DLISTH <= data_in;
          16'hD404: HSCROL <= data_in;
          16'hD405: VSCROL <= data_in;
          16'hD407: PMBASE <= data_in;
          16'hD409: CHBASE <= data_in;
          16'hD40A: WSYNC <= data_in;
          16'hD40E: NMIEN <= data_in;
          16'hD40F: NMIRES_NMIST <= data_in;
          16'hC000: HPOSP0 <= data_in;
          16'hC001: HPOSP1 <= data_in;
          16'hC002: HPOSP2 <= data_in;
          16'hC003: HPOSP3 <= data_in;
          16'hC004: HPOSM0 <= data_in;
          16'hC005: HPOSM1 <= data_in;
          16'hC006: HPOSM2 <= data_in;
          16'hC007: HPOSM3 <= data_in;
          16'hC008: SIZEP0 <= data_in;
          16'hC009: SIZEP1 <= data_in;
          16'hC00A: SIZEP2 <= data_in;
          16'hC00B: SIZEP3 <= data_in;
          16'hC00C: SIZEM <= data_in;
          16'hC00D: GRAFP0 <= data_in;
          16'hC00E: GRAFP1 <= data_in;
          16'hC00F: GRAFP2 <= data_in;
          16'hC010: GRAFP3 <= data_in;
          16'hC011: GRAFPM <= data_in;
          16'hC012: COLPM0 <= data_in;
          16'hC013: COLPM1 <= data_in;
          16'hC014: COLPM2 <= data_in;
          16'hC015: COLPM3 <= data_in;
          16'hC016: COLPF0 <= data_in;
          16'hC017: COLPF1 <= data_in;
          16'hC018: COLPF2 <= data_in;
          16'hC019: COLPF3 <= data_in;
          16'hC01A: COLBK <= data_in;
          16'hC01B: PRIOR <= data_in;
          16'hC01C: VDELAY <= data_in;
          16'hC01D: GRACTL <= data_in;
          16'hC01E: HITCLR <= data_in;
          16'hC01F: CONSPK <= data_in;
        endcase
      end
      
      VCOUNT <= VCOUNT_in;
      
      if (ANTIC_writeEn != 3'd0) begin
        case (ANTIC_writeEn)
          3'd1: if (~((write_reg)&&(CPU_addr == 16'hD402)))
                  DLISTL <= DLISTL_bus;
          3'd2: if (~((write_reg)&&((CPU_addr == 16'hD402)||(CPU_addr == 16'hD403)))) begin
                  DLISTL <= DLISTL_bus;
                  DLISTH <= DLISTH_bus;
                end
          //3'd3: VCOUNT <= VCOUNT_in;
          3'd4: if (~((write_reg)&&((CPU_addr == 16'hD402)||(CPU_addr == 16'hD40F)))) begin
                  DLISTL <= DLISTL_bus;
                  NMIRES_NMIST <= NMIRES_NMIST_bus;
                end
          3'd5: if (~((write_reg)&&((CPU_addr == 16'hD402)||
                   (CPU_addr == 16'hD403)||(CPU_addr == 16'hD40F)))) begin
                  DLISTL <= DLISTL_bus;
                  DLISTH <= DLISTH_bus;
                  NMIRES_NMIST <= NMIRES_NMIST_bus;
                end
          3'd6: if (~((write_reg)&&(CPU_addr == 16'hD40F)))
                  NMIRES_NMIST <= NMIRES_NMIST_bus;
        endcase
      end
    end
  end
  
  // Bus outputs from read/write registers
  assign NMIRES_NMIST_bus = (ANTIC_writeEn == 3'd6) ? 8'hzz : NMIRES_NMIST;
  assign DLISTL_bus = ((ANTIC_writeEn == 3'd1)||(ANTIC_writeEn == 3'd2)) ? 8'hzz : DLISTL;
  assign DLISTH_bus = (ANTIC_writeEn == 3'd2) ? 8'hzz : DLISTH;
  
  // Output from registers to CPU
  //CPU doesnt need to write to these pokey read registers, so just connect straight to bus.
  assign data_reg_out = (CPU_addr == 16'hE800) ? POT0_BUS : 
                        (CPU_addr == 16'hE801) ? POT1_BUS :
                        (CPU_addr == 16'hE802) ? POT2_BUS :
                        (CPU_addr == 16'hE803) ? POT3_BUS :
                        (CPU_addr == 16'hE804) ? POT4_BUS :
                        (CPU_addr == 16'hE805) ? POT5_BUS :
                        (CPU_addr == 16'hE806) ? POT6_BUS :
                        (CPU_addr == 16'hE807) ? POT7_BUS :
                        (CPU_addr == 16'hE808) ? ALLPOT_BUS :
                        (CPU_addr == 16'hE809) ? KBCODE_BUS :
                        (CPU_addr == 16'hE80A) ? RANDOM_BUS :
                        (CPU_addr == 16'hE80D) ? SERIN_BUS :
                        (CPU_addr == 16'hE80E) ? IRQST_BUS :
                        (CPU_addr == 16'hE80F) ? SKSTAT_BUS :
                        
                        (CPU_addr == 16'hD400) ? DMACTL :
                        (CPU_addr == 16'hD401) ? CHACTL :
                        (CPU_addr == 16'hD402) ? DLISTL :
                        (CPU_addr == 16'hD403) ? DLISTH :
                        (CPU_addr == 16'hD404) ? HSCROL :
                        (CPU_addr == 16'hD405) ? VSCROL :
                        (CPU_addr == 16'hD407) ? PMBASE :
                        (CPU_addr == 16'hD409) ? CHBASE :
                        (CPU_addr == 16'hD40A) ? WSYNC :
                        (CPU_addr == 16'hD40B) ? VCOUNT :
                        (CPU_addr == 16'hD40C) ? PENH :
                        (CPU_addr == 16'hD40D) ? PENV :
                        (CPU_addr == 16'hD40E) ? NMIEN :
                        (CPU_addr == 16'hD40F) ? NMIRES_NMIST : 
                        (CPU_addr == 16'hC000) ? M0PF : 
                        (CPU_addr == 16'hC001) ? M1PF : 
                        (CPU_addr == 16'hC002) ? M2PF : 
                        (CPU_addr == 16'hC003) ? M3PF : 
                        (CPU_addr == 16'hC004) ? P0PF : 
                        (CPU_addr == 16'hC005) ? P1PF : 
                        (CPU_addr == 16'hC006) ? P2PF : 
                        (CPU_addr == 16'hC007) ? P3PF : 
                        (CPU_addr == 16'hC008) ? M0PL : 
                        (CPU_addr == 16'hC009) ? M1PL : 
                        (CPU_addr == 16'hC00A) ? M2PL : 
                        (CPU_addr == 16'hC00B) ? M3PL : 
                        (CPU_addr == 16'hC00C) ? P0PL : 
                        (CPU_addr == 16'hC00D) ? P1PL : 
                        (CPU_addr == 16'hC00E) ? P2PL : 
                        (CPU_addr == 16'hC00F) ? P3PL : 
                        (CPU_addr == 16'hC010) ? TRIG0 : 
                        (CPU_addr == 16'hC011) ? TRIG1 : 
                        (CPU_addr == 16'hC012) ? TRIG2 : 
                        (CPU_addr == 16'hC013) ? TRIG3 : 
                        (CPU_addr == 16'hC014) ? PAL : 
                        (CPU_addr == 16'hC015) ? COLPM3 : 
                        (CPU_addr == 16'hC016) ? COLPF0 : 
                        (CPU_addr == 16'hC017) ? COLPF1 : 
                        (CPU_addr == 16'hC018) ? COLPF2 : 
                        (CPU_addr == 16'hC019) ? COLPF3 : 
                        (CPU_addr == 16'hC01A) ? COLBK : 
                        (CPU_addr == 16'hC01B) ? PRIOR : 
                        (CPU_addr == 16'hC01C) ? VDELAY : 
                        (CPU_addr == 16'hC01D) ? GRACTL : 
                        (CPU_addr == 16'hC01E) ? HITCLR : 
                        (CPU_addr == 16'hC01F) ? CONSOL : 8'hzz;




          /* ============================= STROBE DETECTION ========================*/
          wire POTGO_strobe, STIMER_strobe;

          strobeDetect strobePotGo(.rst(rst),.clk(Fclk),.writeNow(((~rst) & (CPU_addr == 16'hE80B) & write_reg)),.strobeOut(POTGO_strobe));
          strobeDetect strobeStimer(.rst(rst),.clk(Fclk),.writeNow(((~rst) & (CPU_addr == 16'hE809) & write_reg)),.strobeOut(STIMER_strobe));
endmodule

// Tristate driver which splits databus into in/out wires
module triStateData(DB, DB_out, writeEn, DB_in);

  inout [7:0] DB;
  input [7:0] DB_out;
  input writeEn;
  output [7:0] DB_in;
  
  assign DB = (writeEn) ? 8'hzz : DB_out;
  assign DB_in = (writeEn) ? DB : 8'hzz;
    
endmodule

// Address checking module to map to RAM / registers
module addrCheck(addr, addr_RAM,addr_BIOS,addr_CART);
  
  input [15:0] addr;
  output addr_RAM;
  output addr_BIOS;
  output addr_CART;
  
  //high bits 00
   assign addr_RAM = ({1'b0,16'h4000} > {1'b0,addr}) ? 1'b1 : 1'b0; //ensure unsigned comparison 
 
 // high bits 1111_1xxx
 //bios runs from F800 to FFFF
  assign addr_BIOS = ({1'b0,addr} > {1'b0,16'hF7FF}) ? 1'b1 : 1'b0;
  
  //cart runs from 4000 to BFFF high bits 01 and 10
  assign addr_CART = (({1'b0,addr} > {1'b0,16'h3FFF}) & ( {1'b0,16'hC000} > {1'b0,addr})) ? 1'b1 : 1'b0;
  
  
/*
  assign addr_RAM = ~addr[15] & ~addr[14];
  
  assign addr_BIOS = addr[15] & addr[14] & addr[13] & addr[12] & addr[11];
  
  assign addr_CART = (~addr[15] & addr[14]) | (addr[15] & ~addr[14]);
  */
endmodule

// Mux to select sending output data from RAM / registers
module addrMuxOut(addr_RAM,addr_BIOS,addr_CART,
                  data_RAM_out,data_BIOS_out,data_CART_out,
                  data_reg_out, data_out);

  input addr_RAM,addr_BIOS,addr_CART;
  input [7:0] data_RAM_out,data_BIOS_out,data_CART_out;
  input [7:0] data_reg_out;
  output [7:0] data_out;
  
  assign data_out = addr_RAM ? data_RAM_out : 
                    addr_BIOS ? data_BIOS_out :
                    addr_CART ? data_CART_out :
                    data_reg_out;

endmodule

// Mux to select write enable for RAM / registers
module writeMux(addr_RAM, writeEn, write_RAM, write_reg);

  input addr_RAM;
  input writeEn;
  output write_RAM;
  output write_reg;
  
  assign write_RAM = (writeEn & addr_RAM) ? 1'b1 : 1'b0;
  assign write_reg = (writeEn & ~addr_RAM) ? 1'b1 : 1'b0;

endmodule

module strobeDetect(rst,clk,writeNow,strobeOut);
    parameter strobeWidth = 8; //number of counts before releasing strobe.
    input rst, clk, writeNow;
    output reg strobeOut;


    integer counter = 0;
    always @ (posedge clk) begin
        if (rst) begin
            counter <= 0;
            strobeOut <= 1'b0;
        end
        else begin

            if (writeNow) strobeOut <= 1'b1;
            else if (strobeOut) begin
                //start counting
                counter <= counter + 1;
            end
            
            if (counter == strobeWidth) begin
                counter <= 0;
                strobeOut <= 1'b0;
            end
        end
    end

endmodule

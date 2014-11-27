`include "POKEY/IO/IOControl.v"
`include "POKEY/IO/potFSM.v"

module POKEY_top_integration(rst_latch,kr1_L,timer,control_input_pot_scan,state,control_input,control_output_8_5,key_scan_L,rst,clk15, clk179,clk64, HDR2_10, HDR2_12, HDR2_14, HDR2_16, HDR2_18, HDR2_20, HDR2_22, HDR2_24, HDR2_26, HDR2_28, HDR2_30, HDR2_32,
                                     SKCTL, GRACTL, POTGO_strobe,IRQEN,CONSOL,
                                     timer4Pending,timer2Pending,timer1Pending,

                                     IRQ_ST, POT0_bus, POT1_bus, POT2_bus, POT3_bus, ALLPOT_bus, KBCODE_bus, SKSTAT_bus, TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus, 
									 HDR2_2, HDR2_4, HDR2_6, HDR2_8, HDR1_60, HDR1_62, HDR1_64,IRQ_L);
output rst_latch;
output kr1_L;        
    output [7:0] timer;
		  output [3:0] control_input_pot_scan;
		  output [1:0] state;

       output [3:0] control_input,control_output_8_5,key_scan_L;
        input rst, clk15,clk179,clk64;

        input  HDR2_2, HDR2_4, HDR2_6, HDR2_8, HDR2_18, HDR2_20, HDR2_22, HDR2_24, HDR2_26, HDR2_28, HDR2_30, HDR2_32;
        input [7:0] SKCTL, GRACTL, IRQEN, CONSOL; //control registers
        input timer4Pending, timer2Pending, timer1Pending;
        
        input POTGO_strobe;
        output [7:0] IRQ_ST,POT0_bus, POT1_bus, POT2_bus, POT3_bus, ALLPOT_bus, KBCODE_bus, SKSTAT_bus, TRIG0_bus, TRIG1_bus, TRIG2_bus, TRIG3_bus;
        output HDR2_10, HDR2_12, HDR2_14, HDR2_16,HDR1_60, HDR1_62, HDR1_64;
        output IRQ_L;

    
    


    wire [3:0]key_scan_L;
	wire kr1_L;

	wire [3:0] control_output_8_5;
	wire [3:0] control_input;
	wire [3:0] control_input_side_but;
	wire [3:0] control_input_pot_scan;
    wire pot_rel;

    
    wire [3:0] keycode_latch;
	wire [3:0] KBCODE_4_1;
    wire [1:0] KBCODE_7_6;
   



   // assign {HDR2_2, HDR2_4, HDR2_6, HDR2_8} = control_output_8_5;
   // assign control_input = {HDR2_10, HDR2_12, HDR2_14, HDR2_16};

    assign  {HDR2_10, HDR2_12, HDR2_14, HDR2_16} = control_output_8_5;
    assign  control_input = {HDR2_2, HDR2_4, HDR2_6, HDR2_8};

    assign control_input_side_but = {HDR2_24,HDR2_22,HDR2_20,HDR2_18}; // {top0,bot0,top1,bot1}
    assign control_input_pot_scan = {HDR2_32,HDR2_30,HDR2_28,HDR2_26};
    assign HDR1_60 = pot_rel;
    assign HDR1_62 = (CONSOL[1:0] == 2'b00);
    assign HDR1_64 = (CONSOL[1:0] == 2'b01);

    assign KBCODE_bus = {KBCODE_7_6, 1'd0, KBCODE_4_1, 1'd0};
	assign KBCODE_7_6 = control_input_side_but[3] ? 2'b00 : 2'b11;
    assign SKSTAT_bus = control_input_side_but[3] ? 8'h09 : 8'h01;
	 

    //wire top;
   // assign top0 = ~control_input_side_but[3];
    //assign top1 = ~control_input_side_but[1];
   
    
    wire TRIG0,TRIG1;
    trig_latch trigControl0(.buttonIn(~control_input_side_but[2]), .enLatch(GRACTL[2]), .trigOut(TRIG0));
    trig_latch trigControl1(.buttonIn(~control_input_side_but[0]), .enLatch(GRACTL[2]), .trigOut(TRIG1));
    assign TRIG0_bus = {7'd0,~TRIG0};
    assign TRIG1_bus = {7'd0,~TRIG1};
    assign TRIG2_bus = 8'd0;
    assign TRIG3_bus = 8'd0;

    /* =========================== IRQ generation ==============================*/
    reg [7:0] IRQST = 8'h08;
    wire brkPending;
    reg kbcodePending = 1'b0;
    wire serInPending,serOutPending,timer4Pending,timer2Pending,timer1Pending;

    wire topTrigIn;
    assign topTrigIn = (CONSOL[1:0] == 2'b00) ? (~control_input_side_but[3]) : (~control_input_side_but[1]);

    wire brkNow;
    //debounce direct trigger, so we dont get an IRQ spam.
    DeBounce #(4) trigdebounce(clk179,1'b1,topTrigIn,brkNow);



    wire IRQ_ST7,IRQ_ST6,IRQ_ST5,IRQ_ST4,IRQ_ST2,IRQ_ST1,IRQ_ST0;
    FDCPE #(.INIT(1'b1)) latch7(.Q(IRQ_ST7), .C(brkNow),    .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[7]));
    FDCPE #(.INIT(1'b1)) latch6(.Q(IRQ_ST6), .C(kbcodePending), .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[6]));
    FDCPE #(.INIT(1'b1)) latch5(.Q(IRQ_ST5), .C(serInPending),  .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[5]));
    FDCPE #(.INIT(1'b1)) latch4(.Q(IRQ_ST4), .C(serOutPending), .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[4]));
    FDCPE #(.INIT(1'b1)) latch2(.Q(IRQ_ST2), .C(timer4Pending),  .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[2]));
    FDCPE #(.INIT(1'b1)) latch1(.Q(IRQ_ST1), .C(timer2Pending), .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[1]));
    FDCPE #(.INIT(1'b1)) latch0(.Q(IRQ_ST0), .C(timer1Pending), .CE(1'b1), .CLR(1'b0), .D(1'b0), .PRE(~IRQEN[0]));
    
    assign IRQ_ST = {IRQ_ST7,IRQ_ST6,IRQ_ST5,IRQ_ST4,1'b1,IRQ_ST2,IRQ_ST1,IRQ_ST0};
    assign IRQ_L = ~(IRQ_ST!=8'hff);
    
    //FDCPE #(.INIT(1'b1)) latch8(.Q(brkPending), .C(top0|top1),.CE(1'b1),.CLR(~IRQEN[7]), .D(1'b1));
    //assign brkPending = top;
    reg [3:0] storedKBcode = 4'd0;
    always @ (posedge clk179) begin
        if ((KBCODE_bus[4:1] != 4'd0) & (KBCODE_bus[4:1] != storedKBcode)) begin
            storedKBcode <= KBCODE_bus[4:1];
            kbcodePending <= 1'b1;
        end
        else kbcodePending <= 1'b0;
    end 

    assign serInPending = 1'b0;
    assign serOutPending = 1'b0;


    /* ============================= main modules ==============================*/



    wire [1:0] state;
    wire rst_latch;
    mux   pin_4_1(control_input, key_scan_L[1:0], kr1_L);
    demux pin_8_5(key_scan_L[3:2], control_output_8_5);
	
    //main control logic
    IOControl iocontrol_mod(.rst_latch(rst_latch), .state(state),.rst(rst),.SKCTL(SKCTL),.clk15(clk15),.clk179(clk179),.clk64(clk64), 
                            .POTGO_strobe(POTGO_strobe), .kr1_L(kr1_L), .pot_scan_in(control_input_pot_scan),.key_scan_L(key_scan_L),
                            .keycode_latch(keycode_latch),.POT0(POT0_bus), .POT1(POT1_bus), .POT2(POT2_bus), .POT3(POT3_bus), .ALLPOT(ALLPOT_bus),
                            .pot_rel(pot_rel));

    // translate keycode latch to kbcode
    KB_modify kb_modify_mod (.keycode_latch(keycode_latch), .KBCODE_4_1(KBCODE_4_1));

endmodule

//button is active high
module trig_latch (buttonIn, enLatch, trigOut);

    input buttonIn;
    input enLatch;
    output trigOut;

    wire trigLatch;

   FDCE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDCE_inst (
      .Q(trigLatch),      // 1-bit Data output
      .C(buttonIn),      // 1-bit Clock input
      .CE(enLatch),    // 1-bit Clock enable input
      .CLR(~enLatch),  // 1-bit Asynchronous clear input
      .D(1'b1)       // 1-bit Data input
   );
  
    

    assign trigOut = enLatch ? trigLatch : buttonIn;

endmodule



module demux (sel, Y);
    input [1:0] sel;
    output [3:0] Y;
    
    reg [3:0] Y;
    
    always @ (sel) begin
        case (sel)
            2'b00: Y = 4'b1110;
            2'b01: Y = 4'b1101;
            2'b10: Y = 4'b1011;
            2'b11: Y = 4'b0111;
            default: Y = 4'b1111;
        endcase
    end

endmodule

module mux (Y, sel, A);
    
    input [3:0] Y;
    input [1:0] sel;
    output A;
    
    reg A;
    
    always @ (Y or sel) begin
        case (sel)
            2'b00: A = Y[0];
            2'b01: A = Y[1];
            2'b10: A = Y[2];
            2'b11: A = Y[3];
        endcase
    end


endmodule

module KB_modify (keycode_latch, KBCODE_4_1);

    input [3:0] keycode_latch;
    
    output [3:0] KBCODE_4_1;
    
    reg [3:0] KBCODE_4_1_reg;
    
    assign KBCODE_4_1 = KBCODE_4_1_reg;
    
    always @ (keycode_latch) begin
        case (keycode_latch)
            4'h0: KBCODE_4_1_reg = 4'b0000;
            4'h1: KBCODE_4_1_reg = 4'b0011;
            4'h2: KBCODE_4_1_reg = 4'b0010;
            4'h3: KBCODE_4_1_reg = 4'b0001;
            4'h4: KBCODE_4_1_reg = 4'b1100;
            4'h5: KBCODE_4_1_reg = 4'b1111;
            4'h6: KBCODE_4_1_reg = 4'b1110;
            4'h7: KBCODE_4_1_reg = 4'b1101;
            4'h8: KBCODE_4_1_reg = 4'b1000;
            4'h9: KBCODE_4_1_reg = 4'b1011;
            4'ha: KBCODE_4_1_reg = 4'b1010;
            4'hb: KBCODE_4_1_reg = 4'b1001;
            4'hc: KBCODE_4_1_reg = 4'b0100;
            4'hd: KBCODE_4_1_reg = 4'b0111;
            4'he: KBCODE_4_1_reg = 4'b0110;
            4'hf: KBCODE_4_1_reg = 4'b0101;
        endcase
    end
        /* 
            Key     keycode_latch       KBCODE bits
            <none>  0000                0000
            #       3                   0001
            0       2                   0010
            *       1                   0011
            3       7                   1101
            2       6                   1110
            1       5                   1111
            START   4                   1100
            6       B                   1001
            5       A                   1010
            4       9                   1011
            PAUSE   8                   1000
            9       F                   0101
            8       E                   0110
            7       D                   0111
            RESET   C                   0100
        */

endmodule

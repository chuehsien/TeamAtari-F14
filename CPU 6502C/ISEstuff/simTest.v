/*  Test module for top level CPU 6502C 
 *  Created:        1 Oct 2014, 1058 hrs (bhong)
 *  Last Modified:  3 Oct 2014, 1414 hrs

 Designed to test module "top_6502C", located in "top_6502C.v"

*/

`include "top_6502C.v"

`define TICKS 2400
module testCPU;

  /* CPU registers */
    reg RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;

  
    wire phi1_out, SYNC, phi2_out, RW;
    wire [15:0] extAB; //Address Bus Low and High
    wire [7:0] extDB; //Data Bus

    integer i;
    reg [15:0] j;
    reg[8*15:0] T_string;
    reg[8*10:0] FSM_string;
    /* Memory registers */

    //Setting up the clock to run
    always begin
        #10 phi0_in = ~phi0_in;
    end
  
    top_6502C cpu(.ALUout(),.holdHi(),.holdLo(),.activeInt(),.adCon(),.currT(),.currState(),.DB(),.SB(),.ADH(),.ADL(),
            .RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), 
                            .extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extAB(extAB), .phi2_out(phi2_out), .RW(RW));
  
    wire we_L, re_L;
    assign we_L = RW;
    assign re_L = ~RW; //RW=1 => read mode.
    memory256x256 mem(.clock(phi1_out), .enable(1'b1), .we_L(we_L), .re_L(re_L), .address(extAB), .data(extDB));

  
  
    /* High level description:  
        *  We place a sample program in memory, connect the CPU + memory, and clock them.
   
        Other components we want to observe: 
        - Address Bus (AB) high and low
        - Side Bus (SB) and Data Bus (DB)
        - X and Y registers
        - A and B registers
        - Accumulator registers
        - Status Register
        - Adder Hold Register
        - Decimal Adjust
        - ..and others? That's it for now.
    */
  
    /*  We only control the bytecode that's coming in, we place them in memory and let cpu fetch them
    
  
    */

    task printStuff;
        input integer i;
        begin

        TtoString(cpu.currT, T_string);
        FSMtoString(cpu.fsm.currState,FSM_string);
        //$display("phi1: %d, active_int: %b,currT: %b, dummy_T: %b, open_T: %b, open_controls:%b, P1:%b, P2: %b ",
        //        phi1_out,cpu.fsm.active_interrupt, cpu.fsm.curr_T,cpu.fsm.dummy_T,cpu.fsm.open_T,
         //       cpu.fsm.open_control,cpu.fsm.next_P1controlSigs,cpu.fsm.next_P2controlSigs);
         
  $display("@%03x %04x %02x %02x %x %02x %04x %02x %02x %02x %02x %02x %08b %02x  %02x %02x  %02x  %02x    %02x    %02x     %02x   %b   %b   %b  %b   %b   %b",
                i,
                cpu.extAB,
                cpu.extDB,
                cpu.SB,
                RW,
                cpu.opcode,
                {cpu.hi_3.currPC,cpu.lo_3.currPC},
                cpu.a.currAccum,
                cpu.x_reg.currVal,
                cpu.y_reg.currVal,
                cpu.sp.latchOut,
                cpu.predecodeOut,
                cpu.SR_contents,
                cpu.dor.dataOut,
                cpu.DB,
                cpu.ADH,
                cpu.ADL,
                cpu.A,
                cpu.B,
                cpu.ALU_out,
                cpu.ALUhold_out,
                cpu.controlSigs[`I_ADDC],
                cpu.aluACR,
                cpu.AVR,
                NMI_L,
                IRQ_L,
                RES_L);
        
        


      
        //$display("SRLOAD:%b, flagsalu:%b, flagsdb:%b, Nflag: %b, OP:%x",cpu.SR.load,cpu.SR.flagsALU,cpu.SR.flagsDB,cpu.SR.currVal[`status_N],cpu.activeOpcode);
        //$display("NMI_L %b, nmiControlOut %b, fsmNmi: %b, active_interrupt: %d",
        //        cpu.NMI_L, cpu.nmiPending,cpu.fsmNMI,cpu.fsm.active_interrupt);
        //$display("NMIpending:%b, intg: %b",cpu.iHandler.nmiPending,cpu.iHandler.intg);
        //$display("decMode: %b, controlnDSA: %b, dasb: %x,SBin: %x DSA:%b DAA:%b HC: %b",cpu.fsm.statusReg[`status_D],cpu.controlSigs[`nDSA],cpu.inFromDecAdder,cpu.decAdj.SBin,cpu.decAdj.iDSA,cpu.decAdj.iDAA,cpu.decAdj.iHC);
        //$display("SR_d:%x, nextP1DSA:%b, nextP2DSA:%b",cpu.fsm.statusReg[`status_D],cpu.fsm.next_P1controlSigs[`nDSA],cpu.fsm.next_P2controlSigs[`nDSA]);
     //   $display("activeopcode:%x, nextopcode :%x, interrupt:%b ",cpu.fsm.activeOpcode, cpu.fsm.nextOpcode, cpu.pdl.interrupt);
      /*
      //Check that the output is correct
      //ALTERNATIVE: check that certain outputs correspond to expected values
      
      $display("DB: \t%h, \tAB: \t%h, \tSYNC: \t%h, \tRW: \t%h, \tcontrolSigs: \t%b, \tA: \t%h, \tY: \t%h", extDB, extAB, SYNC, RW, top_6502C_module.controlSigs, top_6502C_module.A, top_6502C_module.SB);
      
      $display("======================");
     */
        end
    
    endtask
    


    task TtoString;
        input reg[6:0] T_state;
        output reg[8*15:0] T_string;

        begin
        if (T_state == `Tzero) T_string = "Tzero";
        else if (T_state == `Tone) T_string = "Tone";
        else if (T_state == `Ttwo) T_string = "Ttwo";
        else if (T_state == `Tthree) T_string = "Tthree";
        else if (T_state == `Tfour) T_string = "Tfour";
        else if (T_state == `Tfive) T_string = "Tfive";
        else if (T_state == `Tsix) T_string = "Tsix";
        else if (T_state == `T1NoBranch) T_string = "T1NoBranch";
        else if (T_state == `T1BranchNoCross) T_string = "T1BranchNoCross";
        else if (T_state == `T1BranchCross) T_string = "T1BranchCross";
        else if (T_state == `TzeroNoCrossPg) T_string = "TzeroNoCrossPg";
        else if (T_state == `TzeroCrossPg) T_string = "TzeroCrossPg";
        else T_string = "error";
        end
    endtask
  
    task FSMtoString;
        input reg[2:0] FSM_state;
        output reg[8*10:0] FSM_string;
  
        begin
        if (FSM_state == `FSMinit) FSM_string = "FSMinit";
        else if (FSM_state == `FSMfetch) FSM_string = "FSMfetch";
        else if (FSM_state == `FSMexecNorm) FSM_string = "execNorm";
        else if (FSM_state == `FSMexecBrk) FSM_string = "execBrk";
        else FSM_string = "error";
        end
    endtask
    

    always @ (j) begin
       // if (j == 16'd25) NMI_L = 1'b0;
        //if (j == 16'd29) NMI_L = 1'b1;
        //if (j == 16'd34) RES_L = 1'b0;
        //if (j == 16'd38) RES_L = 1'b1;
    end

    initial begin
  
    phi0_in = 1'b0;
  
    RDY = 1'b1;
    IRQ_L = 1'b1;
    NMI_L = 1'b1;
    RES_L = 1'b1;
    SO = 1'b1;
    #2
    RES_L = 1'b0;
    #2
    @(posedge phi1_out);
    #2 RES_L = 1'b1;
    $display("(halfcycle:%d, %s,%s,%x) T:%b, newT:%b inrst:%b fsmrst:%b",j,FSM_string, T_string,cpu.opcode,
               cpu.currT,cpu.newT,cpu.outRES_L,cpu.resPending);
    printStuff(0);
    @(negedge phi1_out);
    #2
     $display("(halfcycle:%d, %s,%s,%x) T:%b, newT:%b inrst:%b, fsmrst:%b",j,FSM_string, T_string,cpu.opcode,
               cpu.currT,cpu.newT,cpu.outRES_L,cpu.resPending);
    printStuff(0);
    j = 2; //used to count half cycles
    
    for (i=1; i<`TICKS; i=i+1)
    begin
           //$display("============================================");
           //$display("~ADH/ABH: %B",cpu.controlSigs[`nADH_ABH]);
          //$display("cyc  Eab Edb sb rw IR pc  a  x  y  s  pd     p    dor db adh adl alu_a alu_b alu aluHold Cin acr avr nmi irq res");
            @(posedge phi1_out);
            j = j + 1;

            #5;
            printStuff(i);
            
        //$display("(halfcycle:%d, %s,%s,%x) adhHold:%b ACRtologic: %b control %b",j,FSM_string, T_string,cpu.opcode,
        //       cpu.controlSigs[`nADH_ABH],cpu.ACR,cpu.controlSigs);
                    
                    
            @(negedge phi1_out);
            j = j + 1;
 
            #5;
            printStuff(i);   
            $display("(halfcycle:%d, %s,%s,%x) ",j,FSM_string, T_string,cpu.opcode);
          
            $display("");
            
    end
    
  
    $display("$0200: %X %X %X %X %X %X %X %X %X %X %X %X %X %X %X %X %X",
            mem.mem[16'h0200],mem.mem[16'h0201],mem.mem[16'h0202],mem.mem[16'h0203],
            mem.mem[16'h0204],mem.mem[16'h0205],mem.mem[16'h0206],mem.mem[16'h0207],
            mem.mem[16'h0208],mem.mem[16'h0209],mem.mem[16'h020a],mem.mem[16'h020b],
            mem.mem[16'h020c],mem.mem[16'h020d],mem.mem[16'h020e],mem.mem[16'h020f],mem.mem[16'h0210]);
    $finish;
    end
    


endmodule

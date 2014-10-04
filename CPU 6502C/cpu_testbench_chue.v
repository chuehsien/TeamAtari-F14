/*  Test module for top level CPU 6502C 
 *  Created:        1 Oct 2014, 1058 hrs (bhong)
 *  Last Modified:  3 Oct 2014, 1414 hrs

 Designed to test module "top_6502C", located in "top_6502C.v"

*/
`include "Control/TDef.v"
`include "Control/FSMstateDef.v"

`define TICKS 20
module testCPU;

  /* CPU registers */
    reg RDY, IRQ_L, NMI_L, RES_L, SO, phi0_in;

  
    wire phi1_out, SYNC, phi2_out, RW;
    wire [15:0] extAB; //Address Bus Low and High
    wire [7:0] extDB; //Data Bus

    integer i;
    reg[8*15:0] T_string;
    reg[8*10:0] FSM_string;
    /* Memory registers */

    //Setting up the clock to run
    always begin
        #100 phi0_in = ~phi0_in;
    end
  
    top_6502C cpu(.RDY(RDY), .IRQ_L(IRQ_L), .NMI_L(NMI_L), .RES_L(RES_L), .SO(SO), .phi0_in(phi0_in), 
                            .extDB(extDB), .phi1_out(phi1_out), .SYNC(SYNC), .extAB(extAB), .phi2_out(phi2_out), .RW(RW));
  
    wire we_L, re_L;
    assign we_L = ~RW;
    assign re_L = RW;
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

        TtoString(cpu.fsm.curr_T, T_string);
        FSMtoString(cpu.fsm.curr_state,FSM_string);
        //$display("phi1: %d, active_int: %b,currT: %b, dummy_T: %b, open_T: %b, open_controls:%b, P1:%b, P2: %b ",
        //        phi1_out,cpu.fsm.active_interrupt, cpu.fsm.curr_T,cpu.fsm.dummy_T,cpu.fsm.open_T,
         //       cpu.fsm.open_control,cpu.fsm.next_P1controlSigs,cpu.fsm.next_P2controlSigs);
        $display("@%03x %04x %02x %02x %x %02x %04x %02x %02x %02x %02x %08b %02x %02x  %02x  %02x    %02x    %02x     %02x    %b   %b",
                i,
                {cpu.ADH,cpu.ADL},     
                cpu.DB,
                cpu.SB,
                RW,
                cpu.effective_opcode,
                {cpu.hi_3.currPC,cpu.lo_3.currPC},
                cpu.a.currAccum,
                cpu.x_reg.currVal,
                cpu.y_reg.currVal,
                cpu.sp.latchOut,
                cpu.SR_contents,
                cpu.predecodeOut,
                cpu.ADL,
                cpu.ADH,
                cpu.A,
                cpu.B,
                cpu.ALU_out,
                cpu.addHold.adderReg,
                cpu.ACR,
                cpu.AVR);
                
      $display("E_Add: %04x, E_Data: %02x (%s,%s)",cpu.extAB,cpu.extDB,FSM_string, T_string);
        $display("");
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
        else if (FSM_state == `FSMstall) FSM_string = "FSMstall";
        else if (FSM_state == `execNorm) FSM_string = "execNorm";
        else if (FSM_state == `execRMW) FSM_string = "execRMW";
        else if (FSM_state == `execBranch) FSM_string = "execBranch";
        else if (FSM_state == `execBrk) FSM_string = "execBrk";
        else FSM_string = "error";
        end
    endtask



    initial begin
  
    phi0_in = 1'b0;
    RDY = 1'b1;
    RES_L = 1'b1;
    #20
    RES_L = 1'b0;
    #20
    @(posedge phi1_out);
    #50 RES_L = 1'b1;
    printStuff(0);
    
    for (i=1; i<`TICKS; i=i+1)
    begin
            $display("============================================");
            $display("cycle ab  db sb rw IR pc  a  x  y  s      p    pd adl adh alu_a alu_b alu aluHold acr avr");
            @(posedge phi1_out);
            #20
            printStuff(i);

            
            @(negedge phi1_out);
            #20
            printStuff(i);   
            
            
    end
    
  
  
    $finish;
    end

endmodule
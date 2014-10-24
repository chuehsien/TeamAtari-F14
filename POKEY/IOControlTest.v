module IOControlTest;

    reg o2;
    reg [7:0] pot_scan; //when pot_scan becomes 1, capture time! 
    reg kr1_L, kr2_L;
    reg [3:0] addr_bus;
    
    wire [5:0] key_scan_L; //decide which of the 64 keys to be decoded, decodes 0-63 keys
    wire [7:0] data_out; //to output the value of the key that was pressed.

    //instantiate IOControl module
    IOControl IOControl_mod(o2, pot_scan, kr1_L, kr2_L, addr_bus, key_scan_L, data_out);
    
    always begin
        #10 o2 = ~o2;
    end
    
    initial begin
        o2 = 1'b0;
        
        /* Testing potentiometer */
        //can you actually test it like this??
        pot_scan = 8'd0;
        addr_bus = 4'hb;
        $display("key_scan_L is: %b", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);        
        @ (posedge o2);
        addr_bus = 4'ha;
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("key_scan_L is: %b", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        @ (posedge o2);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("key_scan_L is: %b", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        @ (posedge o2);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("key_scan_L is: %b", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        @ (posedge o2);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("key_scan_L is: %b", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        @ (posedge o2); //5 clocks have passed
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("key_scan_L is: %d", key_scan_L);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        pot_scan = 8'b00001000;
        kr1_L = 1'b0; //key is depressed!
        @ (posedge o2);
        $display("key_scan_L is: %d", key_scan_L);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("POT0 is now: %b", IOControl_mod.POT0);
        $display("POT1 is now: %b", IOControl_mod.POT1);
        $display("POT2 is now: %b", IOControl_mod.POT2);
        $display("POT3 is now: %b", IOControl_mod.POT3);
        $display("POT4 is now: %b", IOControl_mod.POT4);
        $display("POT5 is now: %b", IOControl_mod.POT5);
        $display("POT6 is now: %b", IOControl_mod.POT6);
        $display("POT7 is now: %b", IOControl_mod.POT7);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        @ (posedge o2);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        $display("POT0 is now: %b", IOControl_mod.POT0);
        $display("POT1 is now: %b", IOControl_mod.POT1);
        $display("POT2 is now: %b", IOControl_mod.POT2);
        $display("POT3 is now: %b", IOControl_mod.POT3);
        $display("POT4 is now: %b", IOControl_mod.POT4);
        $display("POT5 is now: %b", IOControl_mod.POT5);
        $display("POT6 is now: %b", IOControl_mod.POT6);
        $display("POT7 is now: %b", IOControl_mod.POT7);
        $display("key_scan_L is: %b", key_scan_L);
        addr_bus = 4'hb;
        @ (posedge o2);
        addr_bus = 4'ha;
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        $display("POT0 is now: %b", IOControl_mod.POT0);
        $display("POT1 is now: %b", IOControl_mod.POT1);
        $display("POT2 is now: %b", IOControl_mod.POT2);
        $display("POT3 is now: %b", IOControl_mod.POT3);
        $display("POT4 is now: %b", IOControl_mod.POT4);
        $display("POT5 is now: %b", IOControl_mod.POT5);
        $display("POT6 is now: %b", IOControl_mod.POT6);
        $display("POT7 is now: %b", IOControl_mod.POT7);
        $display("key_scan_L is: %b", key_scan_L);
        @ (posedge o2);
        $display("compare_latch is: %b", IOControl_mod.compare_latch);
        $display("bin_ctr_pot is: %b", IOControl_mod.bin_ctr_pot);
        $display("POT0 is now: %b", IOControl_mod.POT0);
        $display("POT1 is now: %b", IOControl_mod.POT1);
        $display("POT2 is now: %b", IOControl_mod.POT2);
        $display("POT3 is now: %b", IOControl_mod.POT3);
        $display("POT4 is now: %b", IOControl_mod.POT4);
        $display("POT5 is now: %b", IOControl_mod.POT5);
        $display("POT6 is now: %b", IOControl_mod.POT6);
        $display("POT7 is now: %b", IOControl_mod.POT7);
        $display("key_scan_L is: %b", key_scan_L);
        $finish;
    
    
    
    
    
    end

endmodule
module Tcontrol(T,opcode,carry,SR,newT);
    input [6:0] T;
    input [7:0] opcode;
    input carry;
    input [7:0] SR;
    output reg [6:0] newT = `emptyT;

    always @ (*) begin
        if (opcode==`BRK) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`ORA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`ORA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`ASL_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`PHP) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`ORA_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ASL) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ORA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ASL_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BPL_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(~SR[`status_N]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`ORA_izy) begin
            case (T)
            `TzeroCrossPg : newT = `Tone;
            `TzeroNoCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ORA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ASL_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`CLC) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ORA_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ORA_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ASL_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`JSR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`AND_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BIT_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`AND_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`ROL_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`PLP) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`AND_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ROL) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`BIT_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`AND_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ROL_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BMI_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(SR[`status_N]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`AND_izy) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`AND_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ROL_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`SEC) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`AND_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`AND_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ROL_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`RTI) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`EOR_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`EOR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`LSR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`PHA) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`EOR_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LSR) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`JMP_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`EOR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LSR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BVC_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(~SR[`status_V]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`EOR_izy) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`EOR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LSR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`CLI) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`EOR_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`EOR_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`LSR_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`RTS) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`ADC_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`ADC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`ROR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`PLA) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ADC_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ROR) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`JMP_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`ADC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ROR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BVS_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(SR[`status_V]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`ADC_izy) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ADC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`ROR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`SEI) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`ADC_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ADC_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`ROR_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`STA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`STY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`STA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`STX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`DEY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`TXA) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`STY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`STA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`STX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`BCC_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(~SR[`status_C]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`STA_izy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`STY_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`STA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`STX_zpy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`TYA) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`STA_aby) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`TXS) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`STA_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`LDY_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`LDX_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`LDA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`LDX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`TAY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDA_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`TAX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LDA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LDX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`BCS_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(SR[`status_C]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`LDA_izy) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`LDY_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LDA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`LDX_zpy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`CLV) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDA_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`TSX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`LDY_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`LDA_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`LDX_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`CPY_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`CMP_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`CPY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`CMP_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`DEC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`INY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`CMP_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`DEX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`CPY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`CMP_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`DEC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BNE_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(~SR[`status_Z]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`CMP_izy) begin
            case (T)
            `TzeroCrossPg : newT = `Tone;
            `TzeroNoCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`CMP_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`DEC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`CLD) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`CMP_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`CMP_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`DEC_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

        if (opcode==`CPX_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`SBC_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`CPX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`SBC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            endcase
        end

        if (opcode==`INC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            endcase
        end

        if (opcode==`INX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`SBC_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`NOP) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`CPX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`SBC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`INC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`BEQ_rel) begin
            case (T)
            `Tzero : newT = `T1BranchCross;
            `Ttwo : begin
                    if(SR[`status_Z]) newT = `Tthree;
                    else newT = `T1NoBranch;
                    end
            `Tthree : begin
                    if(carry) newT = `Tzero;
                    else newT = `T1BranchNoCross;
                    end
            `T1BranchNoCross : newT = `Ttwo;
            `T1BranchCross : newT = `Ttwo;
            `T1NoBranch : newT = `Ttwo;
            endcase
        end

        if (opcode==`SBC_izy) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : begin
                    if(carry) newT = `Tfive;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfive : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`SBC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            endcase
        end

        if (opcode==`INC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            endcase
        end

        if (opcode==`SED) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            endcase
        end

        if (opcode==`SBC_aby) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`SBC_abx) begin
            case (T)
            `TzeroNoCrossPg : newT = `Tone;
            `TzeroCrossPg : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : begin
                    if(carry) newT = `Tfour;
                    else newT = `TzeroNoCrossPg;
                    end
            `Tfour : newT = `TzeroCrossPg;
            endcase
        end

        if (opcode==`INC_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            endcase
        end

    end
endmodule

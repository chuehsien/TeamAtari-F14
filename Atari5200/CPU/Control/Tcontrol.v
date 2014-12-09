module Tcontrol(T,opcode,carry,SR,newT);
    input [6:0] T;
    input [7:0] opcode;
    input carry;
    input [7:0] SR;
    output reg [6:0] newT = `emptyT;

    always @ (*) begin
        newT = `emptyT;
        if (opcode==`BRK) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ASL_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`PHP) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ASL) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ASL_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BPL_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ASL_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CLC) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ORA_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ASL_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`JSR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BIT_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROL_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`PLP) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROL) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BIT_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROL_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BMI_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROL_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SEC) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`AND_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROL_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`RTI) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LSR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`PHA) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LSR) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`JMP_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LSR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BVC_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LSR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CLI) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`EOR_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LSR_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`RTS) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROR_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`PLA) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROR) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`JMP_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROR_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BVS_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROR_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SEI) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ADC_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`ROR_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TXA) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BCC_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_izy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STY_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STX_zpy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TYA) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_aby) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TXS) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`STA_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDY_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDX_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TAY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TAX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BCS_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDY_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDX_zpy) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CLV) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`TSX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDY_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDA_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`LDX_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPY_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPY_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INY) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPY_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BNE_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CLD) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CMP_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`DEC_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPX_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_izx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPX_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INC_zp) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INX) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_imm) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`NOP) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`CPX_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INC_abs) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`BEQ_rel) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_izy) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INC_zpx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SED) begin
            case (T)
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tone;
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_aby) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`SBC_abx) begin
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
            default: newT = `emptyT;
			endcase
        end

        else if (opcode==`INC_abx) begin
            case (T)
            `Tzero : newT = `Tone;
            `Tone : newT = `Ttwo;
            `Ttwo : newT = `Tthree;
            `Tthree : newT = `Tfour;
            `Tfour : newT = `Tfive;
            `Tfive : newT = `Tsix;
            `Tsix : newT = `Tzero;
            default: newT = `emptyT;
			endcase
        end

    end
endmodule

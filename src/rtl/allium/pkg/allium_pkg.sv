// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

package allium_pkg;

	typedef enum logic [3:0] {
        ADD,
        SUB,
        XOR,
        AND,
        OR,
        SLT,
        SLTU,
        SLL,
        SRL,
        SRA
    } alu_op_e;

    typedef enum logic [2:0] {
        LB,
        LBU,
        LH,
        LHU,
        LW,
        SB,
        SH,
        SW
    } mem_op_e;

    typedef enum logic [2:0] {
        BEQ,
        BNE,
        BLT,
        BGE,
        BLTU,
        BGEU
    } branch_e;

    // Interconnect source mappings
    localparam logic [5:0] ZERO_SRC = 6'd0;
    localparam logic [5:0] RA_SRC   = 6'd1;
    localparam logic [5:0] SP_SRC   = 6'd2;
    localparam logic [5:0] GP_SRC   = 6'd3;
    localparam logic [5:0] TP_SRC   = 6'd4;
    localparam logic [5:0] T0_SRC   = 6'd5;
    localparam logic [5:0] T1_SRC   = 6'd6;
    localparam logic [5:0] T2_SRC   = 6'd7;
    localparam logic [5:0] S0_SRC   = 6'd8;
    localparam logic [5:0] S1_SRC   = 6'd9;
    localparam logic [5:0] A0_SRC   = 6'd10;
    localparam logic [5:0] A1_SRC   = 6'd11;
    localparam logic [5:0] A2_SRC   = 6'd12;
    localparam logic [5:0] A3_SRC   = 6'd13;
    localparam logic [5:0] A4_SRC   = 6'd14;
    localparam logic [5:0] A5_SRC   = 6'd15;
    localparam logic [5:0] A6_SRC   = 6'd16;
    localparam logic [5:0] A7_SRC   = 6'd17;
    localparam logic [5:0] S2_SRC   = 6'd18;
    localparam logic [5:0] S3_SRC   = 6'd19;
    localparam logic [5:0] S4_SRC   = 6'd20;
    localparam logic [5:0] S5_SRC   = 6'd21;
    localparam logic [5:0] S6_SRC   = 6'd22;
    localparam logic [5:0] S7_SRC   = 6'd23;
    localparam logic [5:0] S8_SRC   = 6'd24;
    localparam logic [5:0] S9_SRC   = 6'd25;
    localparam logic [5:0] S10_SRC  = 6'd26;
    localparam logic [5:0] S11_SRC  = 6'd27;
    localparam logic [5:0] T3_SRC   = 6'd28;
    localparam logic [5:0] T4_SRC   = 6'd29;
    localparam logic [5:0] T5_SRC   = 6'd30;
    localparam logic [5:0] T6_SRC   = 6'd31;

    localparam logic [5:0] IMM_SRC = 6'd32;
    localparam logic [5:0] ALU_SRC = 6'd33;
    localparam logic [5:0] LDST_SRC = 6'd34;

endpackage

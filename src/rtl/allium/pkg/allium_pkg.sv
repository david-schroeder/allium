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

    //////////////////////////////////
    //                              //
    // High-level CPU configuration //
    //                              //
    //////////////////////////////////

    // Adjustable parameters
    localparam int N_PRESELS    = 4;
    localparam int N_POSTSELS   = 2;
    localparam int N_IMMS       = 2;
    localparam int N_ALUS       = 2;
    localparam int N_MOVS       = 2;

    // Not adjustable yet
    localparam int N_LDSTS      = 1;
    localparam int N_BRANCHES   = 1;
    localparam int N_COMMITSETS = 1;

    // Computed parameters
    localparam int N_DATA_FUS   = N_IMMS + N_ALUS + N_LDSTS; // No branches
    localparam int N_FUSRCS     = N_DATA_FUS + N_PRESELS + 1; // +1 for ZERO
    localparam int N_REGSRCS    = N_DATA_FUS + N_MOVS + 1;

    localparam int LG_PRESELS   = $clog2(N_PRESELS);
    localparam int LG_POSTSELS  = $clog2(N_POSTSELS);
    localparam int LG_FUSRCS    = $clog2(N_FUSRCS);
    localparam int LG_REGSRCS   = $clog2(N_REGSRCS);

    /////////////////////////
    //                     //
    // Defines + utilities //
    //                     //
    /////////////////////////

    localparam logic [1:0] MOV_PRE0 = 2'd0;
    localparam logic [1:0] MOV_PRE1 = 2'd1;
    localparam logic [1:0] MOV_PRE2 = 2'd2;
    localparam logic [1:0] MOV_PRE3 = 2'd3;

    localparam logic [2:0] RS_ZERO = 3'd0;
    localparam logic [2:0] RS_LDST = 3'd1;
    localparam logic [2:0] RS_MOV0 = 3'd2;
    localparam logic [2:0] RS_MOV1 = 3'd3;
    localparam logic [2:0] RS_IMM0 = 3'd4;
    localparam logic [2:0] RS_IMM1 = 3'd5;
    localparam logic [2:0] RS_ALU0 = 3'd6;
    localparam logic [2:0] RS_ALU1 = 3'd7;

    localparam logic [3:0] FS_ZERO = 4'd0;
    localparam logic [3:0] FS_LDST = 4'd1;
    localparam logic [3:0] FS_IMM0 = 4'd4;
    localparam logic [3:0] FS_IMM1 = 4'd5;
    localparam logic [3:0] FS_ALU0 = 4'd6;
    localparam logic [3:0] FS_ALU1 = 4'd7;
    localparam logic [3:0] FS_PRE0 = 4'd8;
    localparam logic [3:0] FS_PRE1 = 4'd9;
    localparam logic [3:0] FS_PRE2 = 4'd10;
    localparam logic [3:0] FS_PRE3 = 4'd11;

    localparam logic [4:0] R_ZERO = 5'd0;
    localparam logic [4:0] R_RA   = 5'd1;
    localparam logic [4:0] R_SP   = 5'd2;
    localparam logic [4:0] R_GP   = 5'd3;
    localparam logic [4:0] R_TP   = 5'd4;
    localparam logic [4:0] R_T0   = 5'd5;
    localparam logic [4:0] R_T1   = 5'd6;
    localparam logic [4:0] R_T2   = 5'd7;
    localparam logic [4:0] R_S0   = 5'd8;
    localparam logic [4:0] R_S1   = 5'd9;
    localparam logic [4:0] R_A0   = 5'd10;
    localparam logic [4:0] R_A1   = 5'd11;
    localparam logic [4:0] R_A2   = 5'd12;
    localparam logic [4:0] R_A3   = 5'd13;
    localparam logic [4:0] R_A4   = 5'd14;
    localparam logic [4:0] R_A5   = 5'd15;
    localparam logic [4:0] R_A6   = 5'd16;
    localparam logic [4:0] R_A7   = 5'd17;
    localparam logic [4:0] R_S2   = 5'd18;
    localparam logic [4:0] R_S3   = 5'd19;
    localparam logic [4:0] R_S4   = 5'd20;
    localparam logic [4:0] R_S5   = 5'd21;
    localparam logic [4:0] R_S6   = 5'd22;
    localparam logic [4:0] R_S7   = 5'd23;
    localparam logic [4:0] R_S8   = 5'd24;
    localparam logic [4:0] R_S9   = 5'd25;
    localparam logic [4:0] R_S10  = 5'd26;
    localparam logic [4:0] R_S11  = 5'd27;
    localparam logic [4:0] R_T3   = 5'd28;
    localparam logic [4:0] R_T4   = 5'd29;
    localparam logic [4:0] R_T5   = 5'd30;
    localparam logic [4:0] R_T6   = 5'd31;

    typedef struct packed {
        logic [LG_REGSRCS-1:0] src;
        logic [           4:0] dest;
    } postselect_t;

    typedef struct packed {
        // FU CFG
        logic           [31:0][    N_IMMS-1:0]  imm_data;
        alu_op_e              [    N_ALUS-1:0]  alu0_op;
        mem_op_e              [   N_LDSTS-1:0] ldst_op;
        logic           [11:0][   N_LDSTS-1:0] ldst_offs;
        branch_e              [N_BRANCHES-1:0] branch;
        // Routing CFG
        logic [LG_PRESELS-1:0][    N_MOVS-1:0] move0_src;
        logic [ LG_FUSRCS-1:0][    N_ALUS-1:0] alu_srca;
        logic [ LG_FUSRCS-1:0][    N_ALUS-1:0] alu_srcb;
        logic [ LG_FUSRCS-1:0][   N_LDSTS-1:0] ldst_srca;
        logic [ LG_FUSRCS-1:0][   N_LDSTS-1:0] ldst_srcb;
        logic [ LG_FUSRCS-1:0][N_BRANCHES-1:0] brh_srca;
        logic [ LG_FUSRCS-1:0][N_BRANCHES-1:0] brh_srcb;
        logic [           4:0][ N_PRESELS-1:0] presels;
        postselect_t          [N_POSTSELS-1:0] postsels;
    } cgra_cfg_t;

    localparam int CONFIG_BITS = $bits(cgra_cfg_t);

endpackage

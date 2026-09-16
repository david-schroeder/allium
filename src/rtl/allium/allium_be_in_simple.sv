// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

// Interconnection network for simple Allium
// backend layout:
// - 2x ALU FUs
// - 2x IMM FUs
// - 1x LD/ST FU
// - 2x Move slots
// - 4x preselect lines
// - 2x postselect lines

// Source identifier mapping:
// 0000 - Zero
// 0001 - LD/ST out
// 0010 - Move slot 0 out (reg only)
// 0011 - Move slot 1 out (reg only)
// 0100 - IMM0 out
// 0101 - IMM1 out
// 0110 - ALU0 out
// 0111 - ALU1 out
// 1000 - preselect 0 (FU only)
// 1001 - preselect 1 (FU only)
// 1010 - preselect 2 (FU only)
// 1011 - preselect 3 (FU only)
// 11XX - (undefined)
//
// - Register writes (postselects) only
//   use 3-bit identifiers
// - Move logic uses 2-bit identifiers
//   selecting a preselect line
// - All other FU inputs have 4-bit
//   identifiers

module allium_be_in_simple
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Architectural Register State
    input  logic [31:0] regs_i    [31:0],
    input  logic [ 5:0] presel_i  [ 3:0],
    input  postselect_t postsel_i [ 1:0],
    output logic [31:0] regs_o    [31:0],
    output logic [31:0] regce_o,

    // Configuration
    input  logic        cfg_update_i,
    input  logic [ 1:0] cfg_move0_src_i,
    input  logic [ 1:0] cfg_move1_src_i,
    input  logic [ 3:0] cfg_alu0_srca_i,
    input  logic [ 3:0] cfg_alu0_srcb_i,
    input  logic [ 3:0] cfg_alu1_srca_i,
    input  logic [ 3:0] cfg_alu1_srcb_i,
    input  logic [ 3:0] cfg_ldst_srca_i,
    input  logic [ 3:0] cfg_ldst_srcb_i,
    input  logic [ 3:0] cfg_brh_srca_i,
    input  logic [ 3:0] cfg_brh_srcb_i,

    // FU routing
    input  logic        imm0_valid_i,
    input  logic [31:0] imm0_data_i,
    input  logic        imm1_valid_i,
    input  logic [31:0] imm1_data_i,
    input  logic        alu0_valid_i,
    input  logic [31:0] alu0_data_i,
    input  logic        alu1_valid_i,
    input  logic [31:0] alu1_data_i,
    input  logic        ldst_valid_i,
    input  logic [31:0] ldst_data_i,
    input  logic        brh_valid_i,
    output logic        alu0_a_valid_o,
    output logic [31:0] alu0_a_data_o,
    output logic        alu0_b_valid_o,
    output logic [31:0] alu0_b_data_o,
    output logic        alu1_a_valid_o,
    output logic [31:0] alu1_a_data_o,
    output logic        alu1_b_valid_o,
    output logic [31:0] alu1_b_data_o,
    output logic        ldst_a_valid_o,
    output logic [31:0] ldst_a_data_o,
    output logic        ldst_b_valid_o,
    output logic [31:0] ldst_b_data_o,
    output logic        brh_a_valid_o,
    output logic [31:0] brh_a_data_o,
    output logic        brh_b_valid_o,
    output logic [31:0] brh_b_data_o,

    // Global valid signal is typically asserted
    // once all regs' sources are valid. If the
    // LD/ST unit is storing, wait for it to
    // commit before asserting global valid.
    // Module assumes that ldst_is_store_i is
    // only asserted if the LD/ST FU is actually
    // used (i.e. will eventually be valid)

    input  logic        ldst_is_store_i,
    output logic        global_valid_o
);

    // 32 regs + 3 FUs (BRH doesn't generate data)
    // difference between *_srcs_reg and *_srcs_fu:
    //   If a non-IMM FU uses a result of another FU,
    //   that result should be buffered. If a
    //   register output uses an FU result then it
    //   should not be buffered.
    logic [31:0] data_srcs_reg [7:0];
    logic [31:0] data_srcs_fu  [15:0];
    logic [ 7:0] valid_srcs_reg;
    logic [15:0] valid_srcs_fu;
    logic [ 1:0] postsel_valid;

    logic [31:0] alu0_data_q;
    logic        alu0_valid_q;
    logic [31:0] alu1_data_q;
    logic        alu1_valid_q;
    logic [31:0] ldst_data_q;
    logic        ldst_valid_q;

    logic [ 1:0] cfg_move0_src_q;
    logic [ 1:0] cfg_move1_src_q;
    logic [ 3:0] cfg_alu0_srca_q;
    logic [ 3:0] cfg_alu0_srcb_q;
    logic [ 3:0] cfg_alu1_srca_q;
    logic [ 3:0] cfg_alu1_srcb_q;
    logic [ 3:0] cfg_ldst_srca_q;
    logic [ 3:0] cfg_ldst_srcb_q;
    logic [ 3:0] cfg_brh_srca_q;
    logic [ 3:0] cfg_brh_srcb_q;

    postselect_t postsel_q [1:0];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            alu0_data_q  <= '0;
            alu0_valid_q <= '0;
            alu1_data_q  <= '0;
            alu1_valid_q <= '0;
            ldst_data_q  <= '0;
            ldst_valid_q <= '0;
            cfg_move0_src_q <= '0;
            cfg_move1_src_q <= '0;
            cfg_alu0_srca_q <= '0;
            cfg_alu0_srcb_q <= '0;
            cfg_alu1_srca_q <= '0;
            cfg_alu1_srcb_q <= '0;
            cfg_ldst_srca_q <= '0;
            cfg_ldst_srcb_q <= '0;
            cfg_brh_srca_q  <= '0;
            cfg_brh_srcb_q  <= '0;
            for (int i = 0; i < 2; i++) begin
                postsel_q[i] <= '{default: '0};
            end
        end else begin
            alu0_data_q  <= alu0_data_i;
            alu0_valid_q <= alu0_valid_i;
            alu1_data_q  <= alu1_data_i;
            alu1_valid_q <= alu1_valid_i;
            ldst_data_q  <= ldst_data_i;
            ldst_valid_q <= ldst_valid_i;
            if (cfg_update_i) begin
                alu0_valid_q <= '0;
                alu1_valid_q <= '0;
                ldst_valid_q <= '0;
                for (int i = 0; i < 2; i++) begin
                    postsel_q[i] <= postsel_i[i];
                end
                cfg_move0_src_q <= cfg_move0_src_i;
                cfg_move1_src_q <= cfg_move1_src_i;
                cfg_alu0_srca_q <= cfg_alu0_srca_i;
                cfg_alu0_srcb_q <= cfg_alu0_srcb_i;
                cfg_alu1_srca_q <= cfg_alu1_srca_i;
                cfg_alu1_srcb_q <= cfg_alu1_srcb_i;
                cfg_ldst_srca_q <= cfg_ldst_srca_i;
                cfg_ldst_srcb_q <= cfg_ldst_srcb_i;
                cfg_brh_srca_q  <= cfg_brh_srca_i;
                cfg_brh_srcb_q  <= cfg_brh_srcb_i;
            end
        end
    end

    assign global_valid_o = &regs_valid
                         && (!ldst_is_store_i || ldst_valid_i)
                         && brh_valid_i;

    always_comb begin
        data_srcs_reg [0] = '0;
        valid_srcs_reg[0] = '1;
        for (int i = 1; i < 32; i++) begin
            data_srcs_reg [i] = regs_i[i];
            valid_srcs_reg[i] = '1;
        end
        data_srcs_reg [32] = imm_data_i;
        valid_srcs_reg[32] = imm_valid_i;
        data_srcs_reg [33] = alu_data_i;
        valid_srcs_reg[33] = alu_valid_i;
        data_srcs_reg [34] = ldst_data_i;
        valid_srcs_reg[34] = ldst_valid_i;

        regs_valid[0] = '1;
        regs_o    [0] = '0;
        for (int i = 1; i < 32; i++) begin
            regs_o    [i] = data_srcs_reg [regsrc_q[i]];
            regs_valid[i] = valid_srcs_reg[regsrc_q[i]];
        end
    end

    always_comb begin
        data_srcs_fu [0] = '0;
        valid_srcs_fu[0] = '1;
        for (int i = 1; i < 32; i++) begin
            data_srcs_fu [i] = regs_i[i];
            valid_srcs_fu[i] = '1;
        end
        data_srcs_fu [32] = imm_data_i;
        valid_srcs_fu[32] = imm_valid_i;
        data_srcs_fu [33] = alu_data_q;
        valid_srcs_fu[33] = alu_valid_q;
        data_srcs_fu [34] = ldst_data_q;
        valid_srcs_fu[34] = ldst_valid_q;

        alu_a_valid_o  = valid_srcs_fu[cfg_alu_srca_q];
        alu_a_data_o   = data_srcs_fu [cfg_alu_srca_q];
        alu_b_valid_o  = valid_srcs_fu[cfg_alu_srcb_q];
        alu_b_data_o   = data_srcs_fu [cfg_alu_srcb_q];
        ldst_a_valid_o = valid_srcs_fu[cfg_ldst_srca_q];
        ldst_a_data_o  = data_srcs_fu [cfg_ldst_srca_q];
        ldst_b_valid_o = valid_srcs_fu[cfg_ldst_srcb_q];
        ldst_b_data_o  = data_srcs_fu [cfg_ldst_srcb_q];
        brh_a_valid_o  = valid_srcs_fu[cfg_brh_srca_q];
        brh_a_data_o   = data_srcs_fu [cfg_brh_srca_q];
        brh_b_valid_o  = valid_srcs_fu[cfg_brh_srcb_q];
        brh_b_data_o   = data_srcs_fu [cfg_brh_srcb_q];
    end

endmodule

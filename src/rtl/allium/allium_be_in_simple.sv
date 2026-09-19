// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

// Interconnection network for simple Allium
// backend layout

module allium_be_in_simple
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Architectural Register State
    input  logic [31:0] regs_i    [31:0],
    output logic [31:0] regs_o    [31:0],
    // regce_o should be combined with the global valid
    output logic [31:0] regce_o,

    // Configuration
    input  logic        cfg_update_i,
    input  cgra_cfg_t   config_i,

    // FU routing
    input  logic        imm_valid_i    [    N_IMMS-1:0],
    input  logic [31:0] imm_data_i     [    N_IMMS-1:0],
    input  logic        alu_valid_i    [    N_ALUS-1:0],
    input  logic [31:0] alu_data_i     [    N_ALUS-1:0],
    input  logic        ldst_valid_i   [   N_LDSTS-1:0],
    input  logic [31:0] ldst_data_i    [   N_LDSTS-1:0],
    input  logic        brh_valid_i    [N_BRANCHES-1:0],
    output logic        alu_a_valid_o  [    N_ALUS-1:0],
    output logic [31:0] alu_a_data_o   [    N_ALUS-1:0],
    output logic        alu_b_valid_o  [    N_ALUS-1:0],
    output logic [31:0] alu_b_data_o   [    N_ALUS-1:0],
    output logic        ldst_a_valid_o [   N_LDSTS-1:0],
    output logic [31:0] ldst_a_data_o  [   N_LDSTS-1:0],
    output logic        ldst_b_valid_o [   N_LDSTS-1:0],
    output logic [31:0] ldst_b_data_o  [   N_LDSTS-1:0],
    output logic        brh_a_valid_o  [N_BRANCHES-1:0],
    output logic [31:0] brh_a_data_o   [N_BRANCHES-1:0],
    output logic        brh_b_valid_o  [N_BRANCHES-1:0],
    output logic [31:0] brh_b_data_o   [N_BRANCHES-1:0],

    // Global valid signal is typically asserted
    // once all regs' sources are valid. If the
    // LD/ST unit is storing, wait for it to
    // commit before asserting global valid.
    // Module assumes that ldst_is_store_i is
    // only asserted if the LD/ST FU is actually
    // used (i.e. will eventually be valid)

    input  logic        ldst_is_store_i [N_LDSTS-1:0],
    output logic        global_valid_o
);

    logic [31:0] presel_data [N_PRESELS-1:0];
    logic [32:0] sources_reg [N_REGSRCS-1:0]; // valid + data
    logic [32:0] sources_fu  [ N_FUSRCS-1:0]; // valid + data

    logic [31:0] alu_data_q   [N_ALUS-1:0];
    logic        alu_valid_q  [N_ALUS-1:0];
    logic [31:0] ldst_data_q  [N_LDSTS-1:0];
    logic        ldst_valid_q [N_LDSTS-1:0];

    logic [31:0] move_data [N_MOVS-1:0];

    cgra_cfg_t config_q;

    logic [N_POSTSELS-1:0] postsel_valid;
    logic [          31:0] postsel_data [N_POSTSELS-1:0];

    generate
        for (genvar i = 0; i < N_PRESELS; i++) begin : gen_presel_data
            assign presel_data[i] = regs_i[config_q.presels[i]];
        end : gen_presel_data

        for (genvar i = 0; i < N_MOVS; i++) begin : gen_movs
            assign move_data[i] = presel_data[config_q.move_src[i]];
        end : gen_movs

        for (genvar i = 0; i < N_POSTSELS; i++) begin : gen_postsels
            assign {
                postsel_valid[i],
                postsel_data[i]
            } = sources_reg[config_q.postsels[i].src];
        end : gen_postsels
    endgenerate

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            for (int i = 0; i < N_ALUS; i++) begin
                alu_data_q[i]  <= '0;
                alu_valid_q[i] <= '0;
            end
            for (int i = 0; i < N_LDSTS; i++) begin
                ldst_data_q[i]  <= '0;
                ldst_valid_q[i] <= '0;
            end
            config_q <= '{default: '0};
        end else begin
            alu_data_q   <= alu_data_i;
            alu_valid_q  <= alu_valid_i;
            ldst_data_q  <= ldst_data_i;
            ldst_valid_q <= ldst_valid_i;
            if (cfg_update_i) begin
                alu_valid_q  <= '{default: '0};
                ldst_valid_q <= '{default: '0};
                config_q     <= config_i;
            end
        end
    end

    always_comb begin
        global_valid_o = &postsel_valid;

        for (int i = 0; i < N_BRANCHES; i++) begin
            global_valid_o &= brh_valid_i[i];
        end

        for (int i = 0; i < N_LDSTS; i++) begin
            global_valid_o &= (!ldst_is_store_i[i] | ldst_valid_i[i]);
        end
    end

    /* Routing generation */
    generate
        assign sources_reg[0] = {1'b1, 32'b0};
        assign sources_fu[0]  = {1'b1, 32'b0};

        // Immediates
        for (genvar i = 0; i < N_IMMS; i++) begin : gen_imm_srcs
            assign sources_reg[SRC_IMM_BASE + i] = {
                imm_valid_i[i], imm_data_i[i]
            };
            assign sources_fu[SRC_IMM_BASE + i] = {
                imm_valid_i[i], imm_data_i[i]
            };
        end : gen_imm_srcs

        // ALU FUs
        for (genvar i = 0; i < N_ALUS; i++) begin : gen_alu_srcs
            assign sources_reg[SRC_ALU_BASE + i] = {
                alu_valid_i[i], alu_data_i[i]
            };
            assign sources_fu[SRC_ALU_BASE + i] = {
                alu_valid_q[i], alu_data_q[i]
            };
        end : gen_alu_srcs

        // LD/ST FUs
        for (genvar i = 0; i < N_LDSTS; i++) begin : gen_ldst_srcs
            assign sources_reg[SRC_LDST_BASE + i] = {
                ldst_valid_i[i], ldst_data_i[i]
            };
            assign sources_fu[SRC_LDST_BASE + i] = {
                ldst_valid_q[i], ldst_data_q[i]
            };
        end : gen_ldst_srcs

        // Moves
        for (genvar i = 0; i < N_MOVS; i++) begin : gen_mov_srcs
            assign sources_reg[SRC_MOVE_BASE + i] = {
                1'b1, move_data[i]
            };
        end : gen_mov_srcs

        // Preselects
        for (genvar i = 0; i < N_PRESELS; i++) begin : gen_presel_srcs
            assign sources_fu[SRC_PRESEL_BASE + i] = {
                1'b1, presel_data[i]
            };
        end : gen_presel_srcs

        // Output signals
        for (genvar i = 0; i < N_ALUS; i++) begin : gen_alu_outs
            assign {
                alu_a_valid_o[i], alu_a_data_o[i]
            } = sources_fu[config_q.alu_srca[i]];
            assign {
                alu_b_valid_o[i], alu_b_data_o[i]
            } = sources_fu[config_q.alu_srcb[i]];
        end : gen_alu_outs
        for (genvar i = 0; i < N_LDSTS; i++) begin : gen_ldst_outs
            assign {
                ldst_a_valid_o[i], ldst_a_data_o[i]
            } = sources_fu[config_q.ldst_srca];
            assign {
                ldst_b_valid_o[i], ldst_b_data_o[i]
            } = sources_fu[config_q.ldst_srcb];
        end : gen_ldst_outs
        for (genvar i = 0; i < N_BRANCHES; i++) begin : gen_brh_outs
            assign {
                brh_a_valid_o[i], brh_a_data_o[i]
            } = sources_fu[config_q.brh_srca];
            assign {
                brh_b_valid_o[i], brh_b_data_o[i]
            } = sources_fu[config_q.brh_srcb];
        end : gen_brh_outs
    endgenerate

    always_comb begin
        regs_o = '{default: '0};
        regce_o = '0;

        for (int i = 0; i < N_POSTSELS; i++) begin
            regs_o[config_q.postsels[i].dest] = postsel_data[i];
            regce_o[config_q.postsels[i].dest] = '1;
        end

        regce_o[0] = '0;
    end

endmodule

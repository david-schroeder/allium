// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_cgra_core
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Configuration
    input  logic        cfg_update_i,
    input  cgra_cfg_t   config_i,

    input  logic [31:0] regs_i    [31:0],
    output logic [31:0] regs_o    [31:0],
    output logic [31:0] regce_o,
    output logic        global_valid_o,
    output logic        take_branch_o
);

    /////////////
    //         //
    // SIGNALS //
    //         //
    /////////////

    // FU inputs
    logic        alu_a_valid  [    N_ALUS-1:0];
    logic        alu_b_valid  [    N_ALUS-1:0];
    logic [31:0] alu_a_data   [    N_ALUS-1:0];
    logic [31:0] alu_b_data   [    N_ALUS-1:0];
    logic        ldst_a_valid [   N_LDSTS-1:0];
    logic        ldst_b_valid [   N_LDSTS-1:0];
    logic [31:0] ldst_a_data  [   N_LDSTS-1:0];
    logic [31:0] ldst_b_data  [   N_LDSTS-1:0];
    logic        brh_a_valid  [N_BRANCHES-1:0];
    logic        brh_b_valid  [N_BRANCHES-1:0];
    logic [31:0] brh_a_data   [N_BRANCHES-1:0];
    logic [31:0] brh_b_data   [N_BRANCHES-1:0];

    // FU outputs
    logic        imm_valid    [    N_IMMS-1:0];
    logic [31:0] imm_data     [    N_IMMS-1:0];
    logic        alu_valid    [    N_ALUS-1:0];
    logic [31:0] alu_data     [    N_ALUS-1:0];
    logic        ldst_valid   [   N_LDSTS-1:0];
    logic [31:0] ldst_data    [   N_LDSTS-1:0];
    logic        brh_valid    [N_BRANCHES-1:0];

    // Other
    logic ldst_is_store [N_LDSTS-1:0];
    logic branch_taken;

    //////////////////
    //              //
    // INTERCONNECT //
    //              //
    //////////////////

    allium_interconnect interconnect_i (
        .clk_i,
        .rst_ni,

        .regs_i,
        .regs_o,
        .regce_o,

        .cfg_update_i,
        .config_i,

        .imm_valid_i    (imm_valid),
        .imm_data_i     (imm_data),
        .alu_valid_i    (alu_valid),
        .alu_data_i     (alu_data),
        .ldst_valid_i   (ldst_valid),
        .ldst_data_i    (ldst_data),
        .brh_valid_i    (brh_valid),
        .alu_a_valid_o  (alu_a_valid),
        .alu_a_data_o   (alu_a_data),
        .alu_b_valid_o  (alu_b_valid),
        .alu_b_data_o   (alu_b_data),
        .ldst_a_valid_o (ldst_a_valid),
        .ldst_a_data_o  (ldst_a_data),
        .ldst_b_valid_o (ldst_b_valid),
        .ldst_b_data_o  (ldst_b_data),
        .brh_a_valid_o  (brh_a_valid),
        .brh_a_data_o   (brh_a_data),
        .brh_b_valid_o  (brh_b_valid),
        .brh_b_data_o   (brh_b_data),

        .ldst_is_store_i(ldst_is_store),
        .global_valid_o
    );

    ///////////////////
    //               //
    // FU GENERATION //
    //               //
    ///////////////////

    generate

        for (genvar i = 0; i < N_IMMS; i++) begin : gen_imms
            allium_fu_imm fu_imm_i (
                .clk_i,
                .rst_ni,
                .cfg_update_i,
                .cfg_data_i  (config_i.imm_data[i]),
                .valid_o     (imm_valid[i]),
                .data_o      (imm_data[i])
            );
        end : gen_imms

        for (genvar i = 0; i < N_ALUS; i++) begin : gen_alus
            allium_fu_alu fu_alu_i (
                .clk_i,
                .rst_ni,
                .cfg_update_i,
                .cfg_op_i    (config_i.alu_op[i]),
                .cfg_is_imm_i(config_i.alu_is_imm[i]),
                .cfg_imm_i   (config_i.alu_imm[i]),
                .a_valid_i   (alu_a_valid[i]),
                .a_data_i    (alu_a_data[i]),
                .b_valid_i   (alu_b_valid[i]),
                .b_data_i    (alu_b_data[i]),
                .valid_o     (alu_valid[i]),
                .data_o      (alu_data[i])
            );
        end : gen_alus

        for (genvar i = 0; i < N_LDSTS; i++) begin : gen_ldsts
            allium_fu_ldst fu_ldst_i (
                .clk_i,
                .rst_ni,
                .cfg_update_i,
                .cfg_op_i    (config_i.ldst_op[i]),
                .cfg_offs_i  (config_i.ldst_offs[i]),
                .a_valid_i   (ldst_a_valid[i]),
                .a_data_i    (ldst_a_data[i]),
                .b_valid_i   (ldst_b_valid[i]),
                .b_data_i    (ldst_b_data[i]),
                .is_store_o  (ldst_is_store[i]),
                .valid_o     (ldst_valid[i]),
                .data_o      (ldst_data[i])
            );
        end : gen_ldsts

    endgenerate

    // branch logic will need massive updating anyways
    // when multiple branch/commit set support is added
    // for now just hardcode one unit

    allium_fu_branch fu_branch_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_branch_i (config_i.branch[0]),
        .a_valid_i    (brh_a_valid[0]),
        .a_data_i     (brh_a_data[0]),
        .b_valid_i    (brh_b_valid[0]),
        .b_data_i     (brh_b_data[0]),
        .valid_o      (brh_valid[0]),
        .take_branch_o
    );

endmodule

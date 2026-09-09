// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_cgra_core
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Configuration
    input  logic        cfg_update_i,
    input  logic [31:0] cfg_imm_data_i,
    input  alu_op_e     cfg_alu_op_i,
    input  logic [ 5:0] cfg_alu_srca_i,
    input  logic [ 5:0] cfg_alu_srcb_i,
    input  mem_op_e     cfg_ldst_op_i,
    input  logic [ 5:0] cfg_ldst_srca_i,
    input  logic [ 5:0] cfg_ldst_srcb_i,
    input  logic [11:0] cfg_ldst_offs_i,
    input  branch_e     cfg_branch_i,
    input  logic [ 5:0] cfg_brh_srca_i,
    input  logic [ 5:0] cfg_brh_srcb_i,

    input  logic [31:0] regs_i   [31:0],
    input  logic [ 5:0] regsrc_i [31:0],
    output logic [31:0] regs_o   [31:0],
    output logic        global_valid_o,
    output logic        take_branch_o
);

    /////////////
    //         //
    // SIGNALS //
    //         //
    /////////////

    // FU inputs
    logic        alu_a_valid;
    logic        alu_b_valid;
    logic [31:0] alu_a_data;
    logic [31:0] alu_b_data;
    logic        ldst_a_valid;
    logic        ldst_b_valid;
    logic [31:0] ldst_a_data;
    logic [31:0] ldst_b_data;
    logic        brh_a_valid;
    logic        brh_b_valid;
    logic [31:0] brh_a_data;
    logic [31:0] brh_b_data;

    // FU outputs
    logic        imm_valid;
    logic [31:0] imm_data;
    logic        alu_valid;
    logic [31:0] alu_data;
    logic        ldst_valid;
    logic [31:0] ldst_data;
    logic        brh_valid;

    // Other
    logic ldst_is_store;
    logic branch_taken;

    ///////////////////
    //               //
    // INSTANTIATION //
    //               //
    ///////////////////

    allium_be_in_simple interconnect_i (
        .clk_i,
        .rst_ni,

        .regs_i,
        .regsrc_i,
        .regs_o,

        .cfg_update_i,
        .cfg_alu_srca_i,
        .cfg_alu_srcb_i,
        .cfg_ldst_srca_i,
        .cfg_ldst_srcb_i,
        .cfg_brh_srca_i,
        .cfg_brh_srcb_i,

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

    allium_be_imm fu_imm_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_data_i  (cfg_imm_data_i),
        .valid_o     (imm_valid),
        .data_o      (imm_data)
    );

    allium_be_alu fu_alu_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_op_i    (cfg_alu_op_i),
        .a_valid_i   (alu_a_valid),
        .a_data_i    (alu_a_data),
        .b_valid_i   (alu_b_valid),
        .b_data_i    (alu_b_data),
        .valid_o     (alu_valid),
        .data_o      (alu_data)
    );

    allium_be_ldst fu_ldst_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_op_i    (cfg_ldst_op_i),
        .cfg_offs_i  (cfg_ldst_offs_i),
        .a_valid_i   (ldst_a_valid),
        .a_data_i    (ldst_a_data),
        .b_valid_i   (ldst_b_valid),
        .b_data_i    (ldst_b_data),
        .is_store_o  (ldst_is_store),
        .valid_o     (ldst_valid),
        .data_o      (ldst_data)
    );

    allium_be_branch fu_branch_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_branch_i (cfg_branch_i),
        .a_valid_i    (brh_a_valid),
        .a_data_i     (brh_a_data),
        .b_valid_i    (brh_b_valid),
        .b_data_i     (brh_b_data),
        .valid_o      (brh_valid),
        .take_branch_o
    );

endmodule

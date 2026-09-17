// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_cgra_core
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Configuration
    input  logic        cfg_update_i,
    input  logic [31:0] cfg_imm0_data_i,
    input  logic [31:0] cfg_imm1_data_i,
    input  logic [ 1:0] cfg_move0_src_i,
    input  logic [ 1:0] cfg_move1_src_i,
    input  alu_op_e     cfg_alu0_op_i,
    input  logic [ 3:0] cfg_alu0_srca_i,
    input  logic [ 3:0] cfg_alu0_srcb_i,
    input  alu_op_e     cfg_alu1_op_i,
    input  logic [ 3:0] cfg_alu1_srca_i,
    input  logic [ 3:0] cfg_alu1_srcb_i,
    input  mem_op_e     cfg_ldst_op_i,
    input  logic [ 3:0] cfg_ldst_srca_i,
    input  logic [ 3:0] cfg_ldst_srcb_i,
    input  logic [11:0] cfg_ldst_offs_i,
    input  branch_e     cfg_branch_i,
    input  logic [ 3:0] cfg_brh_srca_i,
    input  logic [ 3:0] cfg_brh_srcb_i,

    input  logic [31:0] regs_i    [31:0],
    input  logic [ 4:0] presel_i  [ 3:0],
    input  postselect_t postsel_i [ 1:0],
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
    logic        alu0_a_valid;
    logic        alu0_b_valid;
    logic [31:0] alu0_a_data;
    logic [31:0] alu0_b_data;
    logic        alu1_a_valid;
    logic        alu1_b_valid;
    logic [31:0] alu1_a_data;
    logic [31:0] alu1_b_data;
    logic        ldst_a_valid;
    logic        ldst_b_valid;
    logic [31:0] ldst_a_data;
    logic [31:0] ldst_b_data;
    logic        brh_a_valid;
    logic        brh_b_valid;
    logic [31:0] brh_a_data;
    logic [31:0] brh_b_data;

    // FU outputs
    logic        imm0_valid;
    logic [31:0] imm0_data;
    logic        imm1_valid;
    logic [31:0] imm1_data;
    logic        alu0_valid;
    logic [31:0] alu0_data;
    logic        alu1_valid;
    logic [31:0] alu1_data;
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
        .presel_i,
        .postsel_i,
        .regs_o,
        .regce_o,

        .cfg_update_i,
        .cfg_move0_src_i,
        .cfg_move1_src_i,
        .cfg_alu0_srca_i,
        .cfg_alu0_srcb_i,
        .cfg_alu1_srca_i,
        .cfg_alu1_srcb_i,
        .cfg_ldst_srca_i,
        .cfg_ldst_srcb_i,
        .cfg_brh_srca_i,
        .cfg_brh_srcb_i,

        .imm0_valid_i   (imm0_valid),
        .imm0_data_i    (imm0_data),
        .imm1_valid_i   (imm1_valid),
        .imm1_data_i    (imm1_data),
        .alu0_valid_i   (alu0_valid),
        .alu0_data_i    (alu0_data),
        .alu1_valid_i   (alu1_valid),
        .alu1_data_i    (alu1_data),
        .ldst_valid_i   (ldst_valid),
        .ldst_data_i    (ldst_data),
        .brh_valid_i    (brh_valid),
        .alu0_a_valid_o (alu0_a_valid),
        .alu0_a_data_o  (alu0_a_data),
        .alu0_b_valid_o (alu0_b_valid),
        .alu0_b_data_o  (alu0_b_data),
        .alu1_a_valid_o (alu1_a_valid),
        .alu1_a_data_o  (alu1_a_data),
        .alu1_b_valid_o (alu1_b_valid),
        .alu1_b_data_o  (alu1_b_data),
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

    allium_be_imm fu_imm0_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_data_i  (cfg_imm0_data_i),
        .valid_o     (imm0_valid),
        .data_o      (imm0_data)
    );

    allium_be_imm fu_imm1_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_data_i  (cfg_imm1_data_i),
        .valid_o     (imm1_valid),
        .data_o      (imm1_data)
    );

    allium_be_alu fu_alu0_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_op_i    (cfg_alu0_op_i),
        .a_valid_i   (alu0_a_valid),
        .a_data_i    (alu0_a_data),
        .b_valid_i   (alu0_b_valid),
        .b_data_i    (alu0_b_data),
        .valid_o     (alu0_valid),
        .data_o      (alu0_data)
    );

    allium_be_alu fu_alu1_i (
        .clk_i,
        .rst_ni,
        .cfg_update_i,
        .cfg_op_i    (cfg_alu1_op_i),
        .a_valid_i   (alu1_a_valid),
        .a_data_i    (alu1_a_data),
        .b_valid_i   (alu1_b_valid),
        .b_data_i    (alu1_b_data),
        .valid_o     (alu1_valid),
        .data_o      (alu1_data)
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

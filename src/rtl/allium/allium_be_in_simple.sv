// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

// Interconnection network for simplest Allium
// backend layout (single ALU/IMM/LDST respectively)

// Source identifiers are 6 bits:
// 0XXXXX - Register XXXXX
// 100000 - IMM out
// 100001 - ALU out
// 100010 - LDST out

module allium_be_in_simple
    import allium_pkg::*;
(
    input  logic clk_i,
    input  logic rst_ni,

    // Architectural Register State
    input  logic [31:0] regs_i   [31:0],
    input  logic [ 5:0] regsrc_i [31:0],
    output logic [31:0] regs_o   [31:0],

    // Configuration
    input  logic        cfg_update_i,
    input  logic [ 5:0] cfg_alu_srca_i,
    input  logic [ 5:0] cfg_alu_srcb_i,
    input  logic [ 5:0] cfg_ldst_srca_i,
    input  logic [ 5:0] cfg_ldst_srcb_i,

    // FU routing
    input  logic        imm_valid_i,
    input  logic [31:0] imm_data_i,
    input  logic        alu_valid_i,
    input  logic [31:0] alu_data_i,
    input  logic        ldst_valid_i,
    input  logic [31:0] ldst_data_i,
    output logic        alu_a_valid_o,
    output logic [31:0] alu_a_data_o,
    output logic        alu_b_valid_o,
    output logic [31:0] alu_b_data_o,
    output logic        ldst_a_valid_o,
    output logic [31:0] ldst_a_data_o,
    output logic        ldst_b_valid_o,
    output logic [31:0] ldst_b_data_o,

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

    // 32 regs + 3 FUs
    // difference between *_srcs_reg and *_srcs_fu:
    //   If a non-IMM FU uses a result of another FU,
    //   that result should be buffered. If a
    //   register output uses an FU result then it
    //   should not be buffered.
    logic [31:0] data_srcs_reg [34:0];
    logic [31:0] data_srcs_fu  [34:0];
    logic [34:0] valid_srcs_reg;
    logic [34:0] valid_srcs_fu;
    logic [31:0] regs_valid;

    logic [31:0] alu_data_q;
    logic        alu_valid_q;
    logic [31:0] ldst_data_q;
    logic        ldst_valid_q;

    logic [ 5:0] regsrc_q [31:0];

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            alu_data_q   <= '0;
            alu_valid_q  <= '0;
            ldst_data_q  <= '0;
            ldst_valid_q <= '0;
            for (int i = 0; i < 32; i++) begin
                regsrc_q[i] <= '0;
            end
        end else begin
            alu_data_q   <= alu_data_i;
            alu_valid_q  <= alu_valid_i;
            ldst_data_q  <= ldst_data_i;
            ldst_valid_q <= ldst_valid_i;
            if (cfg_update_i) begin
                alu_valid_q  <= '0;
                ldst_valid_q <= '0;
                for (int i = 0; i < 32; i++) begin
                    regsrc_q[i] <= regsrc_i[i];
                end
            end
        end
    end

    assign global_valid_o = &regs_valid && (!ldst_is_store_i || ldst_valid_i);

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

        alu_a_valid_o  = valid_srcs_fu[cfg_alu_srca_i];
        alu_a_data_o   = data_srcs_fu [cfg_alu_srca_i];
        alu_b_valid_o  = valid_srcs_fu[cfg_alu_srcb_i];
        alu_b_data_o   = data_srcs_fu [cfg_alu_srcb_i];
        ldst_a_valid_o = valid_srcs_fu[cfg_ldst_srca_i];
        ldst_a_data_o  = data_srcs_fu [cfg_ldst_srca_i];
        ldst_b_valid_o = valid_srcs_fu[cfg_ldst_srcb_i];
        ldst_b_data_o  = data_srcs_fu [cfg_ldst_srcb_i];
    end

endmodule

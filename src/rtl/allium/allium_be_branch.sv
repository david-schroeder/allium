// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_be_branch
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic        cfg_update_i,
	input  branch_e     cfg_branch_i,

	input  logic        a_valid_i,
	input  logic [31:0] a_data_i,
	input  logic        b_valid_i,
	input  logic [31:0] b_data_i,

	output logic        valid_o,
	output logic        take_branch_o
);

	branch_e     branchtype_q;
	logic        lt, ltu, eq;

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			branchtype_q <= BEQ;
		end else begin
			if (cfg_update_i) begin
				branchtype_q <= cfg_branch_i;
			end
		end
	end

	always_comb begin
		lt = $signed(a_data_i) < $signed(b_data_i);
		ltu = a_data_i < b_data_i;
		eq = a_data_i == b_data_i;

		case (branchtype_q)
            BEQ : take_branch_o = eq;
            BNE : take_branch_o = ~eq;
            BLT : take_branch_o = lt;
            BGE : take_branch_o = ~lt;
            BLTU: take_branch_o = ltu;
            BGEU: take_branch_o = ~ltu;
            default: take_branch_o = '0;
        endcase
	end

	assign valid_o = a_valid_i && b_valid_i;

endmodule

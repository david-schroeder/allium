// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_be_alu
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic        cfg_update_i,
	input  alu_op_e     cfg_op_i,

	input  logic        a_valid_i,
	input  logic [31:0] a_data_i,
	input  logic        b_valid_i,
	input  logic [31:0] b_data_i,

	output logic        valid_o,
	output logic [31:0] data_o
);

	alu_op_e op_q;
	logic lt, ltu, eq;

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			op_q <= ADD;
		end else begin
			if (cfg_update_i) op_q <= cfg_op_i;
		end
	end

	always_comb begin
		lt  = $signed(a_data_i) < $signed(b_data_i);
		ltu = a_data_i < b_data_i;

		case (op_q)
			ADD    : data_o = a_data_i + b_data_i;
			SUB    : data_o = a_data_i - b_data_i;
			XOR    : data_o = a_data_i ^ b_data_i;
			AND    : data_o = a_data_i & b_data_i;
			OR     : data_o = a_data_i | b_data_i;
			SLT    : data_o = {31'h0, lt};
			SLTU   : data_o = {31'h0, ltu};
			SLL    : data_o = a_data_i << b_data_i[4:0];
			SRL    : data_o = a_data_i >> b_data_i[4:0];
			SRA    : data_o = $signed(a_data_i) >>> b_data_i[4:0];
			default: data_o = '0;
		endcase
	end

	assign valid_o = a_valid_i && b_valid_i;

endmodule

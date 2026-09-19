// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_fu_alu
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic        cfg_update_i,
	input  alu_op_e     cfg_op_i,
	input  logic        cfg_is_imm_i,
	input  logic [11:0] cfg_imm_i,

	input  logic        a_valid_i,
	input  logic [31:0] a_data_i,
	input  logic        b_valid_i,
	input  logic [31:0] b_data_i,

	output logic        valid_o,
	output logic [31:0] data_o
);

	alu_op_e     op_q;
	logic        is_imm_q;
	logic [11:0] imm_q;
	logic [31:0] b_data;
	logic        lt;
	logic        ltu;

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			op_q     <= ADD;
			is_imm_q <= '0;
			imm_q    <= '0;
		end else begin
			if (cfg_update_i) begin
				op_q     <= cfg_op_i;
				is_imm_q <= cfg_is_imm_i;
				imm_q    <= cfg_imm_i;
			end
		end
	end

	always_comb begin
		b_data = is_imm_q ? {{20{imm_q[11]}}, imm_q} : b_data_i;
		lt  = $signed(a_data_i) < $signed(b_data);
		ltu = a_data_i < b_data;

		case (op_q)
			ADD    : data_o = a_data_i + b_data;
			SUB    : data_o = a_data_i - b_data;
			XOR    : data_o = a_data_i ^ b_data;
			AND    : data_o = a_data_i & b_data;
			OR     : data_o = a_data_i | b_data;
			SLT    : data_o = {31'h0, lt};
			SLTU   : data_o = {31'h0, ltu};
			SLL    : data_o = a_data_i << b_data[4:0];
			SRL    : data_o = a_data_i >> b_data[4:0];
			SRA    : data_o = $signed(a_data_i) >>> b_data[4:0];
			default: data_o = '0;
		endcase
	end

	assign valid_o = a_valid_i && (b_valid_i || is_imm_q);

endmodule

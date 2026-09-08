// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

// Load-Store FU for Allium backend.
// TODO: handle misaligned accesses
//       (they are UB today)

module allium_be_ldst
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic        cfg_update_i,
	input  mem_op_e     cfg_op_i,
	input  logic [11:0] cfg_offs_i,

	input  logic        a_valid_i,
	input  logic [31:0] a_data_i, // base addr
	input  logic        b_valid_i,
	input  logic [31:0] b_data_i, // store data

	output logic        is_store_o,
	output logic        valid_o,
	output logic [31:0] data_o // load data
);

	/* Configuration management */

	mem_op_e     op_q;
	logic        is_store_op;
	logic [11:0] offs_q;

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			op_q <= LB;
			offs_q <= '0;
		end else begin
			if (cfg_update_i) begin
				op_q <= cfg_op_i;
				offs_q <= cfg_offs_i;
			end
		end
	end

	assign is_store_op = op_q inside {SB, SH, SW};
	assign is_store_o  = is_store_op;

	/* LD/ST logic */

	logic [31:0] ea_d, ea_q; // effective address
	logic        inputs_valid;
	logic [31:0] rdata_full;
	logic [15:0] rdata_half;
	logic [ 7:0] rdata_byte;
	logic [31:0] load_data;
	logic [31:0] wdata_full;
	logic [ 3:0] wmask;

	assign ea_d = a_data_i + offs_q;
	// load operations only need A input
	assign inputs_valid = a_valid_i && (b_valid_i || !is_store_op);
	assign rdata_half = ea_q[1] ? rdata_full[31:16] : rdata_full[15:0];
	assign rdata_byte = ea_q[0] ? rdata_half[15:8] : rdata_half[7:0];

	always_comb begin
		case (op_q)
			LB     : load_data = {24'h0, rdata_byte};
			LBU    : load_data = {{24{rdata_byte[7]}}, rdata_byte};
			LH     : load_data = {16'h0, rdata_half};
			LHU    : load_data = {{16{rdata_half[15]}}, rdata_half};
			LW     : load_data = rdata_full;
			default: load_data = '0;
		endcase

		case (op_q)
			SB     : wdata_full = {b_data_i[7:0], b_data_i[7:0], b_data_i[7:0], b_data_i[7:0]};
			SH     : wdata_full = {b_data_i[15:8], b_data_i[15:8]};
			SW     : wdata_full = b_data_i;
			default: wdata_full = '0;
		endcase

		case ({op_q, ea_d[1:0]})
			{SB, 2'b00}: wmask = 4'b0001;
			{SB, 2'b01}: wmask = 4'b0010;
			{SB, 2'b10}: wmask = 4'b0100;
			{SB, 2'b11}: wmask = 4'b1000;
			{SH, 2'b00}: wmask = 4'b0011;
			{SH, 2'b10}: wmask = 4'b1100;
			{SW, 2'b00}: wmask = 4'b1111;
			default: wmask = '0;
		endcase
	end

	assign data_o = load_data;

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			ea_q <= '0;
			valid_o <= '0;
		end else begin
			ea_q <= ea_d;
			valid_o <= inputs_valid && !cfg_update_i;
		end
	end

	/* DTIM */

	logic [31:0] dmem [8191:0];

	always_ff @(posedge clk_i) begin
		if (inputs_valid) begin
			if (is_store_op) begin
				if (wmask[0]) dmem[ea_d[31:2]][ 7: 0] <= wdata_full[ 7: 0];
				if (wmask[1]) dmem[ea_d[31:2]][15: 8] <= wdata_full[15: 8];
				if (wmask[2]) dmem[ea_d[31:2]][23:16] <= wdata_full[23:16];
				if (wmask[3]) dmem[ea_d[31:2]][31:24] <= wdata_full[31:24];
			end
			rdata_full <= dmem[ea_d[31:2]];
		end
	end

	`define STRINGIFY(x) `"x`"
	initial begin
		$readmemh(`STRINGIFY(`INIT_MEM_FILE), dmem);
	end

endmodule

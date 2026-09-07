// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_block_stream_decoder
	import allium_pkg::*;
#(
	parameter logic [31:0] BOOT_ADDR = 32'h00000080
) (
	input  logic clk_i,
	input  logic rst_ni,

	input  logic [31:0] pc_i,
	input  logic        jump_i, // Jump to new address

	output logic [31:0] pc_o,
	output logic [31:0] insn_o,
	output logic        valid_o,
	input  logic        ready_i
);

	/*
		Allium "Block Stream Decoder" module
		====================================

		The backend configuration generation module in the frontend
		requires a stream of RISC-V instructions as they would appear
		in program order. The job of the BSD is thus to:
		- Start fetching instructions sequentially from `BOOT_ADDR`
		  after reset
		- Follow direct, unconditional jumps in the program stream
		  (without! producing a jump output instruction)
		- Yield fetched instructions on the output port (unless
		  explicitly suppressed)
		- Predict branches by BTFNT scheme; their instructions are
		  always yielded
		- Immediately interrupt any ongoing fetch operations if
		  `jump_i` is asserted, in which case it starts fetching
		  from the instruction at address `pc_i`
		- Stop fetching if a `JALR` is encountered; will only resume
		  fetching by `jump_i` assertion (TODO: revisit?)

		Currently, the BSD is TIM-based; TODO: add TileLink bus
	*/


	reg [31:0] imem [8191:0];

	logic [31:0] pc_d, pc_q;
	logic        valid_d, valid_q;
	logic        first_cycle_q;
	logic [31:0] insn;


	/* Coarse instruction decoding */
	// Decode control flow instructions


	logic        is_jal;
	logic [31:0] jal_offset;
	logic        is_jalr;
	logic        is_branch;
	logic [31:0] branch_offset;
	logic        branch_backwards; // corresponds to BTFNT prediction bit

	assign is_jal = insn[6:0] == 7'b1101111 && valid_q;
	assign jal_offset = {{12{insn[31]}}, insn[19:12], insn[20], insn[30:21], 1'b0};
	assign is_jalr = insn[6:0] == 7'b1100111 && insn[14:12] == 3'b000 && valid_q;
	assign is_branch = insn[6:0] == 7'b1100011 && insn[14:13] != 2'b01 && valid_q;
	assign branch_offset = {{20{insn[31]}}, insn[7], insn[30:25], insn[11:8], 1'b0};
	assign branch_backwards = insn[31]; // == branch_offset[31]


	/* Memory + PC plumbing */

	always_comb begin
		priority case (1'b1)
			first_cycle_q: pc_d = BOOT_ADDR;
			jump_i: pc_d = pc_i;
			is_jal: pc_d = pc_q + jal_offset;
			is_branch && branch_backwards: pc_d = pc_q + branch_offset;
			valid_q: pc_d = pc_q + 4;
			default: pc_d = pc_q;
		endcase

		priority case (1'b1)
			first_cycle_q: valid_d = '1;
			is_jalr: valid_d = '0;
			default: valid_d = valid_q;
		endcase
	end

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			pc_q <= BOOT_ADDR;
			valid_q <= '0;
			first_cycle_q <= '1;
		end else begin
			if (!valid_o || ready_i) begin
				pc_q <= pc_d;
				valid_q <= valid_d;
			end
			first_cycle_q <= '0;
		end
	end

	always_ff @(posedge clk_i) begin
		insn <= imem[pc_d[31:2]];
	end


	assign insn_o = insn;
	assign pc_o = pc_q;
	assign valid_o = valid_q && !is_jal; // jumps are not yielded

	`define STRINGIFY(x) `"x`"
	initial begin
		$readmemh(`STRINGIFY(`INIT_MEM_FILE), imem);
	end

endmodule

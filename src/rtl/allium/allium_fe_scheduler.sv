// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_fe_scheduler
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic [31:0] bsd_pc_i,
	input  logic [31:0] bsd_insn_i,
	input  logic        bsd_valid_i,
	output logic        bsd_ready_o,

	output logic        cfg_valid_o,
	input  logic        cfg_ready_i,
	output logic [31:0] cfg_pc_o,
	output cgra_cfg_t   config_o
);

	/*
		Allium Scheduler
		================

		The scheduler lies at the heart of the entire design. Its
		job is to accept a stream of RISC-V instructions from the
		Block Stream Decoder and to convert it into a sequence of
		CGRA configurations that the backend can use directly.
	*/

	/* Instruction decoding */

	typedef enum logic [2:0] {
		IMM, // LUI, AUIPC, JAL, JALR
		BRANCH, // BEQ, BNE, BLT, BGE, BLTU, BGEU
		LOAD, // LB, LBU, LH, LHU, LW
		STORE, // SB, SH, SW
		ARITH, // ADDI, SLTI, SLTIU, XORI, ORI, ANDI,
			   // SLLI, SRLI, SRAI,
			   // ADD, SUB, SLL, SLT, SLTU, XOR, SRL,
			   // SRA, OR, AND
		NOP // FENCE, ECALL, EBREAK, ARITH/LOAD with rd=x0
	} instr_group_e;


	logic [ 6:0] opcode;
	logic [ 2:0] funct3;
	logic [ 6:0] funct7;
	logic [ 4:0] rs1;
	logic [ 4:0] rs2;
	logic [ 4:0] rd;
	logic [11:0] imm12;

	assign opcode = bsd_insn_i[6:0];
	assign funct3 = bsd_insn_i[14:12];
	assign funct7 = bsd_insn_i[31:25];
	assign rs1    = bsd_insn_i[19:15];
	assign rs2    = bsd_insn_i[24:20];
	assign rd     = bsd_insn_i[11:7];
	assign imm12  = bsd_insn_i[31:20];

	/* Configuration management logic */

	cgra_cfg_t cfg_d, cfg_q;
	assign config_o = cfg_q;

	logic alu_used_d, alu_used_q;
	logic imm_used_d, imm_used_q;
	logic ldst_used_d, ldst_used_q;
	logic brh_used_d, brh_used_q;

	always_comb begin
		cfg_d       = cfg_q;
		alu_used_d  = alu_used_q;
		imm_used_d  = imm_used_q;
		ldst_used_d = ldst_used_q;
		brh_used_d  = brh_used_q;
		bsd_ready_o = '1;
	end

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			cfg_q       <= '{default: '0};
			alu_used_q  <= '0;
			imm_used_q  <= '0;
			ldst_used_q <= '0;
			brh_used_q  <= '0;
		end else begin
			cfg_q       <= cfg_d;
			alu_used_q  <= alu_used_d;
			imm_used_q  <= imm_used_d;
			ldst_used_q <= ldst_used_d;
			brh_used_q  <= brh_used_d;
		end
	end

endmodule

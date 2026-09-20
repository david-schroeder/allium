// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_scheduler
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

	//////////////////////////
	//                      //
	// Instruction decoding //
	//                      //
	//////////////////////////

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
	} insn_group_e;


	logic [ 6:0] opcode;
	logic [ 2:0] funct3;
	logic [ 6:0] funct7;
	logic [ 4:0] rs1;
	logic [ 4:0] rs2;
	logic [ 4:0] rd;
	logic [11:0] imm12;
	logic [11:0] imm_s;

	insn_group_e insn_group;

	logic [31:0] imm_data;

	alu_op_e     alu_op;
	logic        alu_is_imm;
	logic [11:0] alu_imm;

	mem_op_e     ldst_op;
	logic [11:0] ldst_offset;

	branch_e     branch_type;

	logic is_move;
	logic is_load_zero;

	assign opcode = bsd_insn_i[6:0];
	assign funct3 = bsd_insn_i[14:12];
	assign funct7 = bsd_insn_i[31:25];
	assign rs1    = bsd_insn_i[19:15];
	assign rs2    = bsd_insn_i[24:20];
	assign rd     = bsd_insn_i[11:7];
	assign imm12  = bsd_insn_i[31:20];
	assign imm_s  = {bsd_insn_i[31:25], bsd_insn_i[11:7]};

	assign ldst_offset = insn_group == STORE ? imm_s : imm12;

	always_comb begin
		casez (opcode)
			7'b0?10111,
			7'b110?111: insn_group = IMM;
			7'b1100011: insn_group = BRANCH;
			7'b0000011: insn_group = LOAD;
			7'b0100011: insn_group = STORE;
			7'b0?10011: insn_group = ARITH;
			default   : insn_group = NOP;
		endcase

		if (insn_group inside {IMM, LOAD, ARITH}) begin
			if (rd == 5'b0) insn_group = NOP;
		end

		case (funct3)
			3'b000: alu_op = bsd_insn_i[30] && !opcode[5] ? SUB : ADD;
			3'b001: alu_op = SLL;
			3'b010: alu_op = SLT;
			3'b011: alu_op = SLTU;
			3'b100: alu_op = XOR;
			3'b101: alu_op = bsd_insn_i[30] ? SRA : SRL;
			3'b110: alu_op = OR;
			3'b111: alu_op = AND;
			default: alu_op = AND;
		endcase

		case (opcode)
			// LUI
			7'b0110111: imm_data = {bsd_insn_i[31:12], 12'b0};
			// AUIPC
			7'b0010111: imm_data = {bsd_insn_i[31:12], 12'b0} + bsd_pc_i;
			// JAL, JALR
			7'b1101111,
			7'b1100111: imm_data = bsd_pc_i + 4;
			default   : imm_data = '0;
		endcase

		case (funct3)
			3'b000: ldst_op = insn_group == STORE ? SB : LB;
			3'b001: ldst_op = insn_group == STORE ? SH : LH;
			3'b010: ldst_op = insn_group == STORE ? SW : LW;
			3'b100: ldst_op = LBU;
			3'b101: ldst_op = LHU;
			default: ldst_op = LBU;
		endcase

		case (funct3)
			3'b000: branch_type = BEQ;
			3'b001: branch_type = BNE;
			3'b100: branch_type = BLT;
			3'b101: branch_type = BGE;
			3'b110: branch_type = BLTU;
			3'b111: branch_type = BGEU;
			default: branch_type = BEQ;
		endcase
	end

	assign alu_is_imm = !opcode[5];
	assign alu_imm    = imm12;

	always_comb begin
		is_move = '0;
		is_load_zero = '0;
		if (insn_group == ARITH && alu_op == ADD) begin
			if (alu_is_imm) begin
				is_move = alu_imm == '0;
				is_load_zero = alu_imm == '0 && rs1 == '0;
			end else begin
				is_move = rs2 == '0;
				is_load_zero = rs1 == '0 && rs2 == '0;
			end
		end
	end

	///////////////////////////////
	//                           //
	// Register Allocation Table //
	//                           //
	///////////////////////////////

	// Further scheduling logic must manage
	// the zero register wrt. the RAT

	logic [LG_FUSRCS-1:0] rat [31:0];
	logic [         31:0] rat_valid;

	logic [LG_FUSRCS-1:0] rs1_allocd_src;
	logic                 rs1_allocd;
	logic [LG_FUSRCS-1:0] rs2_allocd_src;
	logic                 rs2_allocd;

	assign rs1_allocd_src = rat[rs1];
	assign rs1_allocd     = rat_valid[rs1];
	assign rs2_allocd_src = rat[rs2];
	assign rs2_allocd     = rat_valid[rs2];

	//////////////////////
	//                  //
	// Scheduling logic //
	//                  //
	//////////////////////

	// General scheduling approach:
	// - Maintain one configuration register containing
	//   instructions scheduled up to the current point (bsd_pc_i)
	// - Generate two new configurations:
	//   - The current configuration extended by necessary allocations
	//     for the new (decoded) instruction, bsd_insn_i
	//   - A new configuration containing only the new instruction
	// - Determine whether the current configuration can accomodate
	//   the decoded instruction
	// - If so, add it to the state and accept the next instruction
	// - Otherwise, emit the current configuration and schedule the
	//   next instruction into the second generated configuration

	cgra_cfg_t cfg_d, cfg_q;
	assign config_o = cfg_q;

	logic [ LG_PRESELS:0] presel_used_d , presel_used_q;
	logic [LG_POSTSELS:0] postsel_used_d, postsel_used_q;
	logic [    LG_MOVS:0] mov_used_d    , mov_used_q;
	logic [    LG_ALUS:0] alu_used_d    , alu_used_q;
	logic [    LG_IMMS:0] imm_used_d    , imm_used_q;
	logic [   LG_LDSTS:0] ldst_used_d   , ldst_used_q;
	logic [LG_BRANCHES:0] brh_used_d    , brh_used_q;

	logic postsel_is_available;
	logic mov_is_available;
	logic alu_is_available;
	logic imm_is_available;
	logic ldst_is_available;
	logic brh_is_available;

	assign postsel_is_available = postsel_used_q < N_POSTSELS;
	assign alu_is_available     = alu_used_q < N_ALUS;
	assign imm_is_available     = imm_used_q < N_IMMS;
	assign ldst_is_available    = ldst_used_q < N_LDSTS;
	assign brh_is_available     = brh_used_q < N_BRANCHES;

	always_comb begin
		cfg_d          = cfg_q;
		presel_used_q  = presel_used_d;
		postsel_used_q = postsel_used_d;
		alu_used_d     = alu_used_q;
		imm_used_d     = imm_used_q;
		ldst_used_d    = ldst_used_q;
		brh_used_d     = brh_used_q;
		bsd_ready_o    = '1;
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

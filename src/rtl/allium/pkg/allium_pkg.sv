// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

package allium_pkg;

	typedef enum logic [3:0] {
        ADD,
        SUB,
        XOR,
        AND,
        OR,
        SLT,
        SLTU,
        SLL,
        SRL,
        SRA
    } alu_op_e;

    typedef enum logic [2:0] {
        LB,
        LBU,
        LH,
        LHU,
        LW,
        SB,
        SH,
        SW
    } mem_op_e;

endpackage

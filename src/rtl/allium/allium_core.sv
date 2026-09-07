// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_core (
    input  logic clk_i,
    input  logic rst_ni,
    input  top_pkg::board2fpga_t io_i,
    output top_pkg::fpga2board_t io_o
);

    logic [31:0] pc;
    logic [31:0] insn;
    logic        valid;

    allium_block_stream_decoder bsd_dut (
        .clk_i,
        .rst_ni,

        .pc_i   ({24'h0, io_i.switch}),
        .jump_i (io_i.button[0]),
        .ready_i(1'b1),
        .pc_o   (pc),
        .insn_o (insn),
        .valid_o(valid)
    );

    always_comb begin
        io_o = '{default: '0};
        case (io_i.switch[3:0])
            4'b0000: io_o.led = pc[7:0];
            4'b0001: io_o.led = pc[15:8];
            4'b0010: io_o.led = pc[23:16];
            4'b0011: io_o.led = pc[31:24];
            4'b0100: io_o.led = insn[7:0];
            4'b0101: io_o.led = insn[15:8];
            4'b0110: io_o.led = insn[23:16];
            4'b0111: io_o.led = insn[31:24];
            default: io_o.led = {7'b0, valid};
        endcase
    end

endmodule

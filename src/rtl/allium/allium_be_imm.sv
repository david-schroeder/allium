// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_be_imm
	import allium_pkg::*;
(
	input  logic clk_i,
	input  logic rst_ni,

	input  logic        cfg_update_i,
	input  logic [31:0] cfg_data_i,

	output logic        valid_o,
	output logic [31:0] data_o
);

	always_ff @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
			valid_o <= '0;
			data_o <= '0;
		end else begin
			if (cfg_update_i) begin
				data_o <= cfg_data_i;
				valid_o <= '1;
			end
		end
	end

endmodule

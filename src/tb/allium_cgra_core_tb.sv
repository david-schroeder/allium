// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

module allium_cgra_core_tb;

    import allium_pkg::*;

    logic clk, rstn;

    always begin
        clk <= '1;
        #5000;
        clk <= '0;
        #5000;
    end

    logic [31:0] regfile [31:0];

    logic        cfg_update;
    logic [31:0] cfg_imm_data;
    logic [ 5:0] cfg_alu_srca;
    logic [ 5:0] cfg_alu_srcb;
    logic [ 5:0] cfg_ldst_srca;
    logic [ 5:0] cfg_ldst_srcb;
    alu_op_e     cfg_alu_op;
    mem_op_e     cfg_ldst_op;
    logic [11:0] cfg_ldst_offs;
    logic [ 5:0] cfg_reg_srcs [31:0];

    logic [31:0] reg_out [31:0];

    logic        cgra_done;

    allium_cgra_core DUT (
        .clk_i          (clk),
        .rst_ni         (rstn),

        .cfg_update_i   (cfg_update),
        .cfg_imm_data_i (cfg_imm_data),
        .cfg_alu_srca_i (cfg_alu_srca),
        .cfg_alu_srcb_i (cfg_alu_srcb),
        .cfg_ldst_srca_i(cfg_ldst_srca),
        .cfg_ldst_srcb_i(cfg_ldst_srcb),
        .cfg_alu_op_i   (cfg_alu_op),
        .cfg_ldst_op_i  (cfg_ldst_op),
        .cfg_ldst_offs_i(cfg_ldst_offs),

        .regs_i         (regfile),
        .regsrc_i       (cfg_reg_srcs),
        .regs_o         (reg_out),
        .global_valid_o (cgra_done)
    );

    task update_arch_regfile();
        for (int i = 0; i < 32; i++) begin
            regfile[i] <= reg_out[i];
        end
    endtask

    initial begin
        rstn <= '0;

        cfg_update    <= '0;
        cfg_imm_data  <= '0;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_reg_srcs  <= '{default: '0};

        @(posedge clk);
        @(posedge clk);
        rstn <= '1;
        @(posedge clk);

        // Init RF to zero
        update_arch_regfile();

        cfg_update      <= '1;
        cfg_imm_data    <= 32'h00000080;
        cfg_alu_srca    <= 6'd34;
        cfg_alu_srcb    <= 6'd34;
        cfg_ldst_srca   <= 6'd32;
        cfg_ldst_srcb   <= '0;
        cfg_alu_op      <= ADD;
        cfg_ldst_op     <= LW;
        cfg_ldst_offs   <= 12'h004;
        cfg_reg_srcs    <= '{default: '0};
        cfg_reg_srcs[4] <= 6'd32;
        cfg_reg_srcs[7] <= 6'd33;

        @(posedge clk);
        cfg_update <= '0;
        @(posedge clk);

        for (int i = 0; i < 100; i++) @(posedge clk);

        $finish;
    end

endmodule

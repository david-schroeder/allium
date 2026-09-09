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
    alu_op_e     cfg_alu_op;
    logic [ 5:0] cfg_ldst_srca;
    logic [ 5:0] cfg_ldst_srcb;
    mem_op_e     cfg_ldst_op;
    logic [11:0] cfg_ldst_offs;
    branch_e     cfg_branch;
    logic [ 5:0] cfg_brh_srca;
    logic [ 5:0] cfg_brh_srcb;
    logic [ 5:0] cfg_reg_srcs [31:0];

    logic [31:0] reg_out [31:0];

    logic        cgra_done;
    logic        cgra_branch;

    allium_cgra_core DUT (
        .clk_i          (clk),
        .rst_ni         (rstn),

        .cfg_update_i   (cfg_update),
        .cfg_imm_data_i (cfg_imm_data),
        .cfg_alu_srca_i (cfg_alu_srca),
        .cfg_alu_srcb_i (cfg_alu_srcb),
        .cfg_alu_op_i   (cfg_alu_op),
        .cfg_ldst_srca_i(cfg_ldst_srca),
        .cfg_ldst_srcb_i(cfg_ldst_srcb),
        .cfg_ldst_op_i  (cfg_ldst_op),
        .cfg_ldst_offs_i(cfg_ldst_offs),
        .cfg_branch_i   (cfg_branch),
        .cfg_brh_srca_i (cfg_brh_srca),
        .cfg_brh_srcb_i (cfg_brh_srcb),

        .regs_i         (regfile),
        .regsrc_i       (cfg_reg_srcs),
        .regs_o         (reg_out),
        .global_valid_o (cgra_done),
        .take_branch_o  (cgra_branch)
    );

    task update_arch_regfile();
        for (int i = 0; i < 32; i++) begin
            regfile[i] <= reg_out[i];
        end
        #1;
    endtask

    task init_rat();
        for (int i = 0; i < 32; i++) begin
            cfg_reg_srcs[i] <= 6'(i);
        end
        #1;
    endtask

    task cgra_run_configuration();
        cfg_update <= '1;
        @(posedge clk);
        cfg_update <= '0;
        update_arch_regfile();
        while (!cgra_done) begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        rstn <= '0;

        cfg_update    <= '0;
        cfg_imm_data  <= '0;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        cfg_reg_srcs  <= '{default: '0};

        @(posedge clk);
        @(posedge clk);
        rstn <= '1;
        @(posedge clk);


        /* Config template:
        cfg_imm_data  <= '0;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        init_rat();

        cfg_reg_srcs[...] <= ...;
        */

        // Init regs to zero
        update_arch_regfile();


        /*
            li t0, BASE
        */
        cfg_imm_data  <= 32'h00000010;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        init_rat();
        cfg_reg_srcs[T0_SRC] <= IMM_SRC;
        cgra_run_configuration();

        /*
            li t1, N
        */
        cfg_imm_data  <= 32'd10;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        init_rat();
        cfg_reg_srcs[T1_SRC] <= IMM_SRC;
        cfg_reg_srcs[T2_SRC] <= ZERO_SRC;
        cgra_run_configuration();

        /*
            li t2, 0
            li t3, 1
            beqz t1, done
        */
        cfg_imm_data  <= 32'd1;
        cfg_alu_srca  <= '0;
        cfg_alu_srcb  <= '0;
        cfg_alu_op    <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= T1_SRC;
        cfg_brh_srcb  <= ZERO_SRC;
        init_rat();
        cfg_reg_srcs[T3_SRC] <= IMM_SRC;
        cgra_run_configuration();

        if (cgra_branch) begin
            $display("First beqz should not be taken!");
        end

        while (!cgra_branch) begin

            /*
                sw  t2, 0(t0)
                add t4, t2, t3
                mv  t2, t3
                mv  t3, t4
            */
            cfg_imm_data  <= '0;
            cfg_alu_srca  <= T2_SRC;
            cfg_alu_srcb  <= T3_SRC;
            cfg_alu_op    <= ADD;
            cfg_ldst_srca <= T0_SRC;
            cfg_ldst_srcb <= T2_SRC;
            cfg_ldst_op   <= SW;
            cfg_ldst_offs <= '0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= T1_SRC;
            cfg_brh_srcb  <= ZERO_SRC;
            init_rat();
            cfg_reg_srcs[T4_SRC] <= ALU_SRC;
            cfg_reg_srcs[T2_SRC] <= T3_SRC;
            cfg_reg_srcs[T3_SRC] <= ALU_SRC;
            cgra_run_configuration();

            /*
                addi t0, t0, -4
            */
            cfg_imm_data  <= 32'd4;
            cfg_alu_srca  <= T0_SRC;
            cfg_alu_srcb  <= IMM_SRC;
            cfg_alu_op    <= ADD;
            cfg_ldst_srca <= '0;
            cfg_ldst_srcb <= '0;
            cfg_ldst_op   <= LB;
            cfg_ldst_offs <= '0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= '0;
            cfg_brh_srcb  <= '0;
            init_rat();
            cfg_reg_srcs[T0_SRC] <= ALU_SRC;
            cgra_run_configuration();

            /*
                addi t1, t1, -1
                j loop

              .loop:
                beqz t1, done
            */
            cfg_imm_data  <= -32'd1;
            cfg_alu_srca  <= T1_SRC;
            cfg_alu_srcb  <= IMM_SRC;
            cfg_alu_op    <= ADD;
            cfg_ldst_srca <= '0;
            cfg_ldst_srcb <= '0;
            cfg_ldst_op   <= LB;
            cfg_ldst_offs <= '0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= ALU_SRC;
            cfg_brh_srcb  <= ZERO_SRC;
            init_rat();
            cfg_reg_srcs[T1_SRC] <= ALU_SRC;
            cgra_run_configuration();

        end

        for (int i = 0; i < 10; i++) @(posedge clk);

        $finish;
    end

endmodule

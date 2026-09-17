// SPDX-License-Identifier: SHL-2.1
// SPDX-FileCopyrightText: David Schröder 2026

/*

    Testbench for Allium backend CGRA.

    Runs the following RISC-V fibonacci program:

        li t0, BASE
        li t1, N
        li t2, 0
        li t3, 1
    .loop:
        beqz t1, done
        sw  t2, 0(t0)
        add t4, t2, t3
        mv  t2, t3
        mv  t3, t4
        addi t0, t0, 4
        addi t1, t1, -1
        j loop
    .done:
        j done # (end)

*/

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
    logic [31:0] cfg_imm0_data;
    logic [31:0] cfg_imm1_data;
    logic [ 1:0] cfg_move0_src;
    logic [ 1:0] cfg_move1_src;
    logic [ 5:0] cfg_alu0_srca;
    logic [ 5:0] cfg_alu0_srcb;
    alu_op_e     cfg_alu0_op;
    logic [ 5:0] cfg_alu1_srca;
    logic [ 5:0] cfg_alu1_srcb;
    alu_op_e     cfg_alu1_op;
    logic [ 5:0] cfg_ldst_srca;
    logic [ 5:0] cfg_ldst_srcb;
    mem_op_e     cfg_ldst_op;
    logic [11:0] cfg_ldst_offs;
    branch_e     cfg_branch;
    logic [ 5:0] cfg_brh_srca;
    logic [ 5:0] cfg_brh_srcb;
    logic [ 4:0] cfg_presel  [3:0];
    postselect_t cfg_postsel [1:0];

    logic [31:0] reg_out [31:0];
    logic [31:0] regce_out;

    logic        cgra_done;
    logic        cgra_branch;

    allium_cgra_core DUT (
        .clk_i          (clk),
        .rst_ni         (rstn),

        .cfg_update_i   (cfg_update),
        .cfg_imm0_data_i(cfg_imm0_data),
        .cfg_imm1_data_i(cfg_imm1_data),
        .cfg_move0_src_i(cfg_move0_src),
        .cfg_move1_src_i(cfg_move1_src),
        .cfg_alu0_srca_i(cfg_alu0_srca),
        .cfg_alu0_srcb_i(cfg_alu0_srcb),
        .cfg_alu0_op_i  (cfg_alu0_op),
        .cfg_alu1_srca_i(cfg_alu1_srca),
        .cfg_alu1_srcb_i(cfg_alu1_srcb),
        .cfg_alu1_op_i  (cfg_alu1_op),
        .cfg_ldst_srca_i(cfg_ldst_srca),
        .cfg_ldst_srcb_i(cfg_ldst_srcb),
        .cfg_ldst_op_i  (cfg_ldst_op),
        .cfg_ldst_offs_i(cfg_ldst_offs),
        .cfg_branch_i   (cfg_branch),
        .cfg_brh_srca_i (cfg_brh_srca),
        .cfg_brh_srcb_i (cfg_brh_srcb),

        .regs_i         (regfile),
        .presel_i       (cfg_presel),
        .postsel_i      (cfg_postsel),
        .regs_o         (reg_out),
        .regce_o        (regce_out),
        .global_valid_o (cgra_done),
        .take_branch_o  (cgra_branch)
    );

    task update_arch_regfile();
        for (int i = 0; i < 32; i++) begin
            if (regce_out[i]) regfile[i] <= reg_out[i];
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
        cfg_imm0_data <= '0;
        cfg_imm1_data <= '0;
        cfg_move0_src <= '0;
        cfg_move1_src <= '0;
        cfg_alu0_srca <= '0;
        cfg_alu0_srcb <= '0;
        cfg_alu0_op   <= ADD;
        cfg_alu1_srca <= '0;
        cfg_alu1_srcb <= '0;
        cfg_alu1_op   <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        cfg_presel    <= '{default: '0};
        cfg_postsel   <= '{default: '{src: '0, dest: '0}};

        @(posedge clk);
        @(posedge clk);
        rstn <= '1;
        @(posedge clk);

        /*
            li t0, BASE
            li t1, N
        */
        cfg_imm0_data <= 32'h00000010;
        cfg_imm1_data <= 32'd10;
        cfg_move0_src <= '0;
        cfg_move1_src <= '0;
        cfg_alu0_srca <= '0;
        cfg_alu0_srcb <= '0;
        cfg_alu0_op   <= ADD;
        cfg_alu1_srca <= '0;
        cfg_alu1_srcb <= '0;
        cfg_alu1_op   <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= '0;
        cfg_brh_srcb  <= '0;
        cfg_presel    <= '{default: '0};
        cfg_postsel   <= '{
            '{src: RS_IMM0, dest: R_T0},
            '{src: RS_IMM1, dest: R_T1}
        };
        cgra_run_configuration();

        /*
            li t2, 0
            li t3, 1
            beqz t1, done
        */
        cfg_imm0_data <= 32'd1;
        cfg_imm1_data <= '0;
        cfg_move0_src <= '0;
        cfg_move1_src <= '0;
        cfg_alu0_srca <= '0;
        cfg_alu0_srcb <= '0;
        cfg_alu0_op   <= ADD;
        cfg_alu1_srca <= '0;
        cfg_alu1_srcb <= '0;
        cfg_alu1_op   <= ADD;
        cfg_ldst_srca <= '0;
        cfg_ldst_srcb <= '0;
        cfg_ldst_op   <= LB;
        cfg_ldst_offs <= '0;
        cfg_branch    <= BEQ;
        cfg_brh_srca  <= FS_PRE0;
        cfg_brh_srcb  <= FS_ZERO;
        cfg_presel    <= '{
            0: R_T1,
            1: R_ZERO,
            2: R_ZERO,
            3: R_ZERO
        };
        cfg_postsel   <= '{
            '{src: RS_ZERO, dest: R_T2},
            '{src: RS_IMM0, dest: R_T3}
        };
        cgra_run_configuration();

        if (cgra_branch) begin
            $display("First beqz should not be taken!");
        end

        while (!cgra_branch) begin
            /*
                sw  t2, 0(t0)
                add t4, t2, t3
                mv  t2, t3
            */
            cfg_imm0_data <= 32'd1;
            cfg_imm1_data <= '0;
            cfg_move0_src <= MOV_PRE2;
            cfg_move1_src <= '0;
            cfg_alu0_srca <= FS_PRE1;
            cfg_alu0_srcb <= FS_PRE2;
            cfg_alu0_op   <= ADD;
            cfg_alu1_srca <= '0;
            cfg_alu1_srcb <= '0;
            cfg_alu1_op   <= ADD;
            cfg_ldst_srca <= FS_PRE0;
            cfg_ldst_srcb <= FS_PRE1;
            cfg_ldst_op   <= SW;
            cfg_ldst_offs <= 12'h0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= '0;
            cfg_brh_srcb  <= '0;
            cfg_presel    <= '{
                0: R_T0,
                1: R_T2,
                2: R_T3,
                3: R_ZERO
            };
            cfg_postsel   <= '{
                '{src: RS_ALU0, dest: R_T4},
                '{src: RS_MOV0, dest: R_T2}
            };
            cgra_run_configuration();

            /*
                mv  t3, t4
                addi t0, t0, 4
            */
            cfg_imm0_data <= 32'd4;
            cfg_imm1_data <= '0;
            cfg_move0_src <= MOV_PRE0;
            cfg_move1_src <= '0;
            cfg_alu0_srca <= FS_PRE1;
            cfg_alu0_srcb <= FS_IMM0;
            cfg_alu0_op   <= ADD;
            cfg_alu1_srca <= '0;
            cfg_alu1_srcb <= '0;
            cfg_alu1_op   <= ADD;
            cfg_ldst_srca <= '0;
            cfg_ldst_srcb <= '0;
            cfg_ldst_op   <= LB;
            cfg_ldst_offs <= '0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= '0;
            cfg_brh_srcb  <= '0;
            cfg_presel    <= '{
                0: R_T4,
                1: R_T0,
                2: R_ZERO,
                3: R_ZERO
            };
            cfg_postsel   <= '{
                '{src: RS_MOV0, dest: R_T3},
                '{src: RS_ALU0, dest: R_T0}
            };
            cgra_run_configuration();

            /*
                addi t1, t1, -1
                j loop
            .loop:
                beqz t1, done
            */
            cfg_imm0_data <= -32'd1;
            cfg_imm1_data <= '0;
            cfg_move0_src <= '0;
            cfg_move1_src <= '0;
            cfg_alu0_srca <= FS_PRE0;
            cfg_alu0_srcb <= FS_IMM0;
            cfg_alu0_op   <= ADD;
            cfg_alu1_srca <= '0;
            cfg_alu1_srcb <= '0;
            cfg_alu1_op   <= ADD;
            cfg_ldst_srca <= '0;
            cfg_ldst_srcb <= '0;
            cfg_ldst_op   <= LB;
            cfg_ldst_offs <= '0;
            cfg_branch    <= BEQ;
            cfg_brh_srca  <= FS_ALU0;
            cfg_brh_srcb  <= FS_ZERO;
            cfg_presel    <= '{
                0: R_T1,
                1: R_ZERO,
                2: R_ZERO,
                3: R_ZERO
            };
            cfg_postsel   <= '{
                '{src: RS_ALU0, dest: R_T1},
                '{src: '0, dest: '0}
            };
            cgra_run_configuration();
        end

        for (int i = 0; i < 10; i++) @(posedge clk);

        $finish;
    end

endmodule

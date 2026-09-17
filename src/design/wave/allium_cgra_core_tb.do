onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Toplevel
add wave -noupdate -label Clock /allium_cgra_core_tb/clk
add wave -noupdate -label {Reconfigure Backend} /allium_cgra_core_tb/cfg_update
add wave -noupdate -label {Backend finished} /allium_cgra_core_tb/cgra_done
add wave -noupdate -label {Backend branch taken} /allium_cgra_core_tb/cgra_branch
add wave -noupdate -label {Data Mem} /allium_cgra_core_tb/DUT/fu_ldst_i/dmem
add wave -noupdate -group {ALU0 CFG} /allium_cgra_core_tb/cfg_alu0_op
add wave -noupdate -group {ALU0 CFG} /allium_cgra_core_tb/cfg_alu0_srca
add wave -noupdate -group {ALU0 CFG} /allium_cgra_core_tb/cfg_alu0_srcb
add wave -noupdate -group {ALU1 CFG} /allium_cgra_core_tb/cfg_alu1_op
add wave -noupdate -group {ALU1 CFG} /allium_cgra_core_tb/cfg_alu1_srca
add wave -noupdate -group {ALU1 CFG} /allium_cgra_core_tb/cfg_alu1_srcb
add wave -noupdate -group {Branch CFG} /allium_cgra_core_tb/cfg_branch
add wave -noupdate -group {Branch CFG} /allium_cgra_core_tb/cfg_brh_srca
add wave -noupdate -group {Branch CFG} /allium_cgra_core_tb/cfg_brh_srcb
add wave -noupdate -group {Immediates CFG} /allium_cgra_core_tb/cfg_imm0_data
add wave -noupdate -group {Immediates CFG} /allium_cgra_core_tb/cfg_imm1_data
add wave -noupdate -group {LD/ST CFG} /allium_cgra_core_tb/cfg_ldst_offs
add wave -noupdate -group {LD/ST CFG} /allium_cgra_core_tb/cfg_ldst_op
add wave -noupdate -group {LD/ST CFG} /allium_cgra_core_tb/cfg_ldst_srca
add wave -noupdate -group {LD/ST CFG} /allium_cgra_core_tb/cfg_ldst_srcb
add wave -noupdate -group {Moves CFG} /allium_cgra_core_tb/cfg_move0_src
add wave -noupdate -group {Moves CFG} /allium_cgra_core_tb/cfg_move1_src
add wave -noupdate -expand -group {Reg selection} /allium_cgra_core_tb/cfg_postsel
add wave -noupdate -expand -group {Reg selection} /allium_cgra_core_tb/cfg_presel
add wave -noupdate -group Regfile -expand /allium_cgra_core_tb/reg_out
add wave -noupdate -group Regfile /allium_cgra_core_tb/regce_out
add wave -noupdate -group Regfile /allium_cgra_core_tb/regfile
add wave -noupdate -divider {CGRA Core}
add wave -noupdate -label Clock /allium_cgra_core_tb/DUT/clk_i
add wave -noupdate -label Reset /allium_cgra_core_tb/DUT/rst_ni
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_a_data
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_a_valid
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_b_data
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_b_valid
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_data
add wave -noupdate -group ALU0 /allium_cgra_core_tb/DUT/alu0_valid
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_a_data
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_a_valid
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_b_data
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_b_valid
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_data
add wave -noupdate -group ALU1 /allium_cgra_core_tb/DUT/alu1_valid
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/branch_taken
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/brh_a_data
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/brh_a_valid
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/brh_b_data
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/brh_b_valid
add wave -noupdate -group {Branch Unit} /allium_cgra_core_tb/DUT/brh_valid
add wave -noupdate -group Immediates /allium_cgra_core_tb/DUT/imm0_data
add wave -noupdate -group Immediates /allium_cgra_core_tb/DUT/imm0_valid
add wave -noupdate -group Immediates /allium_cgra_core_tb/DUT/imm1_data
add wave -noupdate -group Immediates /allium_cgra_core_tb/DUT/imm1_valid
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_a_data
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_a_valid
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_b_data
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_b_valid
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_data
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_is_store
add wave -noupdate -group LD/ST /allium_cgra_core_tb/DUT/ldst_valid
add wave -noupdate -divider IN
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_a_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_a_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_b_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_b_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_data_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_data_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu0_valid_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_a_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_a_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_b_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_b_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_data_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_data_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/alu1_valid_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/brh_a_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/brh_a_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/brh_b_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/brh_b_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/brh_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu0_srca_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu0_srca_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu0_srcb_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu0_srcb_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu1_srca_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu1_srca_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu1_srcb_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_alu1_srcb_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_brh_srca_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_brh_srca_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_brh_srcb_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_brh_srcb_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_ldst_srca_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_ldst_srca_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_ldst_srcb_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_ldst_srcb_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_move0_src_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_move0_src_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_move1_src_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_move1_src_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/cfg_update_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/clk_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/global_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/imm0_data_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/imm0_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/imm1_data_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/imm1_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_a_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_a_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_b_data_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_b_valid_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_data_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_data_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_is_store_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_valid_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/ldst_valid_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/move0_data
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/move1_data
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/postsel_data
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/postsel_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/postsel_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/postsel_valid
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/presel_data
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/presel_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/presel_q
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/regce_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/regs_i
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/regs_o
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/rst_ni
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/sources_fu
add wave -noupdate /allium_cgra_core_tb/DUT/interconnect_i/sources_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34648860 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 315
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {612772411 fs} {615402203 fs}

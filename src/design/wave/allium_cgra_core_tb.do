onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Toplevel
add wave -noupdate /allium_cgra_core_tb/clk
add wave -noupdate /allium_cgra_core_tb/rstn
add wave -noupdate /allium_cgra_core_tb/regfile
add wave -noupdate /allium_cgra_core_tb/cfg_update
add wave -noupdate /allium_cgra_core_tb/cfg_imm_data
add wave -noupdate /allium_cgra_core_tb/cfg_alu_srca
add wave -noupdate /allium_cgra_core_tb/cfg_alu_srcb
add wave -noupdate /allium_cgra_core_tb/cfg_ldst_srca
add wave -noupdate /allium_cgra_core_tb/cfg_ldst_srcb
add wave -noupdate /allium_cgra_core_tb/cfg_alu_op
add wave -noupdate /allium_cgra_core_tb/cfg_ldst_op
add wave -noupdate /allium_cgra_core_tb/cfg_ldst_offs
add wave -noupdate /allium_cgra_core_tb/cfg_reg_srcs
add wave -noupdate /allium_cgra_core_tb/reg_out
add wave -noupdate /allium_cgra_core_tb/cgra_done
add wave -noupdate -divider {CGRA Core}
add wave -noupdate /allium_cgra_core_tb/DUT/alu_a_valid
add wave -noupdate /allium_cgra_core_tb/DUT/alu_b_valid
add wave -noupdate /allium_cgra_core_tb/DUT/alu_a_data
add wave -noupdate /allium_cgra_core_tb/DUT/alu_b_data
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_a_valid
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_b_valid
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_a_data
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_b_data
add wave -noupdate /allium_cgra_core_tb/DUT/imm_valid
add wave -noupdate /allium_cgra_core_tb/DUT/imm_data
add wave -noupdate /allium_cgra_core_tb/DUT/alu_valid
add wave -noupdate /allium_cgra_core_tb/DUT/alu_data
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_valid
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_data
add wave -noupdate /allium_cgra_core_tb/DUT/ldst_is_store
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 212
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
WaveRestoreZoom {0 fs} {165 fs}

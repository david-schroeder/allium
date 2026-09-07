onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/BOOT_ADDR
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/branch_backwards
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/branch_offset
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/clk_i
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/first_cycle_q
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/imem
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/insn
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/insn_o
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/is_branch
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/is_jal
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/is_jalr
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/jal_offset
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/jump_i
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/pc_d
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/pc_i
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/pc_o
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/pc_q
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/ready_i
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/rst_ni
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/valid_d
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/valid_o
add wave -noupdate /system_tb/board_i/DUT/core_i/bsd_dut/valid_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 fs} {254 fs}

vlib work
vdel -all
vlib work

vlog instructioncache.sv 
vlog DataCache.sv
vlog tb.sv

vsim work.top
#add wave -r *
#add wave sim:/tb/DUT/cacheL1
#add wave sim:/tb/DUT/tag

run -all
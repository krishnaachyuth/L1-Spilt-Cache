vlib work
vdel -all
vlib work

vlog instructioncache.sv 
vlog dataCache.sv
vlog testbench.sv

vsim work.top

run -all
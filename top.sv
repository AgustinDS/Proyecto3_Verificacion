//`timescale 1ns / 1ps

`include "uvm_macros.svh"

`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "sequence_item.sv"
`include "sequences.sv"
`include "monitor.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

module top_testbench;

	import uvm_pkg::*;

	reg clk;

  	always #10 clk =~ clk;
  	dut_if _if(clk);
	
	top dut0(
  	.clk (clk),
  	.r_mode(_if.r_mode),
  	.fp_X(_if.fp_X), .fp_Y(_if.fp_Y),
  	.fp_Z(_if.fp_Z),
  	.ovrf(_if.ovrf), .udrf(_if.udrf));


	initial begin
		clk <= 0;

		`uvm_info("TOP", "Test start", UVM_LOW);

		uvm_config_db#(virtual dut_if)::set(null,"uvm_test_top","des_vif",_if);

		run_test();
	end
	
endmodule
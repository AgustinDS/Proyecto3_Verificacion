//`timescale 1ns / 1ps

`include "uvm_macros.svh"

`include "multiplicador_32_bits_FP_IEEE.sv"
`include "sequence_item.sv"
`include "sequences.sv"

module top_testbench;

	import uvm_pkg::*;

	initial begin
		`uvm_info("TOP", "Test start", UVM_LOW)
	end
	
endmodule
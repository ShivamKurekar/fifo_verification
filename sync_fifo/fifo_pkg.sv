`include "uvm_macros.svh"
`include "fifo_seq_pkg.sv"

package fifo_pkg;
	
	import uvm_pkg::*;
	import fifo_seq_pkg::*;

	`include "fifo_driver.sv"
	`include "fifo_monitor.sv"
	`include "fifo_sequencer.sv"
	`include "fifo_scoreboard.sv"
	`include "fifo_agent.sv"
	`include "fifo_coverage.sv"
	`include "fifo_env.sv"
	`include "fifo_test.sv"

endpackage
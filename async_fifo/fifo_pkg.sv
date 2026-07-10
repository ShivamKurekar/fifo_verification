package fifo_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "params.svh"

`include "wr_txn.sv"
`include "rd_txn.sv"

`include "wr_seq.sv"

`include "wr_driver.sv"

`include "wr_monitor.sv"

`include "wr_agent.sv"

`include "fifo_env.sv"
`include "fifo_test.sv"

endpackage
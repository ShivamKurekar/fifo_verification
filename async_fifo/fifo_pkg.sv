package fifo_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "params.svh"

`include "wr_txn.sv"
`include "rd_txn.sv"

`include "wr_seq.sv"
`include "rd_seq.sv"

`include "wr_driver.sv"
`include "rd_driver.sv"

`include "wr_monitor.sv"
`include "rd_monitor.sv"

`include "wr_agent.sv"
`include "rd_agent.sv"

`include "fifo_scb.sv"
`include "fifo_cov.sv"

`include "fifo_env.sv"
`include "fifo_test.sv"
`include "fifo_rand_test.sv"

endpackage
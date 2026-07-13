`include "fifo_wr_if.sv"
`include "fifo_rd_if.sv"
`include "fifo_pkg.sv"
`include "params.svh"

module tb;
  
import uvm_pkg::*;
import fifo_pkg::*;

`include "uvm_macros.svh"

bit wr_clk, wr_rstn;
bit rd_clk, rd_rstn;

always #5 wr_clk = ~wr_clk;
always #10 rd_clk = ~rd_clk;

initial begin
  rd_clk = 0;
  wr_clk = 0;
end
  
initial begin
  wr_rstn = 0;
  rd_rstn = 0;
  repeat (5) @(posedge rd_clk); // sync wrt to slow clk
  wr_rstn = 1;
  rd_rstn = 1;
end
  
fifo_wr_if wr_if(wr_clk, wr_rstn);
fifo_rd_if rd_if(rd_clk, rd_rstn);

async_fifo #(.DEPTH(`DEPTH),
             .DATA_WIDTH (`DATA_WIDTH))
afifo (
   .i_wr_clk(wr_clk),
   .i_wr_rstn(wr_rstn),
   .i_wr_en(wr_if.wr_en),
   .i_wr_data(wr_if.wr_data),
   .o_full(wr_if.full),

   .i_rd_clk(rd_clk),
   .i_rd_rstn(rd_rstn),
   .i_rd_en(rd_if.rd_en),
   .o_rd_data(rd_if.rd_data),
   .o_empty(rd_if.empty)
);

initial begin
  $display("================> Initiating FIFO TXN <================");
    
  uvm_config_db #(virtual fifo_wr_if.DRIVER)::set(null, "*", "wr_drv", wr_if);
  uvm_config_db #(virtual fifo_wr_if.MONITOR)::set(null, "*", "wr_mon", wr_if);

  uvm_config_db #(virtual fifo_rd_if.DRIVER)::set(null, "*", "rd_drv", rd_if);
  uvm_config_db #(virtual fifo_rd_if.MONITOR)::set(null, "*", "rd_mon", rd_if);
    
  run_test("fifo_test");
end

initial begin
  #(5_000_000);
  $fatal(1, "GLOBAL TIMEOUT: simulation exceeded 5 ms.");
end
  
initial begin
  $dumpfile("dumpfile.vcd");
  $dumpvars;
end

endmodule
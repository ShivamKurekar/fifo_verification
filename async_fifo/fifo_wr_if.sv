`include "params.svh"

interface fifo_wr_if #(parameter DATA_WIDTH = `DATA_WIDTH) (
  input logic wr_clk, wr_rstn
);
  
  logic [DATA_WIDTH - 1: 0] wr_data;
  logic						wr_en;
  logic 					full;
  
  clocking wr_cb @ (posedge wr_clk);
    output wr_en, wr_data;
    input full;
  endclocking
  
  modport DRIVER (clocking wr_cb, input wr_clk, wr_rstn);
  modport MONITOR (input wr_en, wr_data, full, wr_clk, wr_rstn);
    
endinterface
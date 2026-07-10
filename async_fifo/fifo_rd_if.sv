`include "params.svh"

interface fifo_rd_if #(parameter DATA_WIDTH = `DATA_WIDTH) (
  input logic rd_clk, rd_rstn
);

  logic                  rd_en;
  logic [DATA_WIDTH-1:0] rd_data;
  logic                  empty;

  clocking rd_cb @(posedge rd_clk);
    output rd_en;
    input  rd_data, empty;
  endclocking

  modport DRIVER (clocking rd_cb, input rd_clk, rd_rstn);
  modport MONITOR (input rd_en, rd_data, empty, rd_clk, rd_rstn);

endinterface
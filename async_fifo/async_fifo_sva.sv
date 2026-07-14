module async_fifo_blackbox_sva #(
    parameter DEPTH       = 8,
    parameter DATA_WIDTH  = 4
) (
    input                       i_wr_clk,
    input                       i_wr_rstn,
    input                       i_wr_en,
    input [DATA_WIDTH-1:0]      i_wr_data,
    input                       o_full,
 
    input                       i_rd_clk,
    input                       i_rd_rstn,
    input                       i_rd_en,
    input [DATA_WIDTH-1:0]      o_rd_data,
    input                       o_empty
);

// Check full/empty mutual exclusion.
a_full_empty_mutex_wr: assert property (
  @(posedge i_wr_clk) disable iff (!i_wr_rstn) !(o_full && o_empty)
) else $error("o_full and o_empty asserted simultaneously (wr domain sample)");

a_full_empty_mutex_rd: assert property (
  @(posedge i_rd_clk) disable iff (!i_rd_rstn) !(o_full && o_empty)
) else $error("o_full and o_empty asserted simultaneously (rd domain sample)");

// Check reset state.
a_empty_after_reset: assert property (
  @(posedge i_rd_clk) $rose(i_rd_rstn) |-> o_empty
) else $error("o_empty not asserted immediately after i_rd_rstn deassertion");

a_not_full_after_reset: assert property (
  @(posedge i_wr_clk) $rose(i_wr_rstn) |-> !o_full
) else $error("o_full asserted immediately after i_wr_rstn deassertion");

// Check outputs for X/Z.
a_no_x_on_full: assert property (
  @(posedge i_wr_clk) disable iff (!i_wr_rstn) !$isunknown(o_full)
) else $error("o_full went to X/Z");

a_no_x_on_empty: assert property (
  @(posedge i_rd_clk) disable iff (!i_rd_rstn) !$isunknown(o_empty)
) else $error("o_empty went to X/Z");

a_no_x_on_rd_data: assert property (
  @(posedge i_rd_clk) disable iff (!i_rd_rstn)
  (!o_empty |-> !$isunknown(o_rd_data))
) else $error("o_rd_data went to X/Z while o_empty was low");

// Check write clears empty.
a_write_eventually_seen_not_empty: assert property (
  @(posedge i_wr_clk) disable iff (!i_wr_rstn)
  (i_wr_en && !o_full) |-> ##[1:20] !o_empty
) else $error("write accepted but o_empty never deasserted within bound");

// Check read clears full.
a_full_eventually_clears: assert property (
  @(posedge i_wr_clk) disable iff (!i_wr_rstn)
  $rose(o_full) |-> ##[1:40] !o_full
) else $error("o_full stayed asserted for over 40 wr_clk cycles without clearing");
endmodule

// Bind assertions to DUT.
bind async_fifo
  async_fifo_blackbox_sva #(.DEPTH(DEPTH), .DATA_WIDTH(DATA_WIDTH))
  u_async_fifo_blackbox_sva (.*);
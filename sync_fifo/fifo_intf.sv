`include "uvm_macros.svh"

interface fifo_intf (
  input logic clk
);

  logic reset;
  logic [`DATA_WIDTH-1:0] din;
  logic read;
  logic write;

  logic [`DATA_WIDTH-1:0] dout;
  logic empty;
  logic full;
  logic ale;
  logic alf;

  // clocking block
  clocking cb @(posedge clk);
    default input #1step output #2ps;

    output reset, din, read, write;
    input  dout, empty, full, ale, alf;
  endclocking

  // ASSERTIONS
  ASSERT_RESET : assert property (
    @(posedge clk)
    disable iff ($isunknown(reset))
    !reset |-> ##1(empty && !full)
  )
  else
    `uvm_error("FIFO_ASSERT",
               "Reset failed: FIFO should be EMPTY and not FULL")

  ASSERT_FULL_EMPTY : assert property (
    @(posedge clk)
    disable iff(!reset || $isunknown({full,empty}))
    !(full && empty)
  )
  else
    `uvm_error("FIFO_ASSERT",
               "FIFO cannot be FULL and EMPTY simultaneously")

  ASSERT_ALF_EMPTY : assert property (
    @(posedge clk)
    disable iff(!reset || $isunknown({alf,empty}))
    !(alf && empty)
  )
  else
    `uvm_error("FIFO_ASSERT",
               "ALF asserted while FIFO is EMPTY")

  ASSERT_ALE_FULL : assert property (
    @(posedge clk)
    disable iff(!reset || $isunknown({full,ale}))
    !(ale && full)
  )
  else
    `uvm_error("FIFO_ASSERT",
               "ALE asserted while FIFO is FULL")

  COV_FULL  : cover property (
    @(posedge clk)
    full
  );

  COV_EMPTY : cover property (
    @(posedge clk)
    empty
  );

  COV_ALF : cover property (
    @(posedge clk)
    alf
  );

  COV_ALE : cover property (
    @(posedge clk)
    ale
  );

  COV_RW : cover property (
    @(posedge clk)
    read && write
  );

endinterface
`include "parameters.svh"
`include "fifo_intf.sv"
`include "fifo_pkg.sv"

module tb_top;
	
  import uvm_pkg::*;
  import fifo_pkg::*;
  
  bit clk;
  
  initial begin
  	clk = 0;
    $display("-----------> Initiating Testbench <-----------");
//     #1000;
//     $finish;
  end
  
  always #10 clk = ~clk;
  
  // interface instance
  fifo_intf intf (clk);
  
  // sync fifo instance
  sync_fifo  #(.DATA_WIDTH (`DATA_WIDTH),
               .DEPTH (`DEPTH),
               .ALMOST_EMPTY(`ALMOST_EMPTY),
               .ALMOST_FULL(`ALMOST_FULL))
  fifo(
    .i_wr_clk  (intf.clk),
    .i_rstn(intf.reset),
    .i_wr_data  (intf.din),
    .i_rd_en (intf.read),
    .i_wr_en(intf.write),
    
    .o_rd_data(intf.dout),
    .o_empty(intf.empty),
    .o_full(intf.full),
    .o_ale(intf.ale),
    .o_alf(intf.alf)
  );
  
  initial begin
    uvm_config_db#(virtual fifo_intf)::set(uvm_root::get(), "*", "vif", intf);
    run_test("fifo_test");
  end
  
  
  final begin
    $display("-----------> Finished Testbench <-----------");
  end
  
  initial begin
    $dumpfile("dumpfile.vcd");
    $dumpvars;
  end
  
endmodule
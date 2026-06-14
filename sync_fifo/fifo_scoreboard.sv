`include "parameters.svh"

class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  
  uvm_analysis_imp #(fifo_item, fifo_scoreboard) mon_imp;
  
  bit [`DATA_WIDTH-1:0] exp_q [$];
  
  function new (string name = "fifo_scoreboard", uvm_component parent);
    super.new(name, parent);
    
    mon_imp = new("mon_imp",this);
  endfunction
  
  virtual function void write (fifo_item tr);
    bit [`DATA_WIDTH-1: 0] expected;
    
    // Write
    if (tr.write && !tr.full) begin
      exp_q.push_back(tr.din);
      
      //`uvm_info(get_type_name(), $sformatf("WRITE: Pushed %0d | Depth %0d", tr.din, exp_q.size()), UVM_LOW)
    end
    
    // Read
    if (tr.read && !tr.empty) begin
      if (exp_q.size() == 0) begin
        `uvm_error (get_type_name(), "READ observed but queue is empty")
        
        return;
      end
      
      expected = exp_q.pop_front();
      
      if (expected == tr.dout) begin
        //`uvm_info(get_type_name(), $sformatf("PASS expected: %0d actual: %0d", expected, tr.dout), UVM_MEDIUM)
      
      end else begin
        `uvm_error(get_type_name(), $sformatf("FAIL expected: %0d actual: %0d", expected, tr.dout))
      end
    end
    
  endfunction
  
endclass
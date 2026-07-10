class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  
  wr_agent wr_agnt;
  
  function new (string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    wr_agnt = wr_agent::type_id::create("wr_agnt", this);
  endfunction
  
endclass
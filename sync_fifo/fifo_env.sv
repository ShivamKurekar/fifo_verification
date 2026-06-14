class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)
  
  function new (string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  // class handles
  fifo_agent agent;
  fifo_scoreboard scb;
  fifo_coverage coverage;
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    agent = fifo_agent::type_id::create("agent", this);
    scb = fifo_scoreboard::type_id::create("scb", this);
    coverage = fifo_coverage::type_id::create("coverage", this);
  endfunction
  
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.ap_mon.connect(scb.mon_imp);
    agent.monitor.ap_mon.connect(coverage.analysis_export);
  endfunction
  
endclass
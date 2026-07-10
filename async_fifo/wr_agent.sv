class wr_agent extends uvm_agent;
  `uvm_component_utils(wr_agent)
  
  wr_driver drv;
  uvm_sequencer #(wr_txn) seqr;
  wr_monitor mon;
  
  uvm_analysis_port #(wr_txn) ap;
  
  function new (string name = "wr_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    ap 		= new("ap", this);
    drv		= wr_driver::type_id::create("drv", this);
    seqr	= uvm_sequencer #(wr_txn)::type_id::create("seqr", this);
    mon		= wr_monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    mon.wr_ap.connect(ap);
  endfunction
endclass
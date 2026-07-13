class rd_agent extends uvm_agent;
  `uvm_component_utils(rd_agent)
  
  rd_driver drv;
  uvm_sequencer #(rd_txn) seqr;
  rd_monitor mon;

  uvm_analysis_port #(rd_txn) ap;

  function new (string name = "rd_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    ap 		= new("ap", this);
    drv		= rd_driver::type_id::create("drv", this);
    seqr	= uvm_sequencer #(rd_txn)::type_id::create("seqr", this);
    mon		= rd_monitor::type_id::create("mon", this);
  endfunction
  
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    mon.rd_ap.connect(ap);
  endfunction
endclass
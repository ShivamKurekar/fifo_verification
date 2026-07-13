class fifo_test extends uvm_test;
  `uvm_component_utils(fifo_test);
  
  fifo_env env;
  
  function new (string name = "fifo_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase (uvm_phase phase);
    wr_till_full wr_seq_h;
    rd_till_empty rd_seq_h;

    phase.raise_objection(this);

    wr_seq_h = wr_till_full::type_id::create("wr_seq_h");
    rd_seq_h = rd_till_empty::type_id::create("rd_seq_h");

    
    wr_seq_h.start(env.wr_agnt.seqr);
    rd_seq_h.start(env.rd_agnt.seqr);
   
    phase.drop_objection(this);
  endtask
  
endclass
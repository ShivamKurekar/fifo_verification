class fifo_rand_test extends uvm_test;
  `uvm_component_utils(fifo_rand_test)

  fifo_env env;

  function new (string name = "fifo_rand_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase (uvm_phase phase);
    random_write_seq wr_seq_h;
    random_read_seq rd_seq_h;

    phase.raise_objection(this);

    wr_seq_h = random_write_seq::type_id::create("wr_seq_h");
    rd_seq_h = random_read_seq::type_id::create("rd_seq_h");

    // TRUE concurrency across the two clock domains
    fork
      wr_seq_h.start(env.wr_agnt.seqr);
      rd_seq_h.start(env.rd_agnt.seqr);
    join

    phase.drop_objection(this);
  endtask
endclass
class fifo_test extends uvm_test;
  
  `uvm_component_utils(fifo_test)
  
  function new (string name = "fifo_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  fifo_env env_f;
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env_f = fifo_env::type_id::create("env_f", this);
  endfunction
  
  function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    $display("Hierarchy:");
    uvm_root::get().print_topology();
  endfunction
  
  // Sequence class task call
  task run_phase (uvm_phase phase);
    
    reset_seq rst_seq;
    full_seq f_seq;
    drain_seq d_seq;
    alf_seq af_seq;
    ale_seq ae_seq;
    rand_seq r_seq;
    
    phase.raise_objection(this);
    
      rst_seq = reset_seq::type_id::create("rst_seq");
      rst_seq.start(env_f.agent.sequencer);
    
      f_seq = full_seq::type_id::create("f_seq");
      f_seq.start(env_f.agent.sequencer);
    
    
      d_seq = drain_seq::type_id::create("d_seq");
      d_seq.start(env_f.agent.sequencer);
            
      af_seq = alf_seq::type_id::create("af_seq");
      af_seq.start(env_f.agent.sequencer);

      ae_seq = ale_seq::type_id::create("ae_seq");
      ae_seq.start(env_f.agent.sequencer);
    
      r_seq = rand_seq::type_id::create("r_seq");
      r_seq.start(env_f.agent.sequencer);
                                       
      #200;
    phase.drop_objection(this);
  endtask
    
  
  
endclass:fifo_test
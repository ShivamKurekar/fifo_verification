class wr_seq extends uvm_sequence;
  `uvm_object_utils(wr_seq)
  
  function new (string name = "wr_seq");
    super.new(name);
  endfunction
  
  task wr_fifo();
    wr_txn rsp;
    wr_txn req = wr_txn::type_id::create("req");
    
    start_item(req);
    if (!req.randomize() with { wr_en == 1;})
    `uvm_error(get_type_name(), "req.randomize() failed in wr_fifo")
    finish_item(req);
  endtask
  
  task en_off();
    wr_txn rsp;
    wr_txn req = wr_txn::type_id::create("req");
    
    start_item(req);
    if (!req.randomize() with { wr_en == 0;})
    `uvm_error(get_type_name(), "req.randomize() failed in wr_fifo")
    finish_item(req);
  endtask

endclass

class single_wr_seq extends wr_seq;
  `uvm_object_utils(single_wr_seq)
 
  function new (string name = "single_wr_seq");
    super.new(name);
  endfunction
 
  task body();
    wr_fifo();   // exactly one write, wr_en == 1
  endtask
endclass

class wr_till_full extends wr_seq;
  `uvm_object_utils(wr_till_full)
  
  function new (string name = "wr_till_full");
    super.new(name);
  endfunction
  
  task body();
    for (int i = 0; i < (`DEPTH+3); i++)
    wr_fifo();
//     en_off();
  endtask
endclass

class random_write_seq extends wr_seq;
  `uvm_object_utils(random_write_seq)

  rand int count;
  rand int idle;

  constraint c_count { count inside {[1:(`DEPTH*100)]}; }
  constraint c_idle  { idle inside {[0:40]}; }

  function new(string name = "random_write_seq");
    super.new(name);
  endfunction

  task body();

    if (!randomize())
      `uvm_error(get_type_name(), "Randomization failed")

    `uvm_info(get_type_name(),
      $sformatf("count = %0d, idle = %0d", count, idle),
      UVM_LOW)

    repeat (count) begin
      if ($urandom_range(0,99) < idle)
        en_off();
      else
        wr_fifo();
    end

  endtask

endclass
class rd_seq extends uvm_sequence;
  `uvm_object_utils(rd_seq)
  
  function new (string name = "rd_seq");
    super.new(name);
  endfunction
  
  task read_fifo();
    rd_txn rsp;
    rd_txn req = rd_txn::type_id::create("req");
    
    start_item(req);
    if (!req.randomize() with { rd_en == 1; })
    `uvm_error(get_type_name(), "req.randomize() failed in rd_fifo")
    finish_item(req);
  endtask
  
  task en_off();
    rd_txn rsp;
    rd_txn req = rd_txn::type_id::create("req");
    
    start_item(req);
    if (!req.randomize() with { rd_en == 0;})
    `uvm_error(get_type_name(), "req.randomize() failed in rd_fifo")
    finish_item(req);
  endtask
  
endclass

class single_rd_seq extends rd_seq;
  `uvm_object_utils(single_rd_seq)
 
  function new (string name = "single_rd_seq");
    super.new(name);
  endfunction
 
  task body();
    read_fifo();   // exactly one read, rd_en == 1
  endtask
endclass

class rd_till_empty extends rd_seq;
  `uvm_object_utils(rd_till_empty)
  
  function new (string name = "rd_till_empty");
    super.new(name);
  endfunction
  
  task body();
    for (int i = 0; i < (`DEPTH+3); i++)
    read_fifo();
  endtask

endclass

class random_read_seq extends rd_seq;
  `uvm_object_utils(random_read_seq)

  rand int count;
  rand int idle;

  constraint c_count { count inside {[1:(`DEPTH*100)]}; }
  constraint c_idle  { idle inside {[0:40]}; }

  function new(string name = "random_read_seq");
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
        read_fifo();
    end
  endtask

endclass
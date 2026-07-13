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

class wr_till_full extends wr_seq;
  `uvm_object_utils(wr_till_full)
  
  function new (string name = "wr_till_full");
    super.new(name);
  endfunction
  
  task body();
    for (int i = 0; i < (`DEPTH+3); i++)
    wr_fifo();
    en_off();
  endtask
endclass
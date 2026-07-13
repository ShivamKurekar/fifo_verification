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
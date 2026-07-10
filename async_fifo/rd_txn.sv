class rd_txn extends uvm_sequence_item;
  
  rand bit rd_en;

  `uvm_object_utils_begin (rd_txn)
  `uvm_field_int (rd_en, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new (string name = "rd_txn");
    super.new(name);
  endfunction
  
endclass
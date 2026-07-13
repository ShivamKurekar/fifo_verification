class rd_txn extends uvm_sequence_item;
  
  rand bit rd_en;
  bit [`DATA_WIDTH - 1: 0] rd_data;
  bit empty;

  `uvm_object_utils_begin (rd_txn)
  `uvm_field_int (rd_en, UVM_ALL_ON)
  `uvm_field_int (rd_data, UVM_ALL_ON)
  `uvm_field_int (empty, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new (string name = "rd_txn");
    super.new(name);
  endfunction
  
  function string c2s();
    return $sformatf("RD_EN: %0b | RD_DATA: %0h | EMPTY: %0b", rd_en, rd_data, empty);
  endfunction
  
endclass
class wr_txn extends uvm_sequence_item;
  
  randc logic [`DATA_WIDTH - 1: 0] wr_data;
  randc logic wr_en;
  
  logic full;
  
  `uvm_object_utils_begin (wr_txn)
  `uvm_field_int(wr_data, UVM_ALL_ON)
  `uvm_field_int(wr_en, UVM_ALL_ON)
  `uvm_field_int(full, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new (string name = "wr_txn");
    super.new(name);
  endfunction
  
  function string c2s();
    return $sformatf("WR_EN: %0b | WR_DATA: %0h | FULL: %0b", wr_en, wr_data, full);
  endfunction

endclass
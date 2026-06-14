`include "parameters.svh"

class fifo_item extends uvm_sequence_item;
  
  // I/P ports
  rand logic read;
  rand logic write;
  randc logic [`DATA_WIDTH-1: 0] din;
  rand logic reset;
  
  // O/P ports
  logic [`DATA_WIDTH-1: 0] dout;
  logic empty;
  logic full;
  logic ale;
  logic alf;
  
  // object registeration with uvm_factory
  `uvm_object_utils_begin (fifo_item)
  	// object registration for UVM AUTOMATION
      `uvm_field_int(reset, UVM_ALL_ON)
      `uvm_field_int(read, UVM_ALL_ON)
      `uvm_field_int(write, UVM_ALL_ON)
      `uvm_field_int(din, UVM_ALL_ON)
  
      `uvm_field_int(dout, UVM_ALL_ON)
      `uvm_field_int(empty, UVM_ALL_ON)
      `uvm_field_int(full, UVM_ALL_ON)
      `uvm_field_int(ale, UVM_ALL_ON)
      `uvm_field_int(alf, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new (string name = "fifo_item");
    super.new(name);
  endfunction
  
  virtual function string c2s();

    string op;

    if (!reset)
      op = "RESET";
    else if (write && read)
      op = "RD_WR";
    else if (write)
      op = "WRITE";
    else if (read)
      op = "READ";
    else
      op = "IDLE";

    return $sformatf(
        "[%s] din=%02h dout=%02h full=%0b empty=%0b alf=%0b ale=%0b",
        op,
        din,
        dout,
        full,
        empty,
        alf,
        ale
    );

  endfunction
  
endclass
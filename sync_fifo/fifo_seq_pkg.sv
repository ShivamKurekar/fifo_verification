`include "parameters.svh"
`include "uvm_macros.svh"

package fifo_seq_pkg;

import uvm_pkg::*;

`include "fifo_item.sv"


//----------BASE FIFO SEQUENCE-------------
class base_sequence extends uvm_sequence #(fifo_item);
  `uvm_object_utils(base_sequence)
  
  fifo_item rsp;
  
  function new (string name = "base_sequence");
    super.new(name);
  endfunction
  
  task do_reset();
    fifo_item req;   
    req = fifo_item::type_id::create("req");
    
//     `uvm_do_with (req, {
//       reset == 1;
//     })

    start_item(req);
    assert(req.randomize() with {
      reset == 0;
//       read == 0;
//       write == 0;
    });
    finish_item(req);
    get_response(rsp);
    
  endtask
  
  task send_read();
    fifo_item req;
    req = fifo_item::type_id::create("req");
    
//     `uvm_do_with (req, {
//       reset == 0;
//       write == 0;
//       read == 1; 
//     })

    start_item(req);
    assert(req.randomize() with {
      reset == 1;
      write == 0;
      read == 1;
      din == 0;
    });
    finish_item(req);
    get_response(rsp);

    
  endtask
  
  task send_write();
    fifo_item req;
    req = fifo_item::type_id::create("req");

//     `uvm_do_with (req, {
//       reset == 0;
//       write == 1;
//       read == 0;
//     })
    
    start_item(req);
    assert(req.randomize() with {
      reset == 1;
      write == 1;
      read == 0;
    });
    finish_item(req);
    get_response(rsp);
    
  endtask
  
  task send_random();
    fifo_item req;
    req = fifo_item::type_id::create("req");

//     `uvm_do_with (req, {
//       reset == 0;
//       write == 1;
//       read == 0;
//     })
    
    start_item(req);
    assert(req.randomize() with {
      reset == 1;
    });
    finish_item(req);
    get_response(rsp);
  endtask
  
endclass

//----------RESET SEQUENCE-------------
class reset_seq extends base_sequence;
  `uvm_object_utils(reset_seq)
  
  function new (string name = "reset_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ_PKG", "Started RESET SEQUENCE", UVM_LOW)
    repeat(2)
    	do_reset();
    `uvm_info("SEQ_PKG", "Completed RESET SEQUENCE", UVM_LOW)
  endtask
    
endclass

//----------FULL SEQUENCE-------------
class full_seq extends base_sequence;
  `uvm_object_utils(full_seq)
  
  function new (string name = "full_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ_PKG", "Started FIFO FULL SEQUENCE", UVM_LOW)
    
    do begin
      send_write();
    end while(!rsp.full);
    
    `uvm_info("SEQ_PKG", "Completed FIFO FULL SEQUENCE", UVM_LOW)
  endtask

endclass

//----------DRAIN SEQUENCE-------------
class drain_seq extends base_sequence;
  `uvm_object_utils(drain_seq)
  
  function new (string name = "drain_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ_PKG", "Started FIFO DRAIN SEQUENCE", UVM_LOW)
    
    do begin
      send_read();  
    end while(!rsp.empty);
    
    `uvm_info("SEQ_PKG", "Completed FIFO DRAIN SEQUENCE", UVM_LOW)
  endtask

endclass

//----------Almost FULL SEQUENCE-------------
class alf_seq extends base_sequence;
  `uvm_object_utils(alf_seq)
  
  function new (string name = "alf_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ_PKG", "Started FIFO ALMOST FULL SEQUENCE", UVM_LOW)
    
    do begin
      send_write();
    end while(!rsp.alf);
    
    `uvm_info("SEQ_PKG", "Completed FIFO ALMOST FULL SEQUENCE", UVM_LOW)
  endtask

endclass


//----------Almost EMPTY SEQUENCE-------------
class ale_seq extends base_sequence;
  `uvm_object_utils(ale_seq)
  
  function new (string name = "ale_seq");
    super.new(name);
  endfunction
  
  task body();
    `uvm_info("SEQ_PKG", "Started FIFO ALMOST EMPTY SEQUENCE", UVM_LOW)
    
    do begin
      send_read();
    end while(!rsp.ale);
      
    `uvm_info("SEQ_PKG", "Completed FIFO ALMOST EMPTY SEQUENCE", UVM_LOW)
  endtask

endclass


//----------RANDOM SEQUENCE-------------
class rand_seq extends base_sequence;
  `uvm_object_utils(rand_seq)
  
  int num_trans;
  
  function new (string name = "rand_seq");
    super.new(name);
    num_trans = $urandom_range(50, 200);
  endfunction
  
  task body();
    `uvm_info("SEQ", "Started RANDOM_OPERATION", UVM_LOW)
    
    repeat(num_trans)
      send_random();
    
    `uvm_info("SEQ", "Completed RANDOM_OPERATION", UVM_LOW)
  endtask

endclass

endpackage
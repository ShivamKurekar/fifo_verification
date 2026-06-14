class fifo_driver extends uvm_driver #(fifo_item);
  `uvm_component_utils(fifo_driver)
  
  function new (string name = "fifo_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual interface fifo_intf vif;
    
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      
      if (!(uvm_config_db#(virtual fifo_intf)::get(this, "", "vif", vif)))
        `uvm_fatal("DRIVER", "UNABLE TO GET INTERFACE")
    endfunction

    // run_phase task
	task run_phase (uvm_phase phase);
      fifo_item txn = fifo_item::type_id::create("txn");
      fifo_item rsp;
      
      fifo_init();
      
      forever begin
        seq_item_port.get_next_item(txn);
        drive_fifo(txn, rsp);
        rsp.set_id_info(txn);
        seq_item_port.item_done(rsp);
      end
	endtask
      
    // fifo initialization
    task fifo_init();
      vif.reset <= 1;
      vif.read  <= 0;
      vif.write <= 0;
      vif.din   <= 0;
    endtask
      
    // driving fifo
    task drive_fifo(fifo_item tx, output fifo_item rx);
      fifo_item resp;
      if (!($cast(resp, tx.clone()))) `uvm_fatal ("DRIVER", "FIFO Drive error")
        
      vif.cb.reset <= tx.reset;
      vif.cb.read  <= tx.read;
      vif.cb.write <= tx.write;
      vif.cb.din   <= tx.din;
      
      @vif.cb;
      resp.empty = vif.cb.empty;
      resp.full = vif.cb.full;
      resp.ale  = vif.cb.ale;
      resp.alf  = vif.cb.alf;
      resp.dout = vif.cb.dout;
      
      rx = resp;
    endtask
  
endclass
class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)
  
  function new(string name = "fifo_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  fifo_item tr;
  
  virtual interface fifo_intf vif;
    
  uvm_analysis_port #(fifo_item) ap_mon;
  	
    // build phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);

      if (!(uvm_config_db #(virtual fifo_intf)::get(this, "", "vif", vif)))
        `uvm_fatal("MONITOR", "UNABLE TO GET INTERFACE")
        ap_mon = new("ap_mon", this);
    endfunction
      
    // run phase
    task run_phase(uvm_phase phase);
		forever begin
          tr = fifo_item::type_id::create("tr");
          sample_fifo(tr);
//           `uvm_info("MONITOR", tr.c2s(), UVM_LOW)
          ap_mon.write(tr);
        end
    endtask
    
    task sample_fifo (output fifo_item trns);
      fifo_item txn = fifo_item::type_id::create("txn");
      @vif.cb;
      txn.reset = vif.reset;
      txn.read  = vif.read;
      txn.write = vif.write;
      txn.din   = vif.din;
      
      
      txn.dout = vif.dout;
      txn.full = vif.full;
      txn.empty = vif.empty;
      txn.ale = vif.ale;
      txn.alf = vif.alf;
      
      trns = txn;
    endtask

endclass
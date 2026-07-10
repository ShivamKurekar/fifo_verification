class wr_monitor extends uvm_monitor;
  `uvm_component_utils(wr_monitor)
  
  virtual fifo_wr_if.MONITOR vif;
  
  uvm_analysis_port #(wr_txn) wr_ap;

  function new (string name = "wr_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    wr_ap = new("wr_ap", this);
    if(!(uvm_config_db#(virtual fifo_wr_if.MONITOR)::get(this, "", "wr_if", vif)))begin
      `uvm_fatal(get_type_name(), "UNABLE TO FETCH THE WR VIF")
    end
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      wr_txn txn;
      
      @(posedge vif.wr_clk);
      if (vif.wr_rstn === 1'b1)  begin
        txn = wr_txn::type_id::create("txn");
        
        txn.wr_en	= vif.wr_en;
        txn.wr_data = vif.wr_data;
        txn.full	= vif.full;
        
        `uvm_info(get_type_name(), txn.c2s(), UVM_MEDIUM)
        wr_ap.write(txn);
      end    
    end
  endtask
  
endclass
class wr_monitor extends uvm_monitor;
  `uvm_component_utils(wr_monitor)
  
  bit rstn;

  virtual fifo_wr_if.MONITOR vif;
  
  uvm_analysis_port #(wr_txn) wr_ap;
  uvm_analysis_port #(bit) rst_ap;

  function new (string name = "wr_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    
    wr_ap = new("wr_ap", this);
    rst_ap = new("rst_ap", this);

    if(!(uvm_config_db#(virtual fifo_wr_if.MONITOR)::get(this, "", "wr_mon", vif)))begin
      `uvm_fatal(get_type_name(), "UNABLE TO FETCH THE WR VIF")
    end
  endfunction
  
  task run_phase (uvm_phase phase);
    forever begin
      wr_txn txn;
      txn = wr_txn::type_id::create("txn");
      
      @(posedge vif.wr_clk);        

      txn.wr_en	= vif.wr_en;
      txn.wr_data = vif.wr_data;
      txn.full	= vif.full;
      rstn = vif.wr_rstn;
      
      `uvm_info(get_type_name(), txn.c2s(), UVM_MEDIUM)
      wr_ap.write(txn);
      rst_ap.write(rstn);
    
    end
  endtask
  
endclass
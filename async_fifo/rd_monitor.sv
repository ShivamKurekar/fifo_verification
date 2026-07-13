class rd_monitor extends uvm_monitor;
  `uvm_component_utils(rd_monitor)
  
  bit rstn;

  virtual fifo_rd_if.MONITOR vif;
  
  uvm_analysis_port #(rd_txn) rd_ap;
  uvm_analysis_port #(bit) rst_ap;

  function new (string name = "rd_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    rd_ap = new("rd_ap", this);
    rst_ap = new("rst_ap", this);

    if(!(uvm_config_db#(virtual fifo_rd_if.MONITOR)::get(this, "", "rd_mon", vif)))begin
      `uvm_fatal(get_type_name(), "UNABLE TO FETCH THE RD VIF")
    end
  endfunction
  
   task run_phase (uvm_phase phase);
    forever begin
      rd_txn txn;
      txn = rd_txn::type_id::create("txn");

      rstn = vif.rd_rstn;
      
      @(posedge vif.rd_clk);
      txn.rd_en	= vif.rd_en;
      txn.rd_data = vif.rd_data;
      txn.empty	= vif.empty;
      
      `uvm_info(get_type_name(), txn.c2s(), UVM_MEDIUM)
      rd_ap.write(txn);
      rst_ap.write(rstn);
    
    end
  endtask

endclass
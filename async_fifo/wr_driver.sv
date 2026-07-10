class wr_driver extends uvm_driver #(wr_txn);
  `uvm_component_utils(wr_driver)
  
  virtual fifo_wr_if.DRIVER wr_if;
  
  function new (string name = "wr_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      
      if (!uvm_config_db #(virtual fifo_wr_if.DRIVER)::get(this, "", "wr_if", wr_if)) begin
        `uvm_fatal(get_type_name(), "UNABLE TO FETCH WR INTERFACE")
      end
    endfunction
    
  task run_phase (uvm_phase phase);
    reset_signals();
    wait(wr_if.wr_rstn === 1'b1);

    forever begin
      fork
        begin : DRIVE_TRAFFIC
          drive_loop();
        end
        begin : RESET_WATCHER
          @(negedge wr_if.wr_rstn);
        end
      join_any
      disable fork;

        if (wr_if.wr_rstn === 1'b0) begin
          `uvm_info(get_type_name(), "Reset detected mid-run, flushing driver state", UVM_MEDIUM)
          reset_signals();
          wait(wr_if.wr_rstn === 1'b1);
        end
        end
  endtask
    
    task reset_signals();
      wr_if.wr_cb.wr_en   <= 1'b0;
      wr_if.wr_cb.wr_data <= '0;
    endtask
    
    task drive_txn(wr_txn req);
      @(wr_if.wr_cb);
      wr_if.wr_cb.wr_en   <= req.wr_en;
      wr_if.wr_cb.wr_data <= req.wr_data;
    endtask
  
  task drive_loop();
    forever begin
      wr_txn req;
      bit reset_occurred = 0;

      seq_item_port.get_next_item(req);

      fork
        begin : DO_DRIVE
          while (wr_if.wr_cb.full) @(wr_if.wr_cb);
          drive_txn(req);
        end
        begin : RESET_MON
          @(negedge wr_if.wr_rstn);
          reset_occurred = 1;
        end
      join_any
      disable fork;

        seq_item_port.item_done();

        if (reset_occurred) return;
        end
  endtask

endclass
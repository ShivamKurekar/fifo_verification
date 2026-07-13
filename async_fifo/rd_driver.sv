class rd_driver extends uvm_driver #(rd_txn);
  `uvm_component_utils(rd_driver)

  virtual fifo_rd_if.DRIVER vif;

  function new (string name = "rd_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual fifo_rd_if.DRIVER)::get(this, "", "rd_drv", vif)) begin
      `uvm_fatal(get_type_name(), "UNABLE TO FETCH RD INTERFACE")
    end
  endfunction

  task run_phase (uvm_phase phase);
    reset_signals();
    wait(vif.rd_rstn === 1'b1);

    forever begin
      fork
        begin : DRIVE_TRAFFIC
          drive_loop();
        end
        begin : RESET_WATCHER
          @(negedge vif.rd_rstn);
        end
      join_any
      disable fork;

      if (vif.rd_rstn === 1'b0) begin
        `uvm_info(get_type_name(), "Reset detected mid-run, flushing driver state", UVM_MEDIUM)
        reset_signals();
        wait(vif.rd_rstn === 1'b1);
      end
    end
  endtask

  task reset_signals();
    vif.rd_cb.rd_en <= 1'b0;
  endtask

  task drive_txn(rd_txn req);
    @(vif.rd_cb);
    vif.rd_cb.rd_en <= req.rd_en;
  endtask

  task drive_loop();
    forever begin
      rd_txn req;
      bit reset_occurred = 0;

      seq_item_port.get_next_item(req);

      fork
        begin : DO_DRIVE
//           while (vif.rd_cb.empty) @(vif.rd_cb);
          drive_txn(req);
        end
        begin : RESET_MON
          @(negedge vif.rd_rstn);
          reset_occurred = 1;
        end
      join_any
      disable fork;

      seq_item_port.item_done();
      if (reset_occurred) return;
    end
  endtask
endclass
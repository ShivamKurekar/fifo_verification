class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  
  `uvm_analysis_imp_decl(_wr)
  `uvm_analysis_imp_decl(_rd)
  `uvm_analysis_imp_decl(_rst)

  uvm_analysis_imp_wr  #(wr_txn, fifo_scoreboard) wr_imp;
  uvm_analysis_imp_rd  #(rd_txn, fifo_scoreboard) rd_imp;
  uvm_analysis_imp_rst #(bit,    fifo_scoreboard) rst_imp;

  bit [`DATA_WIDTH - 1: 0] ref_q[$];

  int unsigned match_cnt, mismatch_cnt, underflow_cnt, overflow_cnt;

  function new (string name = "fifo_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    wr_imp  = new("wr_imp",  this);
    rd_imp  = new("rd_imp",  this);
    rst_imp = new("rst_imp", this);
  endfunction

  // ---- write side: push accepted writes, flag illegal writes past DEPTH ----
  function void write_wr(wr_txn t);
    if (t.wr_en && !t.full) begin
      if (ref_q.size() >= `DEPTH) begin
        overflow_cnt++;
        `uvm_error(get_type_name(),
          $sformatf("OVERFLOW: write accepted (wr_data=0x%0h) while ref_q already at DEPTH=%0d - full flag failed to block a write",
                     t.wr_data, `DEPTH))
        return;
      end
      ref_q.push_back(t.wr_data);
      `uvm_info(get_type_name(),
        $sformatf("PUSH wr_data=0x%0h (ref_q size=%0d)", t.wr_data, ref_q.size()),
        UVM_MEDIUM)
    end
  endfunction

  // ---- read side: pop and compare against accepted reads ----
  function void write_rd(rd_txn t);
    bit [`DATA_WIDTH - 1: 0] exp_data;
    bit [`DATA_WIDTH - 1: 0] read_data;

    if (t.rd_en && !t.empty) begin
      if (ref_q.size() == 0) begin
        underflow_cnt++;
        `uvm_error(get_type_name(),
          $sformatf("UNDERFLOW: read observed (rd_data=0x%0h) but reference queue is empty - empty flag failed to block a read",
                     t.rd_data))
        return;
      end

      exp_data = ref_q.pop_front();
      read_data = t.rd_data;
      `uvm_info(get_type_name(),
                $sformatf("POP rd_data=0x%0h (ref_q size=%0d)", read_data, ref_q.size()),
        UVM_MEDIUM)

      if (exp_data !== read_data) begin
        mismatch_cnt++;
        `uvm_error(get_type_name(),
          $sformatf("MISMATCH: expected=0x%0h actual=0x%0h (ref_q size now=%0d)",
                     exp_data, read_data, ref_q.size()))
      end else begin
        match_cnt++;
        `uvm_info(get_type_name(),
          $sformatf("MATCH: data=0x%0h (ref_q size now=%0d)", t.rd_data, ref_q.size()),
          UVM_HIGH)
      end
    end
  endfunction

  function void write_rst(bit rst_seen);
    if (!rst_seen) begin
      `uvm_info(get_type_name(), "RESET_SEEN flushing queue", UVM_MEDIUM)
      ref_q.delete();
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("SCOREBOARD SUMMARY: match=%0d mismatch=%0d underflow=%0d overflow=%0d residual_ref_q=%0d",
                 match_cnt, mismatch_cnt, underflow_cnt, overflow_cnt, ref_q.size()),
      UVM_NONE)

    if (mismatch_cnt == 0 && underflow_cnt == 0 && overflow_cnt == 0 && match_cnt > 0)
      `uvm_info(get_type_name(), "TEST PASSED", UVM_NONE)
    else
      `uvm_error(get_type_name(), "TEST FAILED")
  endfunction
endclass
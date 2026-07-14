class fifo_coverage extends uvm_subscriber #(wr_txn);
  `uvm_component_utils(fifo_coverage)

  `uvm_analysis_imp_decl(_rd)
  `uvm_analysis_imp_decl(_rst)
  uvm_analysis_imp_rd  #(rd_txn, fifo_coverage) rd_cov_ap;

  wr_txn m_wr;
  rd_txn m_rd;

  int unsigned wr_count;
  int unsigned rd_count;
  int unsigned wr_while_full_count;
  int unsigned rd_while_empty_count;

  // Write-side coverage
  covergroup cg_wr_trans with function sample (wr_txn txn);
    option.per_instance = 1;

    cp_wr_en : coverpoint txn.wr_en {
      bins EN  = {1'b1};
      bins DIS = {1'b0};
    }

    cp_full : coverpoint txn.full {
      bins FULL     = {1'b1};
      bins NOT_FULL = {1'b0};
    }

    cx_full_wren : cross cp_full, cp_wr_en;
  endgroup : cg_wr_trans

  // Read-side coverage
  covergroup cg_rd_trans with function sample (rd_txn txn);
    option.per_instance = 1;

    cp_rd_en : coverpoint txn.rd_en {
      bins EN  = {1'b1};
      bins DIS = {1'b0};
    }

    cp_empty : coverpoint txn.empty {
      bins EMPTY     = {1'b1};
      bins NOT_EMPTY = {1'b0};
    }

    cx_empty_rden : cross cp_empty, cp_rd_en;
  endgroup : cg_rd_trans

  function new (string name = "fifo_coverage", uvm_component parent);
    super.new(name, parent);
    cg_wr_trans = new();
    cg_rd_trans = new();
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    rd_cov_ap  = new("rd_cov_ap",  this);

    wr_count             = 0;
    rd_count              = 0;
    wr_while_full_count   = 0;
    rd_while_empty_count  = 0;
  endfunction

  function void write (wr_txn t);
    m_wr = t;
    cg_wr_trans.sample(t);

    if (t.wr_en && !t.full)
      wr_count++;
    else if (t.wr_en && t.full)
      wr_while_full_count++;

    `uvm_info(get_type_name(), t.c2s(), UVM_HIGH)
  endfunction

  function void write_rd (rd_txn t);
    m_rd = t;
    cg_rd_trans.sample(t);

    if (t.rd_en && !t.empty)
      rd_count++;
    else if (t.rd_en && t.empty)
      rd_while_empty_count++;

    `uvm_info(get_type_name(), t.c2s(), UVM_HIGH)
  endfunction

  function void report_phase (uvm_phase phase);
    `uvm_info(get_type_name(), c2s(), UVM_NONE)
  endfunction

  function string c2s();
    return $sformatf(
      "\n========== FUNCTIONAL COVERAGE REPORT ==========\n cg_wr_trans           : %0.1f%%\n cg_rd_trans           : %0.1f%%\n wr accepted=%0d  wr while full=%0d\n rd accepted=%0d  rd while empty=%0d\n =================================================",
      cg_wr_trans.get_coverage(),
      cg_rd_trans.get_coverage(),
      wr_count,
      wr_while_full_count,
      rd_count,
      rd_while_empty_count
    );
  endfunction

endclass : fifo_coverage

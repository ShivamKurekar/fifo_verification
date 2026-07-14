class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  wr_agent wr_agnt;
  rd_agent rd_agnt;
  fifo_scoreboard sb;
  fifo_coverage cov;

  function new (string name = "fifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    wr_agnt = wr_agent::type_id::create("wr_agnt", this);
    rd_agnt = rd_agent::type_id::create("rd_agnt", this);
    sb      = fifo_scoreboard::type_id::create("sb", this);
    cov		= fifo_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    wr_agnt.mon.wr_ap.connect(sb.wr_imp);
    rd_agnt.mon.rd_ap.connect(sb.rd_imp);

    wr_agnt.mon.rst_ap.connect(sb.rst_imp);
    rd_agnt.mon.rst_ap.connect(sb.rst_imp);
    
    wr_agnt.mon.wr_ap.connect(cov.analysis_export);
    rd_agnt.mon.rd_ap.connect(cov.rd_cov_ap);
  endfunction
endclass
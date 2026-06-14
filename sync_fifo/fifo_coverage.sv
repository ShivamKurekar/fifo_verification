class fifo_coverage extends uvm_subscriber #(fifo_item);
  
  `uvm_component_utils(fifo_coverage)
  
  function new (string name = "fifo_coverage", uvm_component parent);
    super.new(name, parent);
    
    fifo_cov = new();
  endfunction
  
  fifo_item cov_txn;
  
  real cov_score;
  
  covergroup fifo_cov;
    option.per_instance = 1;
    option.name         = "fifo_cov";
    option.comment      = "FIFO Functional Coverage";
    
    option.auto_bin_max = 255;
    
    COV_RESET: coverpoint cov_txn.reset;
    COV_READ:  coverpoint cov_txn.read;
    COV_WRITE: coverpoint cov_txn.write;
    COV_DIN:   coverpoint cov_txn.din;
    COV_ALE:   coverpoint cov_txn.ale;
    COV_ALF:   coverpoint cov_txn.alf;
    
    RW_CROSS: cross COV_READ, COV_WRITE;
  endgroup
  
  function void write (fifo_item t);
    cov_txn = t;
    fifo_cov.sample();
  endfunction
  
  function void extract_phase (uvm_phase phase);
    super.extract_phase(phase);
    cov_score = fifo_cov.get_coverage();
  endfunction
  
  function void report_phase (uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Coverage score: %2f", cov_score), UVM_NONE)
  endfunction

endclass
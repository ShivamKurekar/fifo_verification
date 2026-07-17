# FIFO Verification

SystemVerilog/UVM-based verification environments for both **Synchronous** and **Asynchronous FIFOs**.

## Repository Structure

```
fifo_verification/
├── sync_fifo/      # UVM verification environment for synchronous FIFO
└── async_fifo/     # Dual-clock FIFO verification with CDC-aware environment
```

## Verification Methodology

Both environments verify:

- Data integrity
- FIFO ordering (FIFO behavior)
- Overflow/Underflow handling
- Status flag correctness
- Reset functionality
- Corner-case scenarios


## Features

### Synchronous FIFO
- UVM-based verification environment
- Driver, Monitor, Sequencer, Agent, Environment
- Scoreboard using queue-based reference model
- Functional coverage
- Directed and randomized sequences
- Verification of:
  - Reset
  - Full
  - Empty
  - Almost Full
  - Almost Empty
  - Random read/write traffic

### Asynchronous FIFO
- Independent read/write clock domains
- Separate read/write agents
- Queue-based scoreboard
- SystemVerilog Assertions (SVA)
- Functional coverage
- Directed and randomized testing
- CDC-focused verification

## Verification Methodology

Both environments verify:

- Data integrity
- FIFO ordering (FIFO behavior)
- Overflow/Underflow handling
- Status flag correctness
- Reset functionality
- Corner-case scenarios

## EDA Playground

- **Synchronous FIFO:** https://edaplayground.com/x/iLY7
- **Asynchronous FIFO:** https://www.edaplayground.com/x/ANdA
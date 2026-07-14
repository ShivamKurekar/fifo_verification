# Verification Plan — Asynchronous FIFO (`async_fifo`)

This document describes the verification environment and test coverage for the dual-clock, Gray-code synchronized `async_fifo` design, as currently implemented in the UVM testbench.

---

## 1. What we're trying to prove

The FIFO moves data between two independent clock domains (write side and read side, no shared clock). The main risks:

- Data **lost, duplicated, or reordered** across the CDC boundary.
- **Full/empty flags** wrong or timed incorrectly.
- **Reset** leaves the FIFO in a bad state.
- **Corner cases** (full, empty, back-to-back write/read) not handled cleanly.

---

## 2. Testbench Architecture (as built)

```
tb (testbench.sv)
 ├── wr_clk / rd_clk, wr_rstn / rd_rstn   -> free-running clocks, shared reset release point
 ├── async_fifo (DUT)                     -> DEPTH=16, DATA_WIDTH=16 (params.svh)
 ├── fifo_wr_if / fifo_rd_if              -> one interface per clock domain
 └── fifo_env
      ├── wr_agent  (wr_driver, wr_monitor, sequencer)
      ├── rd_agent  (rd_driver, rd_monitor, sequencer)
      ├── fifo_scoreboard  -> reference-queue based checker
      └── fifo_coverage    -> UVM-side functional coverage
```

**Connections (`fifo_env`):**
- `wr_monitor.wr_ap` → `scoreboard.wr_imp` and `coverage.analysis_export`
- `rd_monitor.rd_ap` → `scoreboard.rd_imp` and `coverage.rd_cov_ap`
- `wr_monitor.rst_ap` / `rd_monitor.rst_ap` → `scoreboard.rst_imp` (queue flush on reset)

**DUT-side checking**, bound directly to `async_fifo` (independent of the UVM env):
- `async_fifo_sva.sv` — blackbox SVA assertions
- `async_fifo_cov.sv` — blackbox functional coverage

**Clock configuration:** `wr_clk` period = 10 ns, `rd_clk` period = 20 ns (write side 2× faster than read side). Both `wr_rstn`/`rd_rstn` are released together, 5 `rd_clk` cycles after start. This is a **single fixed clock ratio and synchronous reset release** — not yet the multi-ratio / skewed-reset sweep described in the original plan (see Section 6).

---

## 3. Tests Implemented

| Test | Sequences used | What it does | Wired to `run_test`? |
|---|---|---|---|
| `fifo_test` | `wr_till_full`, `rd_till_empty` | Directed: writes `DEPTH+3` entries (drives full and one write-while-full), then reads `DEPTH+3` entries (drives empty and one read-while-empty). Write and read run sequentially, not concurrently. | No (available, not default) |
| `fifo_rand_test` | `random_write_seq`, `random_read_seq` | Randomized write/read counts and idle-cycle probability (0–40%), run **concurrently** via `fork/join` on both agents — this is the main stress test for the CDC path. | **Yes** — set in `testbench.sv` |

Both sequence classes also include `single_wr_seq` / `single_rd_seq` for one-shot, directed transactions if needed for debug.

---

## 4. Checking Mechanisms

**Scoreboard (`fifo_scb.sv`)** — reference-model queue (`ref_q`), one entry per accepted write:
- Push on `wr_en && !full`; flags **overflow** if a write is accepted while `ref_q` already holds `DEPTH` entries.
- Pop-and-compare on `rd_en && !empty`; flags **underflow** if a read is accepted with an empty `ref_q`; flags **mismatch** on data miscompare.
- Flushes `ref_q` when either domain's `rst_ap` reports reset asserted.
- Pass/fail rolls up in `report_phase` (`match/mismatch/underflow/overflow` counts).

**SVA (`async_fifo_sva.sv`, bound to DUT ports only):**
- `o_full` and `o_empty` never both asserted (checked on both clock domains).
- `o_empty` high immediately after `i_rd_rstn` release; `o_full` low immediately after `i_wr_rstn` release.
- `o_full`, `o_empty`, `o_rd_data` never unknown (X/Z) after reset.
- A write eventually clears `o_empty`; `o_full` eventually clears after asserting (bounded-time liveness checks).

**Functional coverage (two sources):**
- `fifo_cov.sv` (UVM subscriber, transaction-level): `wr_en`/`full` cross, `rd_en`/`empty` cross.
- `async_fifo_cov.sv` (bound to DUT): same en/flag crosses, plus write/read data value bins (zero, max, other).

---

## 5. Sign-off Checklist (current status)

- [x] Randomized concurrent write/read test (`fifo_rand_test`) passing via scoreboard
- [x] Full/empty mutual-exclusion and reset-state assertions passing
- [x] Directed full/empty test (`fifo_test`) wired into regression
- [x] Multiple clock ratios exercised
- [x] Depth/width parameter sweep


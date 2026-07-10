# Verification Plan — Asynchronous FIFO (`async_fifo`)

This document describes the verification plan for the dual-clock, Gray-code synchronized `async_fifo` design.

---

## 1. What we're trying to prove

This FIFO moves data between two clock domains that don't share a common clock (write side and read side run independently). The main risks in this kind of design are:

- Data gets **lost, duplicated, or reordered** when crossing clock domains.
- The **full/empty flags** are wrong or arrive a cycle too late/early.
- The **reset logic** misbehaves when the two domains reset at different times.
- The design **breaks at edge cases** — DEPTH-1, DEPTH, 0, wraparound, etc.

The verification plan below is built to catch exactly these failure modes.

---

## 2. Testbench Overview

We use a standard UVM setup, split cleanly by clock domain:

```
tb_top
 ├── wr_clk_gen, rd_clk_gen        -> independent, ratio configurable
 ├── async_fifo_env
      ├── wr_agent   -> drives writes on i_wr_clk
      ├── rd_agent   -> drives reads on i_rd_clk
      ├── scoreboard -> checks data order/integrity
      ├── coverage   -> tracks what's been tested
      └── virt_sequencer -> coordinates wr/rd traffic + clock ratio
```

**Key point:** keep the write and read sides as two separate agents with two separate clocks. Don't try to force them onto one shared interface/clocking block — that defeats the purpose of testing a real async design.

**Scoreboard:** doesn't need to be fancy. It's just a FIFO — push what you write, pop what you read, compare values in order. A plain SystemVerilog queue as the reference model is enough.

---

## 3. Clock Ratios to Test

The whole point of this design is handling clocks that aren't related. Always test these four cases:

| Case | Why it matters |
|---|---|
| Write clock much faster than read clock | Pushes toward FULL condition |
| Read clock much faster than write clock | Pushes toward EMPTY condition |
| Same frequency, random phase offset | Worst case for the synchronizer sampling window |
| Completely unrelated (non-integer ratio) frequencies | Closest to real silicon conditions |

---

## 4. Test List

| # | Test Name | What it checks |
|---|---|---|
| 1 | `reset_test` | Reset values are correct on both domains |
| 2 | `skewed_reset_test` | Resets asserted/released at different times on each side, no glitches |
| 3 | `basic_write_read_test` | One write, data shows up (FWFT), one read, FIFO goes empty |
| 4 | `full_flag_test` | `o_full` asserts on exactly the right cycle when FIFO fills up |
| 5 | `empty_flag_test` | `o_empty` asserts on exactly the right cycle when FIFO drains |
| 6 | `full_empty_mutex_test` | `o_full` and `o_empty` are never both high at once |
| 7 | `pointer_wraparound_test` | Run enough traffic to wrap the read/write pointers at least twice |
| 8 | `full_empty_toggle_test` | Repeatedly fill/drain the FIFO at every clock ratio from Section 3 |
| 9 | `random_traffic_test` | Randomized bursts of writes/reads, random delays, random clock ratio — the main stress test |
| 10 | `boundary_1_entry_test` | Write and read happen on the same cycle when FIFO has exactly 1 entry — trickiest corner case |
| 11 | `depth_sweep_test` | Re-run core tests at DEPTH = 2, 4, 8, 16, 32 |
| 12 | `width_sweep_test` | Re-run core tests at DATA_WIDTH = 1, 4, 8, 32 |
| 13 | `bad_depth_test` | Instantiate with a non-power-of-2 DEPTH, confirm it errors out at elaboration |
| 14 | `sync_latency_test` | Confirm the 2-flop synchronizer takes exactly 2 destination-clock cycles |

---

## 5. Functional Coverage — what "done" looks like

We track coverage on these areas, and don't call verification complete until all bins are hit:

- **FIFO occupancy:** empty, almost-empty, mid-range, almost-full, full
- **Flag transitions:** empty→not-empty, not-empty→empty, full→not-full, not-full→full — each one crossed with every clock ratio from Section 3
- **Pointer wraparound:** 0 wraps, 1 wrap, 2+ wraps (need to hit 2+)
- **Reset combinations:** write-only reset, read-only reset, both together, both skewed
- **Simultaneous write+read:** especially at the 1-entry boundary
- **Clock ratio:** all four cases from Section 3

---

## 6. Assertions (SVA) — the "never let this happen" checks

These get written as a separate bind-in checker file, not stuffed inside the RTL itself. That way they're reusable and don't clutter the design.

- No write pointer movement while `o_full` is asserted and a write is attempted (write must be blocked, not silently dropped)
- No read pointer movement while `o_empty` is asserted and a read is attempted
- Gray-coded pointers only ever change **one bit per clock edge** (this is what makes the CDC crossing safe in the first place)
- `o_full` and `o_empty` are never unknown (X/Z) after reset
- DEPTH must be a power of 2 — checked at elaboration time, fails the build otherwise

---

## 7. Things simulation alone can't catch (do these too)

Simulation proves the *logic* is correct, but this is a clock-domain-crossing design, so a few extra checks matter:

- **Run a CDC lint tool** (e.g. Spyglass CDC, Questa CDC) to confirm only the Gray-coded pointer bits cross domains through the synchronizers — nothing else should be crossing unsynchronized.
- **Double check the reset structure**: each synchronizer must be reset only by its *own* domain's reset, never by the other domain's reset. This avoids a reset-removal CDC hazard. This is called out in the DUT spec itself — worth explicitly re-confirming in the RTL, not just assuming it's right.
- Optional but nice to have: run formal verification on just the full/empty flag logic. It's a small, bounded state machine, so formal tools handle it well and can exhaustively prove there's no way to see `o_full` and `o_empty` high at the same time.

---

## 8. Sign-off Checklist

- [ ] All directed tests (1–8, 10, 13, 14) passing
- [ ] Parameter sweeps (11, 12) passing with zero failures
- [ ] Random test (9) run across 50+ seeds, all 4 clock ratios, zero failures
- [ ] 100% functional coverage closure
- [ ] 100% assertion coverage
- [ ] CDC lint clean (no unwaived violations)
- [ ] Code coverage ≥ 95% (secondary metric, not a hard gate for a design this size)

---

## 9. Notes for anyone extending this testbench

- Use two separate interfaces (`wr_if`, `rd_if`) instead of one shared interface with both clocks — much cleaner clocking-block behavior per domain.
- If you need to probe inside `ff_sync` for the synchronizer latency check, prefer a `bind`-based checker over hierarchical references (`tb_top.dut.wr_ff.f1`) — hierarchical paths break the moment someone renames a signal.
- This plan is written to translate directly into an EDA Playground package — keep the assertion/bind file separate from the DUT source so it stays portable.
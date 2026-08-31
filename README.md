# FPGA Coffee Vending Machine — Moore FSM Controller

## Overview

A finite state machine (FSM) controller for a coin-operated coffee vending machine, implemented in Verilog and simulated on an Intel FPGA toolchain (Quartus/Questa). The machine accepts nickels (5¢) and dimes (10¢) only, dispenses coffee once 15¢ has been deposited, and signals change if more than 15¢ is entered. This is a Moore machine: outputs depend only on the current state, not on the inputs directly.

Based on ECEN 21L Lab 8 (Santa Clara University), an extension of Example 8.7 in *Fundamentals of Digital Logic Design with Verilog* (Brown & Vranesic, 3rd ed).

## Problem Specification

- Inputs: `N` (nickel sensor, active-high), `D` (dime sensor, active-high) — never asserted simultaneously
- Outputs: `O` (Open/dispense coffee), `C` (Change)
- Coffee costs 15¢; the machine tracks balance across 5 states

| State | Balance | O (Open) | C (Change) |
|-------|---------|----------|------------|
| S0    | 0¢      | 0        | 0          |
| S5    | 5¢      | 0        | 0          |
| S10   | 10¢     | 0        | 0          |
| S15   | 15¢     | 1        | 0          |
| S20   | 20¢     | 1        | 1          |

## Design Process

1. State diagram derived from the spec (5 states, transitions on N/D)
2. State transition table (current state × input → next state)
3. State encoding (3 bits, `S[2:0]`) — chosen to minimize output logic gate count
4. Boolean equation minimization for `S*[2:0]`, `O`, `C` via K-maps
5. Two parallel Verilog implementations of the same FSM, to compare design styles

## Two Implementation Approaches

This project intentionally implements the same FSM two different ways, to compare them directly:

- **`module1.txt` → `lab8.v` (equation-based):** Next-state and output logic written as minimized Boolean `assign` statements derived from K-maps. Tests whether manual logic minimization is correct.
- **`module2.txt` → `lab8.v` (behavioral/case-based):** Same FSM written with `case` statements in `always` blocks instead of minimized equations. Tests whether both descriptions produce identical simulation results — if they don't, either the K-map minimization or the case logic has an error.

Both must be simulated against the same testbench and produce identical `O`, `C`, `S` trajectories.

## Files

| File | Purpose |
|------|---------|
| `module1.txt` | Equation-based FSM description — **`assign` statements for `S*[2:0]`, `O`, `C` not yet filled in** |
| `module2.txt` | Case-based FSM description — **`S5`, `S10`, `S20` next-state cases and `S5`/`S10`/`S15`/`S20` output cases not yet filled in** |
| `tb_for_lab8.v` | Provided testbench. Drives `Clock` (10-unit period), asserts `Reset`, then runs sequence: Reset → Nickel → Nickel → Nickel → (idle) |

## Ports

| Port | Direction | Description |
|------|-----------|--------------|
| `Clock` | input | positive-edge clock |
| `Reset` | input | positive-edge reset, forces `S = 000` |
| `N` | input | nickel sensor (active-high) |
| `D` | input | dime sensor (active-high) |
| `O` | output | Open/dispense coffee |
| `C` | output | Change owed |
| `S[2:0]` | output | current state (exposed for debugging) |

## TODO (before this is a complete/portfolio-ready project)

- [ ] Complete state encoding for `S10`, `S15`, `S20` (currently only `S0=000`, `S5=001` are fixed)
- [ ] Derive and fill in minimized Boolean equations for `S*[2:0]`, `O`, `C` in `module1.txt`
- [ ] Fill in `case` branches for `S5`, `S10`, `S20` next-state logic and `S5`/`S10`/`S15`/`S20` output logic in `module2.txt`
- [ ] Run RTL simulation (Questa) for the provided test sequence (Reset → N → N → N) and confirm `O`/`C`/`S` match the expected balance progression
- [ ] Modify the testbench to cover 3 additional required scenarios: Reset→N→N→D, Reset→D→D, Reset→N→D
- [ ] Confirm both implementations (`module1` and `module2`) produce identical results across all 4 test sequences
- [ ] Answer the lab report questions (pre-lab correctness, which implementation style is more productive, and how the design would change to accept pennies/quarters/dollar bills)

## How to Run

1. Open the Quartus project, create `lab8.v` from `module1.txt` (or `module2.txt`)
2. `Assignment → Settings → EDA Tool Settings → Simulation`, set Tool Name to `Questa Intel FPGA`
3. Add `tb_for_lab8.v` as the testbench under NativeLink settings (Top level module: `tb`)
4. `Tools → Run Simulation Tool → RTL Simulation` (not Gate Level)
5. Verify `O`, `C`, `S` waveforms against the expected state progression for each test scenario

## Notes

This lab is simulation-only (no FPGA hardware deployment) — verification is done entirely via RTL simulation against the testbench, which is a useful contrast to Lab 3 (schematic + hardware deployment on the DE2-115 board).

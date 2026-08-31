# Coffee Vending Machine — Moore FSM Controller

Status: **Complete** — both implementations verified against 4 simulation test cases.

## Overview

A finite state machine (FSM) controller for a coin-operated coffee vending machine, implemented in Verilog and simulated on an Intel FPGA toolchain (Quartus/Questa). The machine accepts nickels (5¢) and dimes (10¢) only, dispenses coffee once 15¢ has been deposited, and signals change if more than 15¢ is entered. This is a Moore machine: outputs depend only on the current state, not on the inputs directly.

Based on ECEN 21L Lab 8 (Santa Clara University), an extension of Example 8.7 in *Fundamentals of Digital Logic Design with Verilog* (Brown & Vranesic, 3rd ed).

## Problem Specification

- Inputs: `N` (nickel sensor, active-high), `D` (dime sensor, active-high) — never asserted simultaneously
- Outputs: `O` (Open/dispense coffee), `C` (Change)
- Coffee costs 15¢; the machine tracks balance across 5 states

| State | Balance | S[2:0] | O (Open) | C (Change) |
|-------|---------|--------|----------|------------|
| S0    | 0¢      | 000    | 0        | 0          |
| S5    | 5¢      | 001    | 0        | 0          |
| S10   | 10¢     | 010    | 0        | 0          |
| S15   | 15¢     | 110    | 1        | 0          |
| S20   | 20¢     | 111    | 1        | 1          |

The encoding is deliberately non-sequential: `S[2]` is 1 only for the two dispensing states, and `S[0]` is additionally 1 only for S20. That makes the output logic collapse to two single-gate expressions:

```
O = S[2]
C = S[2] & S[0]
```

## Design Process

1. State diagram derived from the spec (5 states, transitions on N/D)
2. State transition table (current state × input → next state)
3. State encoding (3 bits, `S[2:0]`) — chosen to minimize output logic gate count
4. Boolean equation minimization for `S*[2:0]`, `O`, `C` via K-maps
5. Two parallel Verilog implementations of the same FSM, to compare design styles

## Two Implementation Approaches

This project intentionally implements the same FSM two different ways, to compare them directly:

- **`coffee_fsm_equations.v` (equation-based):** Next-state and output logic written as minimized Boolean `assign` statements derived from K-maps. Tests whether manual logic minimization is correct.
- **`coffee_fsm_case.v` (behavioral/case-based):** Same FSM written with `case` statements in `always` blocks instead of minimized equations. Tests whether both descriptions produce identical simulation results — if they don't, either the K-map minimization or the case logic has an error.

Both must be simulated against the same testbench and produce identical `O`, `C`, `S` trajectories.

## Files

| File | Purpose |
|------|---------|
| `coffee_fsm_equations.v` | Equation-based FSM description (`assign` statements for `S*[2:0]`, `O`, `C`) |
| `coffee_fsm_case.v` | Case-based FSM description (`case`/`always` blocks for next-state and output logic) |
| `tb_coffee_fsm.v` | Testbench. Drives `Clock` (10-unit period), asserts `Reset`, then runs sequence: Reset → Nickel → Nickel → Nickel → (idle) |

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

## Verification & Results

Both implementations were simulated (RTL simulation, Questa Intel FPGA Starter Edition) against four coin sequences and checked against the full state transition table, not just the waveforms:

| Test | Coins | Expected path | Final output |
|------|-------|----------------|---------------|
| 1 | N, N, N | S0→S5→S10→S15 | O=1, C=0 |
| 2 | N, N, D | S0→S5→S10→S20 | O=1, C=1 |
| 3 | D, D | S0→S10→S20 | O=1, C=1 |
| 4 | N, D | S0→S5→S15 | O=1, C=0 |

All four passed for both `coffee_fsm_equations.v` and `coffee_fsm_case.v`, with identical `O`, `C`, and `S` trajectories between the two implementations. Key behaviors confirmed:

- Reset drives `S` to `000` in both versions
- Outputs trail the coin pulse by exactly one clock edge — they reflect the *stored* state, not the raw input, which is the expected and correct behavior for a Moore machine (e.g. in Test 1, `O` only goes high on the edge after the third nickel lands the FSM in S15, not during that coin pulse)
- Both dispensing states (S15, S20) return to S0 on the next no-coin cycle, clearing outputs before the next transaction
- `ND=11` never appears in any test and is correctly treated as don't-care throughout

**Implementation comparison:** the case-statement version (`coffee_fsm_case.v`) proved more useful for verifying against the spec — each state is its own block and each valid input points to a named next state, so checking correctness is a direct line-by-line comparison against the transition table. The equation-based version (`coffee_fsm_equations.v`) is more compact and closer to actual gate-level hardware, but verifying it requires manually evaluating each Boolean expression for every state, which is slower and more error-prone.

## How to Run

1. Open the Quartus project and add `coffee_fsm_equations.v` (or `coffee_fsm_case.v`) as the design file
2. `Assignment → Settings → EDA Tool Settings → Simulation`, set Tool Name to `Questa Intel FPGA`
3. Add `tb_coffee_fsm.v` as the testbench under NativeLink settings (Top level module: `tb`)
4. `Tools → Run Simulation Tool → RTL Simulation` (not Gate Level)
5. Verify `O`, `C`, `S` waveforms against the expected state progression for each test scenario

## Notes

This lab is simulation-only (no FPGA hardware deployment) — verification is done entirely via RTL simulation against the testbench, which is a useful contrast to Lab 3 (schematic + hardware deployment on the DE2-115 board).

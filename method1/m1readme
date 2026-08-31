# Method 1 — Boolean Equation Implementation

File: `coffee_fsm_equations.v`

## What this is

This version implements the coffee vending FSM using minimized Boolean equations, written as continuous `assign` statements. The state register is still a flip-flop block (clocked, synchronous), but everything driving the next state (`S*`) and the outputs (`O`, `C`) is pure combinational logic — each `assign` line corresponds directly to a set of AND/OR/NOT gates. This is about as close to gate-level design as Verilog gets without instantiating gate primitives directly.

## How the logic was derived

1. Built the state transition table (current state × N/D input → next state)
2. Chose a non-sequential 3-bit state encoding specifically to minimize the output logic:
   - `S[2]` is 1 only in the two dispensing states (S15, S20)
   - `S[0]` is additionally 1 only in S20
   - This makes `O = S[2]` and `C = S[2] & S[0]` — two single-gate outputs
3. Used K-maps (with `ND=11` treated as don't-care, since N and D are never asserted together) to minimize `S*[2]`, `S*[1]`, `S*[0]` down to their smallest Boolean forms

## The equations

```
S*[2] = (~S[2] & ~S[1] & S[0] & D) | (~S[2] & S[1] & ~S[0] & (N | D))
S*[1] = ~S[2] & (S[1] | D | (S[0] & N))
S*[0] = (~S[2] & ~S[1] & ~D & (S[0] ^ N)) | (~S[2] & S[1] & D)
O     = S[2]
C     = S[2] & S[0]
```

## Tradeoff

This form is compact and efficient — few gates, minimal logic depth — but it's not very readable. Confirming correctness means mentally evaluating each Boolean expression for every reachable state; there's no direct visual correspondence between the code and the state diagram. See Method 2 (`coffee_fsm_case.v`) for the more spec-readable alternative, which was verified to produce identical simulation results across all 4 test cases.


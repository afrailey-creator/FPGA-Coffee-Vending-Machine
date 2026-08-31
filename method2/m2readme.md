# Method 2 — Case-Statement Implementation

File: `coffee_fsm_case.v`

## What this is

This version implements the same coffee vending FSM as Method 1, but describes it behaviorally instead of as minimized gate equations. Each state is its own `case` branch inside an `always` block, and each valid input combination within that branch points to the next state by name (`S5`, `S10`, etc.) rather than by raw bit pattern. It's longer than the equation-based version, but it maps directly onto the state diagram and transition table.

## Structure

- State encoding is declared with named `parameter`s (`S0=3'b000`, `S5=3'b001`, `S10=3'b010`, `S15=3'b110`, `S20=3'b111`) instead of being buried in bit-level equations
- Next-state logic: one `always @(S, N, D)` block with a `case(S)` that lists every valid transition explicitly (e.g. `S5: if (!N && D) S_star = S15;`)
- Output logic: a separate `always @(S)` block with a `case(S)` that sets `O`/`C` directly per state — no derived equations, since this is a Moore machine and outputs depend only on current state

## Tradeoff

This version is more useful for verification against the spec: checking correctness means finding the row in the transition table, finding the matching `case` branch, and confirming the assignment — a direct line-by-line comparison. It's less gate-efficient and less "close to hardware" than Method 1, but for anything specification-first, the extra lines are a small price for readability.

Both `coffee_fsm_case.v` and `coffee_fsm_equations.v` were simulated against the same testbench (`tb_coffee_fsm.v`) across 4 coin sequences and produced identical `O`, `C`, and `S` results.

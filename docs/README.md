PCIe test plan, verification strategy, and coverage goals
# PCIe Verification Test Plan (UVM)

This document outlines the verification strategy for a simplified PCIe Transaction Layer model using a UVM-based testbench.
Goal: validate correct TLP construction/parsing, ordering rules, credit-based flow control behavior (modeled), and robust error handling.

---

## 1. DUT Scope (Simplified Model)
This repository verifies a learning-focused PCIe model (not production IP). The design scope includes:
- Transaction Layer Packet (TLP) generation and reception (modeled)
- Basic request/completion transactions (MemRd/MemWr + CplD)
- Header field correctness and payload handling
- Sequence ordering and protocol sanity checks (simplified)
- Flow control / backpressure modeled at interface level (non-physical)

Out of scope:
- Physical Layer, LTSSM, equalization, electrical compliance
- Full Data Link Layer (LCRC/DLLP) details (may be stubbed)
- Multi-lane timing closure, real PHY behavior

---

## 2. Testbench Strategy (UVM)
Verification uses a layered UVM environment with:
- **Agent(s):** driver, monitor, sequencer
- **Scoreboard:** end-to-end checking for expected request/completion behavior
- **Assertions (SVA):** handshake, stability, packet-format rules
- **Functional coverage:** packet types, address alignment, boundary cases, error injection

Primary goals:
- Catch protocol/formatting violations early via assertions
- Ensure scenario breadth via constrained-random + functional coverage
- Provide fast debug using transaction logs + waveform visibility

---

## 3. Stimulus Plan (Directed + Constrained-Random)

### 3.1 Directed Tests (Bring-up)
1. Reset + basic initialization sequence
2. Single Memory Write (MemWr) with aligned address
3. Single Memory Read (MemRd) followed by valid Completion with Data (CplD)
4. Back-to-back writes and reads (no idle cycles)
5. Small payload vs. max payload (within model limits)

### 3.2 Constrained-Random Tests (Coverage Closure)
Randomize the following (within legal constraints):
- TLP type: MemRd / MemWr / Cpl / CplD
- Address alignment (aligned + misaligned where applicable)
- Payload size (0..N DW)
- Tag values (unique vs reused)
- Traffic patterns: bursts, mixed read/write streams
- Backpressure insertion (ready deassertion / delayed completion)
- Reordering scenarios (if model supports out-of-order completion)

---

## 4. Checkers / Scoreboard Plan
Scoreboard responsibilities:
- Track outstanding requests by **Tag**
- Match completions to requests (type, tag, length)
- Validate payload integrity for writes/reads (data compare vs expected model)
- Detect dropped/duplicated TLPs
- Validate ordering rules (in-order completion if model requires it)

Expected checks:
- Correct mapping: request -> completion
- Completion status correctness (success/UR/CA if modeled)
- No completion without a request
- No tag collisions beyond allowed reuse window

---

## 5. Assertion Plan (SVA)
Assertions will focus on:
- Interface handshake correctness (VALID/READY stability)
- Packet field stability when VALID is asserted and READY is low
- Legal TLP formatting (header fields present, length non-zero when required)
- Tag validity and reuse rules (within scoreboard window)
- Completion must correspond to an outstanding request

Example categories:
- Handshake: `valid && !ready |-> $stable(pkt)`
- Formatting: `tlp_type == MEMRD |-> length > 0`
- Matching: `cpl_valid |-> outstanding[tag] == 1`

(Assertions will be implemented under `assertions/`.)

---

## 6. Functional Coverage Plan
Covergroups will measure:
- TLP types covered (MemRd/MemWr/Cpl/CplD)
- Address classes: aligned/misaligned, low/high ranges (bucketed)
- Length bins: 0DW / 1DW / small / medium / max (model-defined)
- Tag bins: min/mid/max and reuse behavior
- Backpressure bins: no stall / short stall / long stall
- Error bins: malformed packet / unsupported request (if modeled)

Exit criteria:
- Cover all major TLP types
- Hit all length and address bins
- Demonstrate backpressure handling
- Close key cross coverage: (type x length), (type x backpressure)

---

## 7. Regression Plan
Regression will run:
- Directed bring-up suite
- Random suite with multiple seeds
- Error-injection tests (if supported)

Outputs tracked:
- Pass/fail summary
- Assertion failures (must be zero for pass)
- Functional coverage trend (target: steady improvement)

---

## 8. Deliverables
- UVM testbench skeleton with agent + scoreboard
- Assertion module(s) for protocol rules
- Functional coverage model
- Regression script template (Questa/VCS friendly)
- Documentation (this test plan + coverage plan)

---

## 9. Notes
This project is intended for learning and demonstration. All RTL/testbench code is self-written and does not contain proprietary IP.

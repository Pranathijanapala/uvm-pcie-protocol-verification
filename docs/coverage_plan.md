# PCIe Verification Coverage Plan

This document describes the functional coverage strategy for the
simplified PCIe Transaction Layer verification environment.

The goal is to ensure adequate stimulus breadth across packet types,
addressing behavior, flow control scenarios, and protocol corner cases.

---

## 1. Coverage Objectives
- Exercise all supported PCIe Transaction Layer Packet (TLP) types
- Validate address alignment and payload length combinations
- Observe behavior under backpressure and stall conditions
- Ensure completion responses are generated and matched correctly
- Drive protocol corner cases using constrained-random stimulus

---

## 2. Functional Coverage Model

### 2.1 TLP Type Coverage
Cover all supported packet types:
- Memory Read (MemRd)
- Memory Write (MemWr)
- Completion (Cpl)
- Completion with Data (CplD)

**Goal:** Each TLP type observed multiple times in regression.

---

### 2.2 Address Coverage
Address space will be bucketed to capture:
- Aligned addresses (DW-aligned)
- Misaligned addresses (if supported by model)
- Low address range
- Mid address range
- High address range

**Goal:** Hit all address buckets across read and write traffic.

---

### 2.3 Length Coverage
Payload length (DW) bins:
- Zero length (valid only for specific packet types)
- Small payloads
- Medium payloads
- Maximum payload supported by model

**Goal:** Ensure legal length combinations are exercised per TLP type.

---

### 2.4 Tag Coverage
Track request tags to verify:
- Unique tag usage
- Tag reuse after completion
- Multiple outstanding tags (if supported)

**Goal:** Observe legal tag reuse behavior without collisions.

---

### 2.5 Backpressure / Stall Coverage
Capture interface behavior under:
- No stall (ready always high)
- Short stall (1–2 cycles)
- Long stall (multi-cycle ready deassertion)

**Goal:** Ensure protocol correctness during stalled transfers.

---

## 3. Cross Coverage

Key cross coverage points:
- TLP Type × Payload Length
- TLP Type × Address Alignment
- TLP Type × Backpressure Scenario
- Completion Type × Status (if modeled)

**Goal:** Demonstrate that different packet types behave correctly
under varying traffic and flow-control conditions.

---

## 4. Assertion Coverage
Assertions are used to complement functional coverage:
- Handshake stability (VALID/READY)
- Packet field stability during stalls
- Legal packet formatting rules
- Completion-to-request matching rules

**Goal:** Zero assertion failures for legal traffic during regression.

---

## 5. Coverage Closure Strategy
Coverage will be improved by:
- Increasing constrained-random iterations
- Adjusting random distributions to target uncovered bins
- Adding directed tests for hard-to-hit scenarios

Exit criteria:
- All major TLP types observed
- All primary coverage bins hit
- No outstanding critical coverage holes

---

## 6. Notes
This coverage plan is designed for a simplified, educational PCIe model.
Coverage metrics are used to guide stimulus quality rather than enforce
production signoff thresholds.

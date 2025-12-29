//============================================================
// pcie_sva.sv
// Simplified PCIe-style protocol assertions (educational)
// Focus: handshake stability + basic TLP format sanity checks
//============================================================

`ifndef PCIE_SVA_SV
`define PCIE_SVA_SV

module pcie_sva #(
  parameter int ADDR_W = 32,
  parameter int LEN_W  = 10,   // length in DW (example)
  parameter int TAG_W  = 8
)(
  input  logic                clk,
  input  logic                rst_n,

  // Simplified "TLP-like" interface (transaction-level model)
  input  logic                tlp_valid,
  input  logic                tlp_ready,

  input  logic [2:0]          tlp_type,     // 0:MemRd, 1:MemWr, 2:Cpl, 3:CplD (example encoding)
  input  logic [ADDR_W-1:0]   tlp_addr,
  input  logic [LEN_W-1:0]    tlp_len_dw,
  input  logic [TAG_W-1:0]    tlp_tag,

  // Optional status for completions (if your model has it; keep tied-off if not used)
  input  logic [1:0]          cpl_status    // 0:SC, 1:UR, 2:CA, 3:RSVD (example)
);

  // ----------------------------
  // Local type encodings (edit if your DUT uses different encodings)
  // ----------------------------
  localparam logic [2:0] TLP_MEMRD = 3'd0;
  localparam logic [2:0] TLP_MEMWR = 3'd1;
  localparam logic [2:0] TLP_CPL   = 3'd2;
  localparam logic [2:0] TLP_CPLD  = 3'd3;

  // ----------------------------
  // Helper: when transfer is "accepted"
  // ----------------------------
  wire tlp_fire = tlp_valid && tlp_ready;

  //============================================================
  // 1) Handshake/Interface Assertions
  //============================================================

  // A1: VALID must not be X/Z (basic sanity)
  assert_valid_known: assert property (@(posedge clk) disable iff (!rst_n)
    !$isunknown(tlp_valid)
  ) else $error("SVA: tlp_valid is X/Z");

  // A2: READY must not be X/Z
  assert_ready_known: assert property (@(posedge clk) disable iff (!rst_n)
    !$isunknown(tlp_ready)
  ) else $error("SVA: tlp_ready is X/Z");

  // A3: If VALID is high and READY is low, payload/control must remain stable
  // (classic ready/valid stability rule)
  assert_stable_on_stall: assert property (@(posedge clk) disable iff (!rst_n)
    (tlp_valid && !tlp_ready) |=> $stable({tlp_type, tlp_addr, tlp_len_dw, tlp_tag, cpl_status})
  ) else $error("SVA: TLP fields changed while stalled (valid=1, ready=0)");

  // A4: Once VALID is asserted, it should remain asserted until accepted (optional policy)
  // If your DUT allows withdrawing VALID, comment this out.
  assert_valid_until_fire: assert property (@(posedge clk) disable iff (!rst_n)
    (tlp_valid && !tlp_ready) |=> tlp_valid
  ) else $error("SVA: tlp_valid deasserted before transfer completed");

  //============================================================
  // 2) Basic TLP Format Sanity Checks (simplified)
  //============================================================

  // A5: TLP type must be one of supported encodings when accepted
  assert_type_legal: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire |-> (tlp_type inside {TLP_MEMRD, TLP_MEMWR, TLP_CPL, TLP_CPLD})
  ) else $error("SVA: Illegal tlp_type observed on acceptance");

  // A6: Memory Read/Write must have non-zero length (DW)
  assert_len_nonzero_for_mem: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire && (tlp_type inside {TLP_MEMRD, TLP_MEMWR}) |-> (tlp_len_dw != '0)
  ) else $error("SVA: MemRd/MemWr with zero length");

  // A7: Completion-with-data should have non-zero length
  assert_len_nonzero_for_cpld: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire && (tlp_type == TLP_CPLD) |-> (tlp_len_dw != '0)
  ) else $error("SVA: CplD with zero length");

  // A8: Completion-without-data should typically have zero length (model rule)
  // If your model allows non-zero, comment this out.
  assert_cpl_len_zero: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire && (tlp_type == TLP_CPL) |-> (tlp_len_dw == '0)
  ) else $error("SVA: Cpl (no data) has non-zero length");

  // A9: Address alignment rule (example): DW-aligned for mem transactions
  // If you want byte addressing, adjust alignment accordingly.
  assert_addr_aligned: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire && (tlp_type inside {TLP_MEMRD, TLP_MEMWR}) |-> (tlp_addr[1:0] == 2'b00)
  ) else $error("SVA: Mem transaction address not DW-aligned");

  //============================================================
  // 3) Completion Status Sanity (optional)
  //============================================================

  // A10: Completion status must be legal when completion is accepted
  assert_cpl_status_legal: assert property (@(posedge clk) disable iff (!rst_n)
    tlp_fire && (tlp_type inside {TLP_CPL, TLP_CPLD}) |-> (cpl_status inside {2'd0,2'd1,2'd2})
  ) else $error("SVA: Illegal completion status");

endmodule

`endif

//============================================================
// pcie_tlp_stub.sv
// Simplified PCIe Transaction Layer stub (educational)
//
// This is NOT a real PCIe implementation.
// It exists only to act as a DUT for verification bring-up.
//============================================================

`timescale 1ns/1ps

module pcie_tlp_stub #(
  parameter int ADDR_W = 32,
  parameter int LEN_W  = 10,
  parameter int TAG_W  = 8
)(
  input  logic                clk,
  input  logic                rst_n,

  // Input TLP-like interface
  input  logic                tlp_valid,
  output logic                tlp_ready,
  input  logic [2:0]          tlp_type,
  input  logic [ADDR_W-1:0]   tlp_addr,
  input  logic [LEN_W-1:0]    tlp_len_dw,
  input  logic [TAG_W-1:0]    tlp_tag,
  input  logic [1:0]          cpl_status
);

  // Simple ready generation (always ready after reset)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      tlp_ready <= 1'b0;
    else
      tlp_ready <= 1'b1;
  end

  // NOTE:
  // No internal storage or protocol behavior is modeled.
  // This stub simply accepts transactions when ready/valid handshake occurs.

endmodule

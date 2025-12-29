//============================================================
// top_tb.sv
// Simplified top-level testbench wrapper (educational)
// - Declares a TLP-like interface
// - Instantiates DUT (placeholder)
// - Instantiates SVA module from assertions/pcie_sva.sv
// - Provides minimal clock/reset + basic directed stimulus
//============================================================

`timescale 1ns/1ps

module top_tb;

  // ----------------------------
  // Parameters (keep consistent with pcie_sva)
  // ----------------------------
  localparam int ADDR_W = 32;
  localparam int LEN_W  = 10;
  localparam int TAG_W  = 8;

  // ----------------------------
  // Clock / Reset
  // ----------------------------
  logic clk;
  logic rst_n;

  initial clk = 0;
  always #5 clk = ~clk;  // 100 MHz

  initial begin
    rst_n = 0;
    repeat (5) @(posedge clk);
    rst_n = 1;
  end

  // ----------------------------
  // Simplified "TLP-like" channel signals
  // ----------------------------
  logic              tlp_valid;
  logic              tlp_ready;
  logic [2:0]        tlp_type;
  logic [ADDR_W-1:0] tlp_addr;
  logic [LEN_W-1:0]  tlp_len_dw;
  logic [TAG_W-1:0]  tlp_tag;
  logic [1:0]        cpl_status;

  // ----------------------------
  // DUT placeholder (replace with your real model later)
  // For now, we model READY and accept traffic
  // ----------------------------
  initial begin
    tlp_ready  = 0;
    wait (rst_n);
    repeat (2) @(posedge clk);
    tlp_ready  = 1;
  end

  // ----------------------------
  // Instantiate Assertions (SVA)
  // ----------------------------
  pcie_sva #(
    .ADDR_W(ADDR_W),
    .LEN_W (LEN_W),
    .TAG_W (TAG_W)
  ) u_pcie_sva (
    .clk        (clk),
    .rst_n      (rst_n),
    .tlp_valid  (tlp_valid),
    .tlp_ready  (tlp_ready),
    .tlp_type   (tlp_type),
    .tlp_addr   (tlp_addr),
    .tlp_len_dw (tlp_len_dw),
    .tlp_tag    (tlp_tag),
    .cpl_status (cpl_status)
  );

  // ----------------------------
  // Minimal stimulus (directed smoke tests)
  // These are NOT UVM sequences yet—just bring-up.
  // Later, replace this block with UVM run_test().
  // ----------------------------
  task automatic send_tlp(
    input logic [2:0]        t_type,
    input logic [ADDR_W-1:0] t_addr,
    input logic [LEN_W-1:0]  t_len_dw,
    input logic [TAG_W-1:0]  t_tag,
    input logic [1:0]        t_status
  );
    // drive request
    @(posedge clk);
    tlp_type   <= t_type;
    tlp_addr   <= t_addr;
    tlp_len_dw <= t_len_dw;
    tlp_tag    <= t_tag;
    cpl_status <= t_status;
    tlp_valid  <= 1'b1;

    // wait until accepted
    while (!(tlp_valid && tlp_ready)) @(posedge clk);

    // deassert after handshake
    @(posedge clk);
    tlp_valid  <= 1'b0;
  endtask

  // Encodings (must match pcie_sva)
  localparam logic [2:0] TLP_MEMRD = 3'd0;
  localparam logic [2:0] TLP_MEMWR = 3'd1;
  localparam logic [2:0] TLP_CPL   = 3'd2;
  localparam logic [2:0] TLP_CPLD  = 3'd3;

  initial begin
    // init defaults
    tlp_valid  = 0;
    tlp_type   = '0;
    tlp_addr   = '0;
    tlp_len_dw = '0;
    tlp_tag    = '0;
    cpl_status = '0;

    wait (rst_n);

    // Smoke test 1: MemWr (DW aligned, non-zero length)
    send_tlp(TLP_MEMWR, 32'h0000_1000, 10'd4, 8'h01, 2'd0);

    // Smoke test 2: MemRd (DW aligned, non-zero length)
    send_tlp(TLP_MEMRD, 32'h0000_2000, 10'd2, 8'h02, 2'd0);

    // Smoke test 3: Completion w/ Data (non-zero length)
    send_tlp(TLP_CPLD,  32'h0000_0000, 10'd2, 8'h02, 2'd0);

    // Smoke test 4: Completion (no data, zero length)
    send_tlp(TLP_CPL,   32'h0000_0000, 10'd0, 8'h03, 2'd0);

    // End
    repeat (10) @(posedge clk);
    $display("[TB] Smoke tests completed.");
    $finish;
  end

endmodule

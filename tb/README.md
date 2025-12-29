# Testbench (tb)

This folder contains the verification top and (future) UVM components.

Files:
- `top_tb.sv` : Top-level TB wrapper that instantiates the simplified TLP interface and binds `pcie_sva` assertions.

Next planned additions:
- UVM agent (driver/monitor/sequencer)
- Scoreboard + reference model
- Constrained-random sequences + functional coverage

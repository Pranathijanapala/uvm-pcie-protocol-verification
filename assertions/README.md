SystemVerilog Assertions for PCIe protocol checks
# Assertions (SVA)

This folder contains SystemVerilog Assertions used to validate simplified PCIe-style protocol rules.

Files:
- `pcie_sva.sv` : Handshake stability checks + basic TLP format sanity assertions

How to use:
- Bind or instantiate `pcie_sva` in your testbench top (tb) and connect it to your TLP-like interface signals.

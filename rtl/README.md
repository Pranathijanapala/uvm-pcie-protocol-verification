# RTL Stub (Educational)

This folder contains a simplified PCIe Transaction Layer stub used
purely as a DUT for verification bring-up.

Files:
- `pcie_tlp_stub.sv` : Minimal ready/valid-based TLP sink

Notes:
- This is NOT a real PCIe implementation
- No PHY, DLL, or LTSSM behavior is modeled
- Intended only to support testbench and assertion development


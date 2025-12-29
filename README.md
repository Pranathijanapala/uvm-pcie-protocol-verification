# UVM-Based PCIe Protocol Verification (Educational)

This project demonstrates a verification-oriented setup for a **simplified PCIe Transaction Layer model** using **SystemVerilog**, with an emphasis on:
- **Protocol/packet sanity checking using SVA**
- **Reusable verification structure (tb/rtl/docs/assertions)**
- **Regression readiness and documentation**

> Note: This repository is intentionally **non-proprietary** and **educational**.  
> It does not include production PCIe IP, PHY, LTSSM, or full DLL behavior.

---

## What’s Implemented Today
✅ Clean repository structure aligned with DV workflows  
✅ PCIe-oriented **test plan** (`docs/README.md`)  
✅ Starter **SVA assertion suite** (`assertions/pcie_sva.sv`)  
✅ Bring-up **top-level testbench** (`tb/top_tb.sv`) that instantiates assertions  
✅ Minimal directed smoke tests (ready/valid + basic TLP scenarios)

---

## Simplified Interface Model
The verification targets a simplified “TLP-like” channel with:
- `tlp_valid / tlp_ready` handshake  
- `tlp_type, tlp_addr, tlp_len_dw, tlp_tag` fields  
- optional `cpl_status` for completion packets

Encodings (current):
- `0: MemRd`
- `1: MemWr`
- `2: Cpl`
- `3: CplD`

(These can be updated to match a future RTL model.)

---

## Repository Layout

# axon-fpga

FPGA DMA engine (SystemVerilog), its bare-metal driver (C) and host SDK (Python).
- RTL lives in rtl/, formal harnesses in formal/, firmware in fw/, host SDK in host/.
- Keep the driver free of direct MMIO; go through axon_hal.h.

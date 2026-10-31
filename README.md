# axon-fpga

Descriptor-driven DMA engine for the Axon card.

- `rtl/`: SystemVerilog: register file (clk_axi), engine (clk_core), CDC, FIFO
- `formal/`: formal harnesses
- `fw/`: bare-metal driver and smoke test
- `host/`: Python host SDK
- `docs/axon_dma_spec.md`: interface specification

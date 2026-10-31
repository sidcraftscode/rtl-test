# Axon DMA: interface specification (rev 1.4)

The Axon card moves data between host buffers using a descriptor-driven DMA
engine. Firmware programs it through a register bus; descriptors live in
memory and are fetched by the engine.

## 1. Clocks
| Clock     | Period | Owns                                  |
|-----------|--------|---------------------------------------|
| clk_axi   | 8 ns   | register bus, interrupt               |
| clk_core  | 4 ns   | descriptor fetch, data movement, FIFO |

Every signal crossing between the two domains must go through `cdc_sync2`,
`cdc_pulse`, or be qualified by a synchronized strobe while held stable.

## 2. Register map
`rtl/axon_regs_pkg.sv` is the source of truth. `fw/include/axon_regs.h` must
match it bit for bit.

## 3. Descriptor and buffering
### 3.1 Descriptor
`axon_desc_pkg::dma_desc_t`, fetched as little-endian 32-bit words; the least
significant field is at byte offset 0. Firmware's `struct axon_dma_desc` must
have identical size, offsets and widths.

### 3.2 Beat buffer semantics
`sync_fifo` accepts a write when `wr_en && !full` and a read when
`rd_en && !empty`. Accepted words are returned in the order they were
accepted, and no accepted word is lost or duplicated.

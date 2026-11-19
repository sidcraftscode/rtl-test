# Axon DMA: interface specification (rev 1.5)

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

### 2.1 Changes in rev 1.5
- New `IRQ_MASK` register at 0x10; `CTRL` moves to 0x14 so control registers are contiguous.
- New read-only `BYTES_DONE` at 0x1C for progress reporting.
- `CTRL.sg_en` enables scatter-gather chaining.

## 3. Descriptor and buffering
### 3.1 Descriptor
`axon_desc_pkg::dma_desc_t`, fetched as little-endian 32-bit words; the least
significant field is at byte offset 0. Firmware's `struct axon_dma_desc` must
have identical size, offsets and widths.

### 3.2 Beat buffer semantics
`sync_fifo` accepts a write when `wr_en && (!full || rd_en)` (a full FIFO
takes a write in the same cycle as a read) and a read when `rd_en && !empty`. Accepted words are returned in the order they were
accepted, and no accepted word is lost or duplicated.

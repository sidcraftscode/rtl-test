/* Axon DMA register map. Must match rtl/axon_regs_pkg.sv. */
#ifndef AXON_REGS_H
#define AXON_REGS_H

#define AXON_ID_VALUE        0xA407D3A0u

#define AXON_REG_ID          0x00u
#define AXON_REG_VERSION     0x04u
#define AXON_REG_IRQ_MASK    0x10u
#define AXON_REG_CTRL        0x14u
#define AXON_REG_STATUS      0x18u
#define AXON_REG_BYTES_DONE  0x1Cu
#define AXON_REG_DESC_ADDR   0x20u
#define AXON_REG_IRQ_STAT    0x28u

#define AXON_CTRL_START      (1u << 0)
#define AXON_CTRL_SOFT_RST   (1u << 1)
#define AXON_CTRL_IRQ_EN     (1u << 3)
#define AXON_CTRL_SG_EN      (1u << 2)

#define AXON_STATUS_BUSY     (1u << 0)
#define AXON_STATUS_DONE     (1u << 1)
#define AXON_STATUS_ERR      (1u << 2)

#endif /* AXON_REGS_H */

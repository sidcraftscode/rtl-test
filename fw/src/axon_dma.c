#include "axon_dma.h"

#include "axon_desc.h"
#include "axon_hal.h"
#include "axon_regs.h"

int axon_dma_init(void)
{
    if (axon_read32(AXON_REG_ID) != AXON_ID_VALUE)
        return AXON_ERR_NODEV;
    axon_write32(AXON_REG_CTRL, AXON_CTRL_SOFT_RST);
    axon_write32(AXON_REG_CTRL, AXON_CTRL_IRQ_EN);
    return 0;
}

int axon_dma_submit(const struct axon_dma_desc *desc, uint32_t desc_bus_addr)
{
    if (desc->len == 0 || (desc->len & 3u))
        return AXON_ERR_INVAL;
    uint32_t ctrl = AXON_CTRL_IRQ_EN | AXON_CTRL_START;
    if (desc->sg_count)
        ctrl |= AXON_CTRL_SG_EN;
    axon_mem_write(desc_bus_addr, desc, sizeof *desc);
    axon_write32(AXON_REG_DESC_ADDR, desc_bus_addr);
    axon_write32(AXON_REG_CTRL, ctrl);
    return 0;
}

uint32_t axon_dma_bytes_done(void)
{
    return axon_read32(AXON_REG_BYTES_DONE);
}

int axon_dma_wait(uint32_t max_polls)
{
    for (uint32_t i = 0; i < max_polls; i++) {
        uint32_t status = axon_read32(AXON_REG_STATUS);
        if (status & AXON_STATUS_ERR)
            return AXON_ERR_HW;
        if (status & AXON_STATUS_DONE) {
            axon_write32(AXON_REG_IRQ_STAT, 1u);
            return 0;
        }
    }
    return AXON_ERR_TIMEOUT;
}

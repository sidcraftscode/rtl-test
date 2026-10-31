/* Axon DMA descriptor, as written to memory for the engine to fetch.
 * Must match axon_desc_pkg::dma_desc_t. */
#ifndef AXON_DESC_H
#define AXON_DESC_H

#include <stdint.h>

#define AXON_DESC_F_LAST     (1u << 0)
#define AXON_DESC_F_IRQ      (1u << 1)

struct axon_dma_desc {
    uint32_t src_addr;
    uint32_t dst_addr;
    uint32_t len;       /* bytes, multiple of 4 */
    uint16_t flags;
    uint16_t next_idx;
    uint32_t sg_count;  /* scatter-gather segments that follow */
};

_Static_assert(sizeof(struct axon_dma_desc) == 20, "descriptor size");

#endif /* AXON_DESC_H */

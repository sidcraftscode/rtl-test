#ifndef AXON_DMA_H
#define AXON_DMA_H

#include <stdint.h>

struct axon_dma_desc;

#define AXON_ERR_NODEV    (-1)
#define AXON_ERR_INVAL    (-2)
#define AXON_ERR_HW       (-3)
#define AXON_ERR_TIMEOUT  (-4)

int axon_dma_init(void);
int axon_dma_submit(const struct axon_dma_desc *desc, uint32_t desc_bus_addr);
int axon_dma_wait(uint32_t max_polls);
uint32_t axon_dma_bytes_done(void);

#endif /* AXON_DMA_H */

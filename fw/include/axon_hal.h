/* Platform access layer. Provided by the BSP, a Linux UIO shim, or a
 * co-simulation bridge. The driver never touches MMIO directly. */
#ifndef AXON_HAL_H
#define AXON_HAL_H

#include <stddef.h>
#include <stdint.h>

void     axon_write32(uint32_t offset, uint32_t value);
uint32_t axon_read32(uint32_t offset);
void     axon_mem_write(uint32_t bus_addr, const void *src, size_t len);

#endif /* AXON_HAL_H */

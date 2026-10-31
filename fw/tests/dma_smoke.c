/* Smoke test: one 68 KiB transfer through the engine. Runs on the board via
 * the BSP HAL, or against the RTL via `breakspec check cosim`. */
#include <stdio.h>

#include "axon_desc.h"
#include "axon_dma.h"

#define DESC_BUS_ADDR  0x00001000u

int main(void)
{
    int rc = axon_dma_init();
    if (rc) {
        printf("init failed: %d\n", rc);
        return 2;
    }

    struct axon_dma_desc desc = {
        .src_addr = 0x00100000u,
        .dst_addr = 0x00200000u,
        .len      = 69632u,
        .flags    = AXON_DESC_F_LAST | AXON_DESC_F_IRQ,
        .next_idx = 0,
    };

    rc = axon_dma_submit(&desc, DESC_BUS_ADDR);
    if (rc == 0)
        rc = axon_dma_wait(40000);
    printf("transfer len=%u rc=%d\n", (unsigned)desc.len, rc);
    return rc == 0 ? 0 : 1;
}

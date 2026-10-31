// Axon DMA: in-memory descriptor layout.
// The engine fetches a descriptor as little-endian 32-bit words, so the
// least-significant field of the packed struct sits at byte offset 0.
// Canonical contract for fw/include/axon_desc.h (struct axon_dma_desc).
package axon_desc_pkg;

  typedef struct packed {
    logic [15:0] next_idx;  // byte 14
    logic [15:0] flags;     // byte 12
    logic [15:0] sg_count;  // byte 10: scatter-gather segments that follow
    logic [15:0] len;       // byte 8: segment length in bytes (max 64 KiB)
    logic [31:0] dst_addr;  // byte 4
    logic [31:0] src_addr;  // byte 0
  } dma_desc_t;

  localparam int DESC_WORDS = 4;  // 128-bit descriptor

endpackage

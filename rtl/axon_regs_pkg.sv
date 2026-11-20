// Axon DMA: control register map.
// Byte offsets on the 8-bit register bus behind the AXI-Lite shell.
// This package is the canonical contract for fw/include/axon_regs.h.
package axon_regs_pkg;

  localparam logic [31:0] AXON_ID      = 32'hA407_D3A0;
  localparam logic [31:0] AXON_VERSION = 32'h0001_0500;

  localparam logic [7:0] ADDR_ID        = 8'h00; // RO
  localparam logic [7:0] ADDR_VERSION   = 8'h04; // RO
  localparam logic [7:0] ADDR_IRQ_MASK  = 8'h10; // RW
  localparam logic [7:0] ADDR_CTRL      = 8'h14; // RW  (moved next to IRQ_MASK)
  localparam logic [7:0] ADDR_STATUS    = 8'h18; // RO
  localparam logic [7:0] ADDR_BYTES_DONE = 8'h1C; // RO
  localparam logic [7:0] ADDR_DESC_ADDR = 8'h20; // RW
  localparam logic [7:0] ADDR_IRQ_STAT  = 8'h28; // W1C

  typedef struct packed {
    logic [27:0] rsvd;
    logic        irq_en;    // [3]
    logic        sg_en;     // [2] follow next_idx chain
    logic        soft_rst;  // [1]
    logic        start;     // [0] self-clearing
  } ctrl_reg_t;

  typedef struct packed {
    logic [28:0] rsvd;
    logic        err;       // [2]
    logic        done;      // [1]
    logic        busy;      // [0]
  } status_reg_t;

endpackage

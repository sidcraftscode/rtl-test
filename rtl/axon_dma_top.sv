// Axon DMA: top level. Two clock domains:
//   clk_axi  : register bus, interrupt
//   clk_core : descriptor fetch and data movement
import axon_regs_pkg::*;
import axon_desc_pkg::*;

module axon_dma_top (
  input  logic        clk_axi,
  input  logic        clk_core,
  input  logic        rst_n,
  // register bus (clk_axi)
  input  logic        wr_en,
  input  logic [7:0]  wr_addr,
  input  logic [31:0] wr_data,
  input  logic        rd_en,
  input  logic [7:0]  rd_addr,
  output logic [31:0] rd_data,
  output logic        irq,
  // descriptor memory (clk_core)
  output logic        mem_rd,
  output logic [31:0] mem_addr,
  input  logic [31:0] mem_rdata,
  // output stream (clk_core)
  output logic [31:0] out_data,
  output logic        out_valid,
  input  logic        out_ready
);
  axon_regs_pkg::ctrl_reg_t ctrl;
  logic [31:0] desc_addr;
  logic        start_axi, start_core;
  logic        busy_core, done_core, err_core;
  logic        busy_axi, done_axi, err_axi;
  logic [31:0] bytes_done;
  axon_desc_pkg::dma_desc_t desc_q;

  axon_regs u_regs (
    .clk_axi     (clk_axi),
    .rst_n       (rst_n),
    .wr_en       (wr_en),
    .wr_addr     (wr_addr),
    .wr_data     (wr_data),
    .rd_en       (rd_en),
    .rd_addr     (rd_addr),
    .rd_data     (rd_data),
    .ctrl        (ctrl),
    .desc_addr   (desc_addr),
    .start_pulse (start_axi),
    .busy_sync   (busy_axi),
    .done_sync   (done_axi),
    .err_sync    (err_axi),
    .irq         (irq)
  );

  // clk_axi -> clk_core
  cdc_pulse u_start_sync (
    .clk_src   (clk_axi),
    .clk_dst   (clk_core),
    .rst_n     (rst_n),
    .pulse_src (start_axi),
    .pulse_dst (start_core)
  );

  // clk_core -> clk_axi
  cdc_sync2 u_busy_sync (.clk_dst(clk_axi), .rst_n(rst_n), .d(busy_core), .q(busy_axi));
  cdc_sync2 u_done_sync (.clk_dst(clk_axi), .rst_n(rst_n), .d(done_core), .q(done_axi));
  cdc_sync2 u_err_sync  (.clk_dst(clk_axi), .rst_n(rst_n), .d(err_core),  .q(err_axi));

  axon_dma_engine u_engine (
    .clk_core   (clk_core),
    .rst_n      (rst_n),
    .start      (start_core),
    .desc_addr  (desc_addr),
    .mem_rd     (mem_rd),
    .mem_addr   (mem_addr),
    .mem_rdata  (mem_rdata),
    .out_data   (out_data),
    .out_valid  (out_valid),
    .out_ready  (out_ready),
    .busy       (busy_core),
    .done       (done_core),
    .err        (err_core),
    .bytes_done (bytes_done),
    .desc_q     (desc_q)
  );

endmodule

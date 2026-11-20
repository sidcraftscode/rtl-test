// Formal harness for sync_fifo.
// Approved semantics (docs/axon_dma_spec.md §3.2): a write is accepted when
// wr_en && (!full || rd_en); accepted words are returned in the order they were accepted.
module sync_fifo_formal #(
  parameter int W     = 8,
  parameter int DEPTH = 4
) (
  input logic clk,
  input logic rst_n,
  input logic wr_en,
  input logic rd_en
);
  logic [W-1:0] wdata, rdata;
  logic         full, empty;
  logic [W-1:0] wr_seq, rd_seq;
  logic [W-1:0] outstanding;

  sync_fifo #(.W(W), .DEPTH(DEPTH)) dut (
    .clk(clk), .rst_n(rst_n),
    .wr_en(wr_en), .wdata(wdata), .full(full),
    .rd_en(rd_en), .rdata(rdata), .empty(empty)
  );

  assign outstanding = wr_seq - rd_seq;

  // Every accepted word carries its own sequence number.
  assign wdata = wr_seq;
  wire wr_acc = wr_en && (!full || rd_en);
  wire rd_acc = rd_en && !empty;

  logic f_past_valid = 1'b0;
  always_ff @(posedge clk) f_past_valid <= 1'b1;
  always_comb if (!f_past_valid) assume (!rst_n);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_seq <= '0;
      rd_seq <= '0;
    end else begin
      if (wr_acc) wr_seq <= wr_seq + 1'b1;
      if (rd_acc) rd_seq <= rd_seq + 1'b1;
    end
  end

  always_comb begin
    if (rst_n && f_past_valid) begin
      // fifo_order: words leave in the order they were accepted
      if (rd_acc) p_fifo_order: assert (rdata == rd_seq);
      // fifo_no_overrun: never more words outstanding than DEPTH
      p_fifo_overrun: assert (outstanding <= DEPTH[W-1:0]);
    end
  end
endmodule

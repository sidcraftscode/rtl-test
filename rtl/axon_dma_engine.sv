// Axon DMA: engine (clk_core domain).
// Fetches one descriptor, then streams `len` bytes as 32-bit beats through a
// small elastic buffer to the output port.
import axon_desc_pkg::*;

module axon_dma_engine (
  input  logic        clk_core,
  input  logic        rst_n,
  input  logic        start,        // synchronized single-cycle pulse
  input  logic [31:0] desc_addr,    // quasi-static, sampled on start
  // descriptor memory read port, 1-cycle latency
  output logic        mem_rd,
  output logic [31:0] mem_addr,
  input  logic [31:0] mem_rdata,
  // output stream
  output logic [31:0] out_data,
  output logic        out_valid,
  input  logic        out_ready,
  // status
  output logic        busy,
  output logic        done,
  output logic        err,
  output logic [31:0] bytes_done,
  output axon_desc_pkg::dma_desc_t desc_q
);
  localparam logic [2:0] LAST_WORD = DESC_WORDS - 1;
  typedef enum logic [2:0] {S_IDLE, S_FETCH, S_RUN, S_DRAIN, S_DONE} state_t;
  state_t state;

  logic [31:0] base_addr;
  logic [2:0]  fetch_idx;
  logic        fetch_pending;
  logic [31:0] desc_words [0:DESC_WORDS-1];
  logic [31:0] bytes_issued;

  logic beat_valid, buf_full, buf_empty;
  logic [31:0] beat_data;

  assign beat_valid = (state == S_RUN) && !buf_full && (bytes_issued < desc_q.len);
  assign beat_data  = desc_q.src_addr + bytes_issued;

  sync_fifo #(.W(32), .DEPTH(4)) u_buf (
    .clk   (clk_core),
    .rst_n (rst_n),
    .wr_en (beat_valid),
    .wdata (beat_data),
    .full  (buf_full),
    .rd_en (out_ready),
    .rdata (out_data),
    .empty (buf_empty)
  );
  assign out_valid = !buf_empty;

  always_ff @(posedge clk_core or negedge rst_n) begin
    if (!rst_n) begin
      state         <= S_IDLE;
      base_addr     <= '0;
      fetch_idx     <= '0;
      fetch_pending <= 1'b0;
      bytes_issued  <= '0;
      bytes_done    <= '0;
      desc_q        <= '0;
      err           <= 1'b0;
      mem_rd        <= 1'b0;
      mem_addr      <= '0;
    end else begin
      mem_rd        <= 1'b0;
      fetch_pending <= mem_rd;
      if (out_valid && out_ready) bytes_done <= bytes_done + 32'd4;
      case (state)
        S_IDLE, S_DONE: if (start) begin
          base_addr    <= desc_addr;
          fetch_idx    <= '0;
          bytes_issued <= '0;
          bytes_done   <= '0;
          err          <= 1'b0;
          mem_rd       <= 1'b1;
          mem_addr     <= desc_addr;
          state        <= S_FETCH;
        end
        S_FETCH: if (fetch_pending) begin
          desc_words[fetch_idx] <= mem_rdata;
          if (fetch_idx == LAST_WORD) begin
            state <= S_RUN;
          end else begin
            fetch_idx <= fetch_idx + 1'b1;
            mem_rd    <= 1'b1;
            mem_addr  <= base_addr + {27'd0, fetch_idx + 1'b1, 2'b00};
          end
        end
        S_RUN: begin
          if (desc_q.len == 0 || desc_q.len[1:0] != 2'b00) begin
            err   <= 1'b1;
            state <= S_DONE;
          end else begin
            if (beat_valid) bytes_issued <= bytes_issued + 32'd4;
            if (bytes_issued + (beat_valid ? 32'd4 : 32'd0) >= desc_q.len) state <= S_DRAIN;
          end
        end
        S_DRAIN: if (buf_empty) state <= S_DONE;
        default: state <= S_IDLE;
      endcase
      if (state == S_FETCH && fetch_pending && fetch_idx == LAST_WORD)
        desc_q <= {mem_rdata, desc_words[2], desc_words[1], desc_words[0]};
    end
  end

  // Registered so the status bits are glitch-free into the clk_axi synchronizers.
  always_ff @(posedge clk_core or negedge rst_n) begin
    if (!rst_n) begin
      busy <= 1'b0;
      done <= 1'b0;
    end else begin
      busy <= (state == S_FETCH) || (state == S_RUN) || (state == S_DRAIN);
      done <= (state == S_DONE);
    end
  end

endmodule

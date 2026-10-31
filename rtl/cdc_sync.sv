// Two-flop synchronizer for single-bit level signals.
module cdc_sync2 (
  input  logic clk_dst,
  input  logic rst_n,
  input  logic d,
  output logic q
);
  (* ASYNC_REG = "TRUE" *) logic meta, sync;
  always_ff @(posedge clk_dst or negedge rst_n) begin
    if (!rst_n) begin
      meta <= 1'b0;
      sync <= 1'b0;
    end else begin
      meta <= d;
      sync <= meta;
    end
  end
  assign q = sync;
endmodule

// Toggle-based pulse synchronizer: one src pulse -> one dst pulse.
module cdc_pulse (
  input  logic clk_src,
  input  logic clk_dst,
  input  logic rst_n,
  input  logic pulse_src,
  output logic pulse_dst
);
  logic toggle_src;
  logic toggle_dst, toggle_dst_q;

  always_ff @(posedge clk_src or negedge rst_n) begin
    if (!rst_n) toggle_src <= 1'b0;
    else if (pulse_src) toggle_src <= ~toggle_src;
  end

  cdc_sync2 u_sync (.clk_dst(clk_dst), .rst_n(rst_n), .d(toggle_src), .q(toggle_dst));

  always_ff @(posedge clk_dst or negedge rst_n) begin
    if (!rst_n) toggle_dst_q <= 1'b0;
    else toggle_dst_q <= toggle_dst;
  end

  assign pulse_dst = toggle_dst ^ toggle_dst_q;
endmodule

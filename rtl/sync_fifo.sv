// Single-clock FIFO, first-word fall-through.
// A write is accepted when wr_en && (!full || rd_en): a full FIFO still takes a
// write in the same cycle as a read, so back-to-back descriptors never stall.
// A read is accepted when rd_en && !empty.
module sync_fifo #(
  parameter int W     = 32,
  parameter int DEPTH = 4
) (
  input  logic         clk,
  input  logic         rst_n,
  input  logic         wr_en,
  input  logic [W-1:0] wdata,
  output logic         full,
  input  logic         rd_en,
  output logic [W-1:0] rdata,
  output logic         empty
);
  localparam int AW = $clog2(DEPTH);

  logic [W-1:0]  mem [0:DEPTH-1];
  logic [AW-1:0] wptr, rptr;
  logic [AW:0]   count;

  wire do_wr = wr_en && (!full || rd_en);
  wire do_rd = rd_en && !empty;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wptr  <= '0;
      rptr  <= '0;
      count <= '0;
    end else begin
      if (do_wr) begin
        mem[wptr] <= wdata;
        wptr      <= wptr + 1'b1;
      end
      if (do_rd) rptr <= rptr + 1'b1;
      case ({do_wr, do_rd})
        2'b10:   count <= count + 1'b1;
        2'b01:   count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end

  assign full  = (count == DEPTH[AW:0]);
  assign empty = (count == '0);
  assign rdata = mem[rptr];

`ifdef FORMAL
  // Embedded structural invariants: occupancy agrees with the pointers.
  always_comb begin
    if (rst_n) begin
      a_count_range: assert (count <= DEPTH[AW:0]);
      a_ptr_count:   assert (wptr == rptr + count[AW-1:0]);
    end
  end
`endif

endmodule

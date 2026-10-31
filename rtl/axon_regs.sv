// Axon DMA: control/status register file (clk_axi domain).
// Reads are registered: rd_data is valid the cycle after rd_en.
import axon_regs_pkg::*;

module axon_regs (
  input  logic        clk_axi,
  input  logic        rst_n,
  // register bus from the AXI-Lite shell
  input  logic        wr_en,
  input  logic [7:0]  wr_addr,
  input  logic [31:0] wr_data,
  input  logic        rd_en,
  input  logic [7:0]  rd_addr,
  output logic [31:0] rd_data,
  // engine interface
  output axon_regs_pkg::ctrl_reg_t ctrl,
  output logic [31:0] desc_addr,
  output logic        start_pulse,
  input  logic        busy_sync,
  input  logic        done_sync,
  input  logic        err_sync,
  input  logic [31:0] bytes_done,
  output logic        irq
);
  logic        irq_stat;
  logic        irq_mask;
  logic        done_q;
  logic [31:0] bytes_done_q;  // captured on DONE: bytes_done is stable once the engine is done
  axon_regs_pkg::status_reg_t status;

  assign status = {29'd0, err_sync, done_sync, busy_sync};

  always_ff @(posedge clk_axi or negedge rst_n) begin
    if (!rst_n) begin
      ctrl        <= '0;
      desc_addr   <= '0;
      start_pulse <= 1'b0;
      irq_stat    <= 1'b0;
      irq_mask    <= 1'b0;
      done_q      <= 1'b0;
      bytes_done_q <= '0;
    end else begin
      start_pulse <= 1'b0;
      done_q      <= done_sync;
      if (done_sync && !done_q) begin
        irq_stat     <= 1'b1;
        bytes_done_q <= bytes_done;
      end
      if (wr_en) begin
        case (wr_addr)
          ADDR_CTRL: begin
            ctrl        <= wr_data;
            ctrl.start  <= 1'b0;
            start_pulse <= wr_data[0];
          end
          ADDR_IRQ_MASK:  irq_mask  <= wr_data[0];
          ADDR_DESC_ADDR: desc_addr <= wr_data;
          ADDR_IRQ_STAT:  if (wr_data[0]) irq_stat <= 1'b0;
          default: ;
        endcase
      end
    end
  end

  always_ff @(posedge clk_axi or negedge rst_n) begin
    if (!rst_n) begin
      rd_data <= '0;
    end else if (rd_en) begin
      case (rd_addr)
        ADDR_ID:        rd_data <= AXON_ID;
        ADDR_VERSION:   rd_data <= AXON_VERSION;
        ADDR_IRQ_MASK:  rd_data <= {31'd0, irq_mask};
        ADDR_CTRL:      rd_data <= ctrl;
        ADDR_STATUS:    rd_data <= status;
        ADDR_BYTES_DONE: rd_data <= bytes_done_q;
        ADDR_DESC_ADDR: rd_data <= desc_addr;
        ADDR_IRQ_STAT:  rd_data <= {31'd0, irq_stat};
        default:        rd_data <= 32'd0;
      endcase
    end
  end

  assign irq = irq_stat & ctrl.irq_en & ~irq_mask;

endmodule

`timescale 1ns/1ps
`include "axi_tasks.sv"

module tb_axi_regs;

  import axi_tasks_pkg::*;

  logic clk = 0, rst_n;

  // AXI 信号
  logic [31:0] awaddr, wdata, araddr;
  logic        awvalid, wvalid, arvalid;
  logic        awready, wready, arready;
  logic [3:0]  wstrb;
  logic [1:0]  bresp, rresp;
  logic        bvalid, rvalid;
  logic        bready, rready;
  logic [31:0] rdata;

  // 实例化 DUT
  axi_lite_slave_regs #(.REG_NUM(4)) dut (
      .clk(clk), .rst_n(rst_n),
      .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
      .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
      .bresp(bresp), .bvalid(bvalid), .bready(bready),
      .araddr(araddr), .arvalid(arvalid), .arready(arready),
      .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
  );

  always #5 clk = ~clk;

  initial begin
    rst_n = 0;
    awvalid = 0; wvalid = 0; arvalid = 0; bready = 0; rready = 0;
    #20 rst_n = 1;

    // 写入寄存器
    for (int i = 0; i < 4; i++) begin
      axi_write(clk, i*4, 32'hA5A50000 + i,
                awaddr, awvalid, awready,
                wdata, wstrb, wvalid, wready,
                bvalid, bready);
    end

    // 读取寄存器
    logic [31:0] rd_data;
    for (int i = 0; i < 4; i++) begin
      axi_read(clk, i*4,
               araddr, arvalid, arready,
               rdata, rvalid, rready,
               rd_data);
      $display("reg[%0d] = 0x%08x", i, rd_data);
    end

    // 非法地址读
    axi_read(clk, 32'h20,
             araddr, arvalid, arready,
             rdata, rvalid, rready,
             rd_data);
    $display("Read invalid addr: 0x%08x", rd_data);

    #50 $finish;
  end

endmodule

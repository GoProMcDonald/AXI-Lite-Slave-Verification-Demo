package axi_tasks_pkg;

  task automatic axi_write(
      input  logic        clk,
      input  logic [31:0] addr,
      input  logic [31:0] data,
      output logic [31:0] awaddr,
      output logic        awvalid,
      input  logic        awready,
      output logic [31:0] wdata,
      output logic [3:0]  wstrb,
      output logic        wvalid,
      input  logic        wready,
      input  logic        bvalid,
      output logic        bready
  );
      @(posedge clk);
      awaddr  <= addr;
      awvalid <= 1;
      wdata   <= data;
      wvalid  <= 1;
      wstrb   <= 4'b1111;

      wait (awready && awvalid);
      wait (wready && wvalid);
      @(posedge clk);
      awvalid <= 0;
      wvalid  <= 0;

      wait (bvalid);
      @(posedge clk);
      bready <= 1;
      @(posedge clk);
      bready <= 0;
  endtask

  task automatic axi_read(
      input  logic        clk,
      input  logic [31:0] addr,
      output logic [31:0] araddr,
      output logic        arvalid,
      input  logic        arready,
      input  logic [31:0] rdata_in,
      input  logic        rvalid,
      output logic        rready,
      output logic [31:0] data_out
  );
      @(posedge clk);
      araddr  <= addr;
      arvalid <= 1;

      wait (arready && arvalid);
      @(posedge clk);
      arvalid <= 0;

      wait (rvalid);
      @(posedge clk);
      data_out = rdata_in;

      rready <= 1;
      @(posedge clk);
      rready <= 0;
  endtask

endpackage

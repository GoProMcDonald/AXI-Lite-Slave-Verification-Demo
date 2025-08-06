module axi_lite_slave_regs #(
    parameter REG_NUM = 4
) (
    input  logic         clk,
    input  logic         rst_n,

    // 写地址通道
    input  logic [31:0]  awaddr,
    input  logic         awvalid,
    output logic         awready,

    // 写数据通道
    input  logic [31:0]  wdata,
    input  logic [3:0]   wstrb,
    input  logic         wvalid,
    output logic         wready,

    // 写响应通道
    output logic [1:0]   bresp,
    output logic         bvalid,
    input  logic         bready,

    // 读地址通道
    input  logic [31:0]  araddr,
    input  logic         arvalid,
    output logic         arready,

    // 读数据通道
    output logic [31:0]  rdata,
    output logic [1:0]   rresp,
    output logic         rvalid,
    input  logic         rready
);

    logic [31:0] regfile [REG_NUM];
    logic [1:0] awaddr_sel, araddr_sel;
    assign awaddr_sel = awaddr[3:2];
    assign araddr_sel = araddr[3:2];

    // 写地址握手
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) awready <= 0;
        else if (!awready && awvalid) awready <= 1;
        else awready <= 0;

    // 写数据握手
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) wready <= 0;
        else if (!wready && wvalid) wready <= 1;
        else wready <= 0;

    // 写逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < REG_NUM; i++) regfile[i] <= 0;
            bvalid <= 0;
            bresp  <= 2'b00;
        end else if (awvalid && awready && wvalid && wready) begin
            if (awaddr_sel < REG_NUM) begin
                if (wstrb[0]) regfile[awaddr_sel][7:0]   <= wdata[7:0];
                if (wstrb[1]) regfile[awaddr_sel][15:8]  <= wdata[15:8];
                if (wstrb[2]) regfile[awaddr_sel][23:16] <= wdata[23:16];
                if (wstrb[3]) regfile[awaddr_sel][31:24] <= wdata[31:24];
                bresp <= 2'b00;
            end else begin
                bresp <= 2'b10;
            end
            bvalid <= 1;
        end else if (bvalid && bready) bvalid <= 0;
    end

    // 读地址握手
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) arready <= 0;
        else if (!arready && arvalid) arready <= 1;
        else arready <= 0;

    // 读逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata <= 0;
            rresp <= 0;
            rvalid <= 0;
        end else if (arvalid && arready) begin
            if (araddr_sel < REG_NUM) begin
                rdata <= regfile[araddr_sel];
                rresp <= 2'b00;
            end else begin
                rdata <= 32'hDEAD_BEEF;
                rresp <= 2'b10;
            end
            rvalid <= 1;
        end else if (rvalid && rready) rvalid <= 0;
    end

endmodule

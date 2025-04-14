`timescale 1ns / 1ps

module tb_pipeline;

    logic clk = 0;
    logic reset;

    // RAM interface wires
    logic [31:2] i_addr;
    logic [31:0] i_rdata;
    logic [31:2] d_addr;
    logic        d_we;
    logic [3:0]  d_be;
    logic [31:0] d_wdata;
    logic [31:0] d_rdata;

    // Clock generation
    always #5 clk = ~clk;

    // Instantiate DUT
    pipeline_top dut (
        .clk(clk),
        .reset(reset),
        .i_addr(i_addr),
        .i_rdata(i_rdata),
        .d_addr(d_addr),
        .d_we(d_we),
        .d_be(d_be),
        .d_wdata(d_wdata),
        .d_rdata(d_rdata)
    );

    // Memory: dual port RAM for instruction + data
    dual_port_ram ram (
        .clk(clk),
        .i_addr(i_addr),
        .i_rdata(i_rdata),
        .d_addr(d_addr),
        .d_we(d_we),
        .d_be(d_be),
        .d_wdata(d_wdata),
        .d_rdata(d_rdata)
    );

    initial begin
        $display("===== RV32I Pipeline Simulation Start =====");
        reset = 1;
        #20;
        reset = 0;

        // Run for enough cycles to pass all stages
        #1000;

        $display("===== Simulation Finished =====");
        $finish;
    end

endmodule

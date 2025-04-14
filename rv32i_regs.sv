module rv32i_regs(
    input  logic        clk,
    input  logic        reset,

    // Register read ports
    input  logic [4:0]  rs1_reg,
    input  logic [4:0]  rs2_reg,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    // Register write port
    input  logic        wb_enable,
    input  logic [4:0]  wb_reg,
    input  logic [31:0] wb_data
);

    logic [31:0] regs[31:0];

    // Synchronous write
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++)
                regs[i] <= 32'd0;
        end else if (wb_enable && wb_reg != 5'd0) begin
            regs[wb_reg] <= wb_data;
        end
    end

    // Asynchronous reads (x0 always returns 0)
    assign rs1_data = (rs1_reg == 5'd0) ? 32'd0 : regs[rs1_reg];
    assign rs2_data = (rs2_reg == 5'd0) ? 32'd0 : regs[rs2_reg];

endmodule

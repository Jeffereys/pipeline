module mem_wb_reg(
    input  logic        clk,
    input  logic        reset,

    // From MEM stage
    input  logic [31:0] mem_rdata,
    input  logic [6:0]  opcode_mem,
    input  logic [31:0] alu_result_mem,
    input  logic        wb_enable_mem,
    input  logic [4:0]  wb_reg_mem,

    // To WB stage
    output logic [31:0] mem_rdata_wb,
    output logic [6:0]  opcode_wb,
    output logic [31:0] alu_result_wb,
    output logic        wb_enable_wb,
    output logic [4:0]  wb_reg_wb
);

    always_ff @(posedge clk) begin
        if (reset) begin
            mem_rdata_wb   <= 32'd0;
            opcode_wb      <= 7'd0;
            alu_result_wb  <= 32'd0;
            wb_enable_wb   <= 1'b0;
            wb_reg_wb      <= 5'd0;
        end else begin
            mem_rdata_wb   <= mem_rdata;
            opcode_wb      <= opcode_mem;
            alu_result_wb  <= alu_result_mem;
            wb_enable_wb   <= wb_enable_mem;
            wb_reg_wb      <= wb_reg_mem;
        end
    end

endmodule

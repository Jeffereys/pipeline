// ================ debug_tap.sv ================
module debug_tap (
    input  logic        clk,
    input  logic        reset,

    // Instruction and PC from all stages
    input  logic [31:0] pc_if,
    input  logic [31:0] iw_if,
    input  logic [31:0] pc_id,
    input  logic [31:0] iw_id,
    input  logic [31:0] pc_ex,
    input  logic [31:0] iw_ex,
    input  logic [31:0] pc_mem,
    input  logic [31:0] iw_mem,
    input  logic [31:0] pc_wb,
    input  logic [31:0] iw_wb,

    // ALU and writeback info
    input  logic [31:0] alu_result_ex,
    input  logic [31:0] wb_data,
    input  logic [4:0]  wb_reg,
    input  logic        wb_enable,

    // Optional: Register file snapshot (optional)
    input  logic [31:0] regs[0:31]
);

    always_ff @(posedge clk) begin
        if (!reset) begin
            $display("------ RV32I Pipeline Debug @ %0t ------", $time);
            $display("IF : PC = %h | IW = %h", pc_if, iw_if);
            $display("ID : PC = %h | IW = %h", pc_id, iw_id);
            $display("EX : PC = %h | IW = %h | ALU = %h", pc_ex, iw_ex, alu_result_ex);
            $display("MEM: PC = %h | IW = %h", pc_mem, iw_mem);
            $display("WB : PC = %h | IW = %h | WB_REG = x%0d | WB_DATA = %h | WB_EN = %b", pc_wb, iw_wb, wb_reg, wb_data, wb_enable);

            // Optional: Dump all 32 registers
            for (int i = 0; i < 32; i++) begin
                $display("x%0d = %h", i, regs[i]);
            end
            $display("---------------------------------------\n");
        end
    end

endmodule

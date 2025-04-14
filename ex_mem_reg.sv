module ex_mem_reg(
    input  logic        clk,
    input  logic        reset_or_halt,

    // From EX stage
    input  logic [31:0] alu_result_ex,
    input  logic [31:0] rs2_data_ex,
    input  logic [31:0] iw_ex,
    input  logic [31:0] pc_ex,
    input  logic        wb_enable_ex,
    input  logic [4:0]  wb_reg_ex,
    input  logic        mem_read_ex,
    input  logic        mem_write_ex,
    input  logic [1:0]  mem_width_ex,
    input  logic        branch_taken_ex,
    input  logic [31:0] pc_target_ex,

    // To MEM stage
    output logic [31:0] alu_result_mem,
    output logic [31:0] rs2_data_mem,
    output logic [31:0] iw_mem,
    output logic [31:0] pc_mem,
    output logic        wb_enable_mem,
    output logic [4:0]  wb_reg_mem,
    output logic        mem_read_mem,
    output logic        mem_write_mem,
    output logic [1:0]  mem_width_mem,
    output logic        branch_taken_ex_mem,
    output logic [31:0] pc_target_ex_mem
);

    always_ff @(posedge clk) begin
        if (reset_or_halt) begin
            alu_result_mem     <= 32'd0;
            rs2_data_mem       <= 32'd0;
            iw_mem             <= 32'd0;
            pc_mem             <= 32'd0;
            wb_enable_mem      <= 1'b0;
            wb_reg_mem         <= 5'd0;
            mem_read_mem       <= 1'b0;
            mem_write_mem      <= 1'b0;
            mem_width_mem      <= 2'b10;
            branch_taken_ex_mem <= 1'b0;
            pc_target_ex_mem    <= 32'd0;
        end else begin
            alu_result_mem     <= alu_result_ex;
            rs2_data_mem       <= rs2_data_ex;
            iw_mem             <= iw_ex;
            pc_mem             <= pc_ex;
            wb_enable_mem      <= wb_enable_ex;
            wb_reg_mem         <= wb_reg_ex;
            mem_read_mem       <= mem_read_ex;
            mem_write_mem      <= mem_write_ex;
            mem_width_mem      <= mem_width_ex;
            branch_taken_ex_mem <= branch_taken_ex;
            pc_target_ex_mem    <= pc_target_ex;
        end
    end

endmodule

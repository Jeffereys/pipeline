module id_ex_reg(
    input  logic        clk,
    input  logic        reset_or_halt,
    input  logic        stall,

    // From ID stage
    input  logic [31:0] pc_id,
    input  logic [31:0] iw_id,
    input  logic [31:0] rs1_data_id,
    input  logic [31:0] rs2_data_id,
    input  logic [4:0]  wb_reg_id,
    input  logic        wb_enable_id,
    input  logic        mem_read_id,
    input  logic        mem_write_id,
    input  logic [1:0]  mem_width_id,

    // To EX stage
    output logic [31:0] pc_ex,
    output logic [31:0] iw_ex,
    output logic [31:0] rs1_data_ex,
    output logic [31:0] rs2_data_ex,
    output logic [4:0]  wb_reg_ex,
    output logic        wb_enable_ex,
    output logic        mem_read_ex,
    output logic        mem_write_ex,
    output logic [1:0]  mem_width_ex
);

    always_ff @(posedge clk) begin
        if (reset_or_halt) begin
            pc_ex         <= 32'd0;
            iw_ex         <= 32'd0;
            rs1_data_ex   <= 32'd0;
            rs2_data_ex   <= 32'd0;
            wb_reg_ex     <= 5'd0;
            wb_enable_ex  <= 1'b0;
            mem_read_ex   <= 1'b0;
            mem_write_ex  <= 1'b0;
            mem_width_ex  <= 2'b10;
        end else if (!stall) begin
            pc_ex         <= pc_id;
            iw_ex         <= iw_id;
            rs1_data_ex   <= rs1_data_id;
            rs2_data_ex   <= rs2_data_id;
            wb_reg_ex     <= wb_reg_id;
            wb_enable_ex  <= wb_enable_id;
            mem_read_ex   <= mem_read_id;
            mem_write_ex  <= mem_write_id;
            mem_width_ex  <= mem_width_id;
        end
    end

endmodule

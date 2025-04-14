// ================ pipeline_top.sv ================
module pipeline_top(
    input  logic clk,
    input  logic reset,
    output logic [31:2] i_addr,
    input  logic [31:0] i_rdata,
    output logic [31:2] d_addr,
    output logic        d_we,
    output logic [3:0]  d_be,
    output logic [31:0] d_wdata,
    input  logic [31:0] d_rdata
);

    // IF -> ID
    logic [31:0] pc_if, iw_if;

    // ID -> EX
    logic [31:0] pc_id, iw_id, rs1_data_id, rs2_data_id;
    logic [4:0]  wb_reg_id;
    logic        wb_enable_id;
    logic        mem_read_id, mem_write_id;
    logic [1:0]  mem_width_id;

    // EX -> MEM
    logic [31:0] pc_ex, iw_ex, rs1_data_ex, rs2_data_ex, alu_result_ex, pc_target_ex;
    logic        branch_taken_ex, ebreak_ex;
    logic [4:0]  wb_reg_ex;
    logic        wb_enable_ex;
    logic        mem_read_ex, mem_write_ex;
    logic [1:0]  mem_width_ex;

    // MEM -> WB
    logic [31:0] mem_rdata_mem, alu_result_mem;
    logic [4:0]  wb_reg_mem;
    logic        wb_enable_mem;
    logic [6:0]  opcode_mem;

    // WB
    logic [31:0] wb_data;
    logic [6:0]  opcode_wb;
    logic [4:0]  wb_reg_wb;
    logic        wb_enable_wb;

    // Control signals
    logic halted;

    // Register interface
    logic [4:0] rs1_reg, rs2_reg;
    logic [31:0] rs1_data, rs2_data;

    // IF stage
    rv32_if_top if_stage(
        .clk(clk),
        .reset_or_halt(reset | halted),
        .pc_sel(branch_taken_ex),
        .pc_target(pc_target_ex),
        .pc_out(pc_if),
        .iw_out(iw_if),
        .i_rdata(i_rdata)
    );
    assign i_addr = pc_if[31:2];

    // ID stage
    rv32_id_top id_stage(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_if),
        .iw_in(iw_if),
        .regif_rs1_reg(rs1_reg),
        .regif_rs2_reg(rs2_reg),
        .regif_rs1_data(rs1_data),
        .regif_rs2_data(rs2_data),
        .pc_out(pc_id),
        .iw_out(iw_id),
        .rs1_out(rs1_data_id),
        .rs2_out(rs2_data_id),
        .wb_reg_out(wb_reg_id),
        .wb_enable_out(wb_enable_id),
        .mem_read_out(mem_read_id),
        .mem_write_out(mem_write_id),
        .mem_width_out(mem_width_id),
        .pc_sel(),
        .pc_target()
    );

    // Register File
    rv32i_regs regfile(
        .clk(clk),
        .reset(reset),
        .rs1_reg(rs1_reg),
        .rs2_reg(rs2_reg),
        .wb_enable(wb_enable_wb),
        .wb_reg(wb_reg_wb),
        .wb_data(wb_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ID/EX pipeline register
    id_ex_reg id_ex_pipe(
        .clk(clk),
        .reset_or_halt(reset | halted),
        .stall(1'b0),
        .pc_id(pc_id),
        .iw_id(iw_id),
        .rs1_data_id(rs1_data_id),
        .rs2_data_id(rs2_data_id),
        .wb_reg_id(wb_reg_id),
        .wb_enable_id(wb_enable_id),
        .mem_read_id(mem_read_id),
        .mem_write_id(mem_write_id),
        .mem_width_id(mem_width_id),
        .pc_ex(pc_ex),
        .iw_ex(iw_ex),
        .rs1_data_ex(rs1_data_ex),
        .rs2_data_ex(rs2_data_ex),
        .wb_reg_ex(wb_reg_ex),
        .wb_enable_ex(wb_enable_ex),
        .mem_read_ex(mem_read_ex),
        .mem_write_ex(mem_write_ex),
        .mem_width_ex(mem_width_ex)
    );

    // EX stage
    rv32_ex_top ex_stage(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_ex),
        .iw_in(iw_ex),
        .rs1_data_in(rs1_data_ex),
        .rs2_data_in(rs2_data_ex),
        .rs1_addr(rs1_reg),
        .rs2_addr(rs2_reg),
        .df_mem_enable(wb_enable_mem),
        .df_mem_reg(wb_reg_mem),
        .df_mem_data(alu_result_mem),
        .df_wb_enable(wb_enable_wb),
        .df_wb_reg(wb_reg_wb),
        .df_wb_data(wb_data),
        .alu_out(alu_result_ex),
        .branch_taken(branch_taken_ex),
        .pc_target(pc_target_ex),
        .ebreak_detected(ebreak_ex)
    );

    assign halted = ebreak_ex;

    // EX/MEM register
    ex_mem_reg ex_mem_pipe(
        .clk(clk),
        .reset_or_halt(reset | halted),
        .alu_result_ex(alu_result_ex),
        .rs2_data_ex(rs2_data_ex),
        .iw_ex(iw_ex),
        .pc_ex(pc_ex),
        .wb_enable_ex(wb_enable_ex),
        .wb_reg_ex(wb_reg_ex),
        .mem_read_ex(mem_read_ex),
        .mem_write_ex(mem_write_ex),
        .mem_width_ex(mem_width_ex),
        .alu_result_mem(alu_result_mem),
        .rs2_data_mem(rs2_data_mem),
        .iw_mem(iw_mem),
        .pc_mem(pc_mem),
        .wb_enable_mem(wb_enable_mem),
        .wb_reg_mem(wb_reg_mem),
        .mem_read_mem(mem_read_mem),
        .mem_write_mem(mem_write_mem),
        .mem_width_mem(mem_width_mem),
        .branch_taken_ex(branch_taken_ex),
        .pc_target_ex(pc_target_ex),
        .branch_taken_ex_mem(branch_taken_ex_mem),
        .pc_target_ex_mem(pc_target_ex_mem)
    );

    // MEM stage
    rv32_mem_top mem_stage(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_mem),
        .iw_in(iw_mem),
        .alu_result(alu_result_mem),
        .rs2_data(rs2_data_mem),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .mem_width(mem_width_mem),
        .d_addr(d_addr),
        .d_we(d_we),
        .d_be(d_be),
        .d_wdata(d_wdata),
        .d_rdata(d_rdata),
        .mem_rdata_out(mem_rdata_mem)
    );

    // MEM/WB register
    mem_wb_reg mem_wb_pipe(
        .clk(clk),
        .reset(reset),
        .mem_rdata(mem_rdata_mem),
        .opcode_mem(iw_mem[6:0]),
        .alu_result_mem(alu_result_mem),
        .wb_enable_mem(wb_enable_mem),
        .wb_reg_mem(wb_reg_mem),
        .mem_rdata_wb(mem_rdata_wb),
        .opcode_wb(opcode_wb),
        .alu_result_wb(alu_result_wb),
        .wb_enable_wb(wb_enable_wb),
        .wb_reg_wb(wb_reg_wb)
    );

    // WB stage
    rv32_wb_top wb_stage(
        .clk(clk),
        .reset(reset),
        .alu_result(alu_result_wb),
        .mem_rdata(mem_rdata_wb),
        .opcode(opcode_wb),
        .wb_data_out(wb_data)
    );

endmodule

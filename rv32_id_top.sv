module rv32_id_top(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_in,
    input  logic [31:0] iw_in,
    input  logic [31:0] regif_rs1_data,
    input  logic [31:0] regif_rs2_data,

    output logic [4:0]  regif_rs1_reg,
    output logic [4:0]  regif_rs2_reg,

    output logic [31:0] pc_out,
    output logic [31:0] iw_out,
    output logic [31:0] rs1_out,
    output logic [31:0] rs2_out,
    output logic [4:0]  wb_reg_out,
    output logic        wb_enable_out,

    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic [1:0]  mem_width_out,

    output logic        pc_sel,
    output logic [31:0] pc_target
);

    // === Decoded fields ===
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2, rd;

    // === Immediate fields ===
    logic [31:0] imm_i, imm_b, imm_j;

    // === Decode instruction ===
    rv32_decoder decoder_inst(
        .iw(iw_in),
        .opcode(opcode),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd)
    );

    // === Control signals ===
    control_unit ctrl_inst(
        .opcode(opcode),
        .funct3(funct3),
        .wb_enable(wb_enable_out),
        .mem_read(mem_read_out),
        .mem_write(mem_write_out),
        .mem_width(mem_width_out)
    );

    // === Immediate decode ===
    imm_decoder imm_dec_inst(
        .iw(iw_in),
        .imm_i(imm_i),
        .imm_b(imm_b),
        .imm_j(imm_j)
    );

    // === Outputs to register file ===
    assign regif_rs1_reg = rs1;
    assign regif_rs2_reg = rs2;

    // === Outputs to EX stage ===
    assign pc_out     = pc_in;
    assign iw_out     = iw_in;
    assign rs1_out    = regif_rs1_data;
    assign rs2_out    = regif_rs2_data;
    assign wb_reg_out = rd;

    // === Branch Unit Integration ===
    branch_unit brancher (
        .opcode(opcode),
        .funct3(funct3),
        .pc(pc_in),
        .rs1(regif_rs1_data),
        .rs2(regif_rs2_data),
        .imm_b(imm_b),
        .imm_j(imm_j),
        .imm_i(imm_i),
        .branch_taken(pc_sel),
        .branch_target(pc_target)
    );

endmodule

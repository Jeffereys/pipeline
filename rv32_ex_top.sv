// ================ rv32_ex_top.sv ================
module rv32_ex_top(
    input  logic        clk, //L2-1
    input  logic        reset, //L2-1

    // From ID/EX stage
    input  logic [31:0] pc_in, //L2-1
    input  logic [31:0] iw_in,  //L2-1
    input  logic [31:0] rs1_data_in,//L2-1
    input  logic [31:0] rs2_data_in, //L2-1
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  wb_reg_in,
    input  logic        wb_enable_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic [1:0]  mem_width_in,

    // Data forwarding inputs
    input  logic        df_mem_enable,
    input  logic [4:0]  df_mem_reg,
    input  logic [31:0] df_mem_data,
    input  logic        df_wb_enable,
    input  logic [4:0]  df_wb_reg,
    input  logic [31:0] df_wb_data,

    // To MEM stage
    output logic [31:0] alu_out, //L2-1
    output logic [31:0] rs2_out,
    output logic [31:0] pc_out,
    output logic [31:0] iw_out,
    output logic [4:0]  wb_reg_out,
    output logic        wb_enable_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic [1:0]  mem_width_out,

    // Branch/JALR signals
    output logic        branch_taken,
    output logic [31:0] pc_target,
    output logic        ebreak_detected
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    assign opcode = iw_in[6:0];
    assign funct3 = iw_in[14:12];
    assign funct7 = iw_in[31:25];

    logic [31:0] imm_i;
    assign imm_i = {{20{iw_in[31]}}, iw_in[31:20]};

    // Data forwarding for ALU inputs
    logic [31:0] alu_rs1, alu_rs2;
    assign alu_rs1 = (df_mem_enable && df_mem_reg != 0 && df_mem_reg == rs1_addr) ? df_mem_data :
                     (df_wb_enable  && df_wb_reg  != 0 && df_wb_reg  == rs1_addr) ? df_wb_data  : rs1_data_in;

    assign alu_rs2 = (df_mem_enable && df_mem_reg != 0 && df_mem_reg == rs2_addr) ? df_mem_data :
                     (df_wb_enable  && df_wb_reg  != 0 && df_wb_reg  == rs2_addr) ? df_wb_data  : rs2_data_in;

    // EBREAK detection
    assign ebreak_detected = (iw_in == 32'h00000073);

    // ALU instance
    logic zero_flag, lt_flag;
    alu alu_inst (
        .a(alu_rs1),
        .b((opcode == 7'b0010011) ? imm_i : alu_rs2),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .result(alu_out),
        .zero(zero_flag),
        .lt(lt_flag)
    );

    // Branch/JAL/JALR logic
    always_comb begin
        branch_taken = 1'b0;
        pc_target    = 32'd0;
        unique case (opcode)
            7'b1100011: begin // Branch
                case (funct3)
                    3'b000: branch_taken = zero_flag;       // BEQ
                    3'b001: branch_taken = ~zero_flag;      // BNE
                    3'b100: branch_taken = lt_flag;         // BLT
                    3'b101: branch_taken = ~lt_flag;        // BGE
                    3'b110: branch_taken = lt_flag;         // BLTU
                    3'b111: branch_taken = ~lt_flag;        // BGEU
                endcase
                if (branch_taken)
                    pc_target = pc_in + {{20{iw_in[31]}}, iw_in[7], iw_in[30:25], iw_in[11:8], 1'b0};
            end
            7'b1101111: begin // JAL
                branch_taken = 1'b1;
                pc_target = pc_in + {{11{iw_in[31]}}, iw_in[31], iw_in[19:12], iw_in[20], iw_in[30:21], 1'b0};
            end
            7'b1100111: begin // JALR
                branch_taken = 1'b1;
                pc_target = (alu_rs1 + imm_i) & ~32'd1;
            end
        endcase
    end

    // Pass-through outputs
    assign rs2_out        = rs2_data_in;
    assign pc_out         = pc_in;
    assign iw_out         = iw_in;
    assign wb_reg_out     = wb_reg_in;
    assign wb_enable_out  = wb_enable_in;
    assign mem_read_out   = mem_read_in;
    assign mem_write_out  = mem_write_in;
    assign mem_width_out  = mem_width_in;

endmodule

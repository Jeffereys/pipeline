module branch_unit(
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [31:0] pc,
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [31:0] imm_b,
    input  logic [31:0] imm_j,
    input  logic [31:0] imm_i,
    output logic        branch_taken,
    output logic [31:0] branch_target
);

    logic take_branch;
    logic is_branch;
    logic is_jal;
    logic is_jalr;

    always_comb begin
        take_branch   = 1'b0;
        is_branch     = (opcode == 7'b1100011);
        is_jal        = (opcode == 7'b1101111);
        is_jalr       = (opcode == 7'b1100111);
        branch_target = 32'd0;

        // Branch condition check
        if (is_branch) begin
            unique case (funct3)
                3'b000: take_branch = (rs1 == rs2);                         // BEQ
                3'b001: take_branch = (rs1 != rs2);                         // BNE
                3'b100: take_branch = ($signed(rs1) < $signed(rs2));       // BLT
                3'b101: take_branch = ($signed(rs1) >= $signed(rs2));      // BGE
                3'b110: take_branch = (rs1 < rs2);                          // BLTU
                3'b111: take_branch = (rs1 >= rs2);                         // BGEU
                default: take_branch = 1'b0;
            endcase
            if (take_branch)
                branch_target = pc + imm_b;
        end
        // JAL: unconditional jump
        else if (is_jal) begin
            take_branch = 1'b1;
            branch_target = pc + imm_j;
        end
        // JALR: register indirect jump
        else if (is_jalr) begin
            take_branch = 1'b1;
            branch_target = (rs1 + imm_i) & ~32'd1;
        end

        branch_taken = take_branch;
    end

endmodule

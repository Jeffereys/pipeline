// ================ alu.sv ================
module alu(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [6:0]  opcode,
    input  logic [2:0]  funct3,
    input  logic [6:0]  funct7,
    output logic [31:0] result,
    output logic        zero,
    output logic        lt
);

    logic signed [31:0] a_signed, b_signed;
    assign a_signed = a;
    assign b_signed = b;

    always_comb begin
        result = 32'd0;

        case (opcode)
            7'b0110011: begin // R-type
                case ({funct7, funct3})
                    10'b0000000000: result = a + b; // ADD
                    10'b0100000000: result = a - b; // SUB
                    10'b0000000111: result = a & b; // AND
                    10'b0000000110: result = a | b; // OR
                    10'b0000000100: result = a ^ b; // XOR
                    10'b0000000001: result = a << b[4:0]; // SLL
                    10'b0000000101: result = a >> b[4:0]; // SRL
                    10'b0100000101: result = a_signed >>> b[4:0]; // SRA
                    10'b0000000010: result = (a_signed < b_signed) ? 32'd1 : 32'd0; // SLT
                    10'b0000000011: result = (a < b) ? 32'd1 : 32'd0; // SLTU
                    default: result = 32'd0;
                endcase
            end
            7'b0010011: begin // I-type
                case (funct3)
                    3'b000: result = a + b; // ADDI
                    3'b111: result = a & b; // ANDI
                    3'b110: result = a | b; // ORI
                    3'b100: result = a ^ b; // XORI
                    3'b001: result = a << b[4:0]; // SLLI
                    3'b101: result = (funct7 == 7'b0000000) ? (a >> b[4:0]) : (a_signed >>> b[4:0]); // SRLI/SRAI
                    3'b010: result = (a_signed < b_signed) ? 32'd1 : 32'd0; // SLTI
                    3'b011: result = (a < b) ? 32'd1 : 32'd0; // SLTIU
                    default: result = 32'd0;
                endcase
            end
            7'b0110111: result = {b[31:12], 12'b0}; // LUI
            7'b0010111: result = a + {b[31:12], 12'b0}; // AUIPC
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
    assign lt   = (a_signed < b_signed);

endmodule

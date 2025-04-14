module rv32_wb_top(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_rdata,
    input  logic [6:0]  opcode,
    output logic [31:0] wb_data_out
);

    always_comb begin
        case (opcode)
            7'b0000011: wb_data_out = mem_rdata; // Load instructions (LB, LH, LW, etc.)
            default:    wb_data_out = alu_result;
        endcase
    end

endmodule

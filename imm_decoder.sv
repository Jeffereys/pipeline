module imm_decoder(
    input  logic [31:0] iw,
    output logic [31:0] imm_i,
    output logic [31:0] imm_b,
    output logic [31:0] imm_j
);
    assign imm_i = {{20{iw[31]}}, iw[31:20]};

    assign imm_b = {{19{iw[31]}}, iw[31], iw[7], iw[30:25], iw[11:8], 1'b0};

    assign imm_j = {{11{iw[31]}}, iw[31], iw[19:12], iw[20], iw[30:21], 1'b0};
endmodule

module rv32_decoder(
    input  logic [31:0] iw,
    output logic [6:0]  opcode,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd
);
    assign opcode = iw[6:0];
    assign rd     = iw[11:7];
    assign funct3 = iw[14:12];
    assign rs1    = iw[19:15];
    assign rs2    = iw[24:20];
endmodule

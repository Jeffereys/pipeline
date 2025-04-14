module rv32_mem_top(
    input  logic        clk,
    input  logic        reset,
    
    // From EX stage
    input  logic [31:0] pc_in,
    input  logic [31:0] iw_in,
    input  logic [31:0] alu_result,
    input  logic [31:0] rs2_data,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [1:0]  mem_width,

    // Memory interface
    output logic [31:2] d_addr,
    output logic        d_we,
    output logic [3:0]  d_be,
    output logic [31:0] d_wdata,
    input  logic [31:0] d_rdata,

    // To WB stage
    output logic [31:0] mem_rdata_out
);

    // Extract address offset
    logic [1:0] addr_offset;
    assign addr_offset = alu_result[1:0];

    // Memory I/O unit (load unpacker + store shifter + byte-enable gen)
    memory_io_unit io_unit (
        .addr           (addr_offset),
        .width          (mem_width),
        .is_unsigned    (iw_in[14]),       // funct3[2] == unsigned
        .we             (mem_write),
        .rs2            (rs2_data),
        .d_rdata        (d_rdata),
        .d_be           (d_be),
        .d_wdata        (d_wdata),
        .reg_write_data (mem_rdata_out)
    );

    // Address and write-enable routing
    assign d_addr = alu_result[31:2];
    assign d_we   = mem_write;

endmodule

module dual_port_ram #(
    parameter ADDR_WIDTH = 15 // 2^15 = 32KB
)(
    input  logic        clk,

    // Instruction port
    input  logic [31:2] i_addr,
    output logic [31:0] i_rdata,

    // Data port
    input  logic [31:2] d_addr,
    input  logic        d_we,
    input  logic [3:0]  d_be,
    input  logic [31:0] d_wdata,
    output logic [31:0] d_rdata
);

    // 8-bit wide memory array
    logic [7:0] mem[0:(1<<ADDR_WIDTH)-1];

    // Load memory contents
    initial $readmemh("ram.hex", mem);

    // Instruction read (always 4 bytes)
    assign i_rdata = {
        mem[{i_addr, 2'b11}],
        mem[{i_addr, 2'b10}],
        mem[{i_addr, 2'b01}],
        mem[{i_addr, 2'b00}]
    };

    // Data read
    assign d_rdata = {
        mem[{d_addr, 2'b11}],
        mem[{d_addr, 2'b10}],
        mem[{d_addr, 2'b01}],
        mem[{d_addr, 2'b00}]
    };

    // Data write with byte enables
    always_ff @(posedge clk) begin
        if (d_we) begin
            if (d_be[0]) mem[{d_addr, 2'b00}] <= d_wdata[7:0];
            if (d_be[1]) mem[{d_addr, 2'b01}] <= d_wdata[15:8];
            if (d_be[2]) mem[{d_addr, 2'b10}] <= d_wdata[23:16];
            if (d_be[3]) mem[{d_addr, 2'b11}] <= d_wdata[31:24];
        end
    end

endmodule

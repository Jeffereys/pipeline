module rv32_if_top(
    input  logic        clk,
    input  logic        reset_or_halt,   // Combined reset + EBREAK halt
    input  logic        pc_sel,          // 1 = take branch/jump
    input  logic [31:0] pc_target,       // Branch/jump destination
    output logic [31:0] pc_out,          // Current PC value
    output logic [31:0] iw_out,          // Instruction fetched
    input  logic [31:0] i_rdata          // Data from instruction memory
);

    logic [31:0] pc;

    always_ff @(posedge clk) begin
        if (reset_or_halt)
            pc <= 32'h00000000;
        else if (pc_sel)
            pc <= pc_target;
        else
            pc <= pc + 32'd4;
    end

    assign pc_out = pc;
    assign iw_out = i_rdata;

endmodule

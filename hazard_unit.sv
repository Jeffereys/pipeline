// ================ hazard_unit.sv ================
module hazard_unit(
    input  logic        mem_read_ex,
    input  logic [4:0]  wb_reg_ex,
    input  logic [4:0]  rs1_id,
    input  logic [4:0]  rs2_id,
    output logic        stall
);

    // Stall when a load-use hazard is detected
    always_comb begin
        if (mem_read_ex && (
            (wb_reg_ex != 0) &&
            ((wb_reg_ex == rs1_id) || (wb_reg_ex == rs2_id))
        )) begin
            stall = 1'b1;
        end else begin
            stall = 1'b0;
        end
    end

endmodule

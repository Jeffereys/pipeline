module control_unit(
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    output logic       wb_enable,
    output logic       mem_read,
    output logic       mem_write,
    output logic [1:0] mem_width
);
    always_comb begin
        // Default outputs
        wb_enable  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_width  = 2'b10; // word

        case (opcode)
            7'b0110011, // R-type ALU
            7'b0010011, // I-type ALU
            7'b1101111, // JAL
            7'b1100111, // JALR
            7'b0110111, // LUI
            7'b0010111: // AUIPC
                wb_enable = 1'b1;

            7'b0000011: begin // LOAD
                wb_enable = 1'b1;
                mem_read  = 1'b1;
                case (funct3)
                    3'b000: mem_width = 2'b00; // LB
                    3'b001: mem_width = 2'b01; // LH
                    3'b010: mem_width = 2'b10; // LW
                    default: mem_width = 2'b10;
                endcase
            end

            7'b0100011: begin // STORE
                mem_write = 1'b1;
                case (funct3)
                    3'b000: mem_width = 2'b00; // SB
                    3'b001: mem_width = 2'b01; // SH
                    3'b010: mem_width = 2'b10; // SW
                    default: mem_width = 2'b10;
                endcase
            end

            default: begin
                wb_enable  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_width  = 2'b10;
            end
        endcase
    end
endmodule

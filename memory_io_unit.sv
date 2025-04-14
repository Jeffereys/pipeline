module memory_io_unit(
    input  logic [1:0]  addr,            // offset bits of address (A[1:0])
    input  logic [1:0]  width,           // 00 = byte, 01 = halfword, 10 = word
    input  logic        is_unsigned,     // unsigned load flag (funct3[2])
    input  logic        we,              // write enable
    input  logic [31:0] rs2,             // store data
    input  logic [31:0] d_rdata,         // data from RAM

    output logic [3:0]  d_be,            // byte enable
    output logic [31:0] d_wdata,         // data to write to RAM
    output logic [31:0] reg_write_data   // loaded data to write to register file
);

    // Store Byte-Enable and Write Data
    always_comb begin
        d_be    = 4'b0000;
        d_wdata = 32'd0;

        case (width)
            2'b00: begin // byte
                d_be = (4'b0001 << addr);
                d_wdata = {4{rs2[7:0]}};
            end
            2'b01: begin // halfword
                d_be = (addr[1]) ? 4'b1100 : 4'b0011;
                d_wdata = {2{rs2[15:0]}};
            end
            2'b10: begin // word
                d_be = 4'b1111;
                d_wdata = rs2;
            end
            default: begin
                d_be = 4'b0000;
                d_wdata = 32'd0;
            end
        endcase
    end

    // Load Unpacking
    always_comb begin
        reg_write_data = 32'd0;

        case (width)
            2'b00: begin // byte
                case (addr)
                    2'd0: reg_write_data = is_unsigned ? {24'd0, d_rdata[7:0]}   : {{24{d_rdata[7]}},   d_rdata[7:0]};
                    2'd1: reg_write_data = is_unsigned ? {24'd0, d_rdata[15:8]}  : {{24{d_rdata[15]}},  d_rdata[15:8]};
                    2'd2: reg_write_data = is_unsigned ? {24'd0, d_rdata[23:16]} : {{24{d_rdata[23]}}, d_rdata[23:16]};
                    2'd3: reg_write_data = is_unsigned ? {24'd0, d_rdata[31:24]} : {{24{d_rdata[31]}}, d_rdata[31:24]};
                endcase
            end
            2'b01: begin // halfword
                reg_write_data = (addr[1] == 1'b0) ?
                    (is_unsigned ? {16'd0, d_rdata[15:0]}  : {{16{d_rdata[15]}}, d_rdata[15:0]}) :
                    (is_unsigned ? {16'd0, d_rdata[31:16]} : {{16{d_rdata[31]}}, d_rdata[31:16]});
            end
            2'b10: begin // word
                reg_write_data = d_rdata;
            end
            default: begin
                reg_write_data = 32'd0;
            end
        endcase
    end

endmodule

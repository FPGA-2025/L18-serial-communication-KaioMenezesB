module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg busy;

    wire parity_bit = ^data_in;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            serial_out <= 1'b1;
            bit_cnt <= 4'd0;
            busy <= 1'b0;
            shift_reg <= 8'd0;
        end else begin
            if (!busy) begin
                serial_out <= 1'b1;
                if (start) begin
                    busy <= 1'b1;
                    bit_cnt <= 4'd0;
                    shift_reg <= {~parity_bit, data_in};
                    serial_out <= 1'b0;
                end
            end else begin
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt < 4'd8) begin
                    serial_out <= shift_reg[0];
                    shift_reg <= {1'b0, shift_reg[7:1]};
                end else begin
                    serial_out <= 1'b1;
                    busy <= 1'b0;
                end
            end
        end
    end
    
endmodule
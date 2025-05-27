module receiver (
    input clk,
    input rstn,
    output reg ready, // Precisei declarar como reg para funcionar corretamente
    output reg [6:0] data_out, // Precisei declarar como reg para funcionar corretamente
    output reg parity_ok_n, // Precisei declarar como reg para funcionar corretamente
    input serial_in
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg receiving;
    reg serial_in_dly;

    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            serial_in_dly <= 1'b1;
        else
            serial_in_dly <= serial_in;
    end

    wire start_bit_detected = (serial_in_dly == 1'b1) && (serial_in == 1'b0);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ready <= 1'b0;
            bit_cnt <= 4'd0;
            shift_reg <= 8'd0;
            receiving <= 1'b0;
            data_out <= 7'd0;
            parity_ok_n <= 1'b1;
        end else begin
            if (!receiving) begin
                ready <= 1'b0;
                parity_ok_n <= 1'b1;
                if (start_bit_detected) begin
                    receiving <= 1'b1;
                    bit_cnt <= 4'd0;
                end
            end else begin
                bit_cnt <= bit_cnt + 1;
                shift_reg <= {serial_in, shift_reg[7:1]};
                if (bit_cnt == 4'd8) begin
                    receiving <= 1'b0;
                    ready <= 1'b1;
                    data_out <= shift_reg[6:0];
                    parity_ok_n <= ~(^shift_reg);
                end
            end
        end
    end
    
endmodule
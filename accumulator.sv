// Accumulator DUT
// Accumulates input data when acc_en is high; clears when clear is high.
module accumulator #(
    parameter DATA_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  acc_en,
    input  logic                  clear,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH:0]   acc_out,   // one extra bit for overflow
    output logic                  overflow
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out  <= '0;
        end else if (clear) begin
            acc_out  <= '0;
        end else if (acc_en) begin
            acc_out  <= acc_out + {1'b0, data_in};
        end
    end

    assign overflow = acc_out[DATA_WIDTH];

endmodule

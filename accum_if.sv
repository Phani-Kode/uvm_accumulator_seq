// Interface for the accumulator DUT
interface accum_if #(parameter DATA_WIDTH = 8) (input logic clk);

    logic                  rst_n;
    logic                  acc_en;
    logic                  clear;
    logic [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH:0]   acc_out;
    logic                  overflow;

    // Clocking block for the driver (active-edge driven)
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output rst_n;
        output acc_en;
        output clear;
        output data_in;
        input  acc_out;
        input  overflow;
    endclocking

    // Clocking block for the monitor (sample after clock edge)
    clocking monitor_cb @(posedge clk);
        default input #1;
        input rst_n;
        input acc_en;
        input clear;
        input data_in;
        input acc_out;
        input overflow;
    endclocking

    modport driver_mp  (clocking driver_cb,  input clk);
    modport monitor_mp (clocking monitor_cb, input clk);

endinterface

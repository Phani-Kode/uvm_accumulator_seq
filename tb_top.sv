// Testbench top-level module
`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // ------------------------------------------------------------------ //
    //  Clock generation
    // ------------------------------------------------------------------ //
    logic clk;
    initial clk = 0;
    always #5 clk = ~clk;   // 100 MHz

    // ------------------------------------------------------------------ //
    //  Interface instantiation
    // ------------------------------------------------------------------ //
    accum_if #(.DATA_WIDTH(8)) dut_if (.clk(clk));

    // ------------------------------------------------------------------ //
    //  DUT instantiation
    // ------------------------------------------------------------------ //
    accumulator #(.DATA_WIDTH(8)) dut (
        .clk     (clk),
        .rst_n   (dut_if.rst_n),
        .acc_en  (dut_if.acc_en),
        .clear   (dut_if.clear),
        .data_in (dut_if.data_in),
        .acc_out (dut_if.acc_out),
        .overflow(dut_if.overflow)
    );

    // ------------------------------------------------------------------ //
    //  Pass interface to UVM config_db and kick off test
    // ------------------------------------------------------------------ //
    initial begin
        uvm_config_db #(virtual accum_if)::set(null, "uvm_test_top.*", "vif", dut_if);
        run_test();   // test name supplied via +UVM_TESTNAME on the command line
    end

    // ------------------------------------------------------------------ //
    //  Optional waveform dump
    // ------------------------------------------------------------------ //
    initial begin
        $dumpfile("accum_waves.vcd");
        $dumpvars(0, tb_top);
    end

endmodule

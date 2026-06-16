// Package bundling all UVM verification classes
package accumulator_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "accumulator_transaction.sv"
    `include "accumulator_sequences.sv"
    `include "accumulator_driver.sv"
    `include "accumulator_monitor.sv"
    `include "accumulator_scoreboard.sv"
    `include "accumulator_agent.sv"
    `include "accumulator_env.sv"
    `include "base_test.sv"

endpackage

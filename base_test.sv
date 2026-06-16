// ============================================================
//  UVM Tests for the accumulator
// ============================================================

// ------------------------------------------------------------
//  base_test – common test infrastructure
//  All tests extend this class.
// ------------------------------------------------------------
class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    accumulator_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = accumulator_env::type_id::create("env", this);
    endfunction

    // Helper to start a sequence on the agent sequencer
    protected task run_sequence(uvm_sequence #(accumulator_transaction) seq);
        seq.start(env.agent.sequencer);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass


// ------------------------------------------------------------
//  random_test
//  Runs the random_accum_sequence with 50 transactions.
// ------------------------------------------------------------
class random_test extends base_test;

    `uvm_component_utils(random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        random_accum_sequence seq;
        phase.raise_objection(this);

        seq          = random_accum_sequence::type_id::create("seq");
        seq.num_txns = 50;
        run_sequence(seq);

        phase.drop_objection(this);
    endtask

endclass


// ------------------------------------------------------------
//  directed_test
//  Runs the directed_accum_sequence to validate known values.
// ------------------------------------------------------------
class directed_test extends base_test;

    `uvm_component_utils(directed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        reset_sequence          rst;
        directed_accum_sequence dir;
        phase.raise_objection(this);

        rst = reset_sequence::type_id::create("rst");
        run_sequence(rst);

        dir = directed_accum_sequence::type_id::create("dir");
        run_sequence(dir);

        phase.drop_objection(this);
    endtask

endclass


// ------------------------------------------------------------
//  full_test
//  Runs the full_test_sequence that chains all sub-sequences.
// ------------------------------------------------------------
class full_test extends base_test;

    `uvm_component_utils(full_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        full_test_sequence seq;
        phase.raise_objection(this);

        seq = full_test_sequence::type_id::create("seq");
        run_sequence(seq);

        phase.drop_objection(this);
    endtask

endclass

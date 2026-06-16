// ============================================================
//  UVM Sequences for the accumulator verification environment
// ============================================================

// ------------------------------------------------------------
//  Base sequence – common infrastructure for all sequences
// ------------------------------------------------------------
class accum_base_sequence extends uvm_sequence #(accumulator_transaction);

    `uvm_object_utils(accum_base_sequence)

    function new(string name = "accum_base_sequence");
        super.new(name);
    endfunction

    // Helper: send a single transaction and wait for it to complete
    protected task send_txn(accumulator_transaction txn);
        start_item(txn);
        if (!txn.randomize())
            `uvm_fatal(get_type_name(), "Randomisation failed")
        finish_item(txn);
        `uvm_info(get_type_name(), txn.convert2string(), UVM_HIGH)
    endtask

endclass


// ------------------------------------------------------------
//  random_accum_sequence
//  Drives N fully randomised transactions subject to the
//  constraints declared in accumulator_transaction.
// ------------------------------------------------------------
class random_accum_sequence extends accum_base_sequence;

    `uvm_object_utils(random_accum_sequence)

    // Configurable number of transactions (overridable from test)
    int unsigned num_txns = 20;

    function new(string name = "random_accum_sequence");
        super.new(name);
    endfunction

    virtual task body();
        accumulator_transaction txn;

        `uvm_info(get_type_name(),
                  $sformatf("Starting random_accum_sequence: %0d transactions", num_txns),
                  UVM_MEDIUM)

        repeat (num_txns) begin
            txn = accumulator_transaction::type_id::create("txn");
            send_txn(txn);
        end

        `uvm_info(get_type_name(), "random_accum_sequence complete", UVM_MEDIUM)
    endtask

endclass


// ------------------------------------------------------------
//  reset_sequence
//  Issues a synchronous clear to reset the accumulator to 0.
// ------------------------------------------------------------
class reset_sequence extends accum_base_sequence;

    `uvm_object_utils(reset_sequence)

    function new(string name = "reset_sequence");
        super.new(name);
    endfunction

    virtual task body();
        accumulator_transaction txn;
        txn = accumulator_transaction::type_id::create("txn");
        start_item(txn);
        txn.acc_en  = 1'b0;
        txn.clear   = 1'b1;
        txn.data_in = 8'h00;
        finish_item(txn);
        `uvm_info(get_type_name(), "Accumulator cleared", UVM_MEDIUM)
    endtask

endclass


// ------------------------------------------------------------
//  directed_accum_sequence
//  Accumulates a fixed set of known values; used to produce a
//  deterministic reference result for sanity checking.
// ------------------------------------------------------------
class directed_accum_sequence extends accum_base_sequence;

    `uvm_object_utils(directed_accum_sequence)

    function new(string name = "directed_accum_sequence");
        super.new(name);
    endfunction

    virtual task body();
        accumulator_transaction txn;
        // Directed pattern: 10, 20, 30, 40 → expected sum 100
        byte unsigned values[$] = '{8'd10, 8'd20, 8'd30, 8'd40};

        foreach (values[i]) begin
            txn = accumulator_transaction::type_id::create("txn");
            start_item(txn);
            txn.acc_en  = 1'b1;
            txn.clear   = 1'b0;
            txn.data_in = values[i];
            finish_item(txn);
            `uvm_info(get_type_name(),
                      $sformatf("Drove data_in=0x%0h", values[i]), UVM_MEDIUM)
        end
    endtask

endclass


// ------------------------------------------------------------
//  overflow_stress_sequence
//  Intentionally drives large values to exercise the overflow
//  flag by accumulating values close to 2^8.
// ------------------------------------------------------------
class overflow_stress_sequence extends accum_base_sequence;

    `uvm_object_utils(overflow_stress_sequence)

    int unsigned num_txns = 10;

    function new(string name = "overflow_stress_sequence");
        super.new(name);
    endfunction

    virtual task body();
        accumulator_transaction txn;

        `uvm_info(get_type_name(), "Starting overflow stress", UVM_MEDIUM)

        repeat (num_txns) begin
            txn = accumulator_transaction::type_id::create("txn");
            start_item(txn);
            // Constrain to large values only (192–255 range)
            if (!txn.randomize() with {
                    acc_en  == 1'b1;
                    clear   == 1'b0;
                    data_in inside {[192:255]};
                })
                `uvm_fatal(get_type_name(), "Overflow randomisation failed")
            finish_item(txn);
            `uvm_info(get_type_name(), txn.convert2string(), UVM_HIGH)
        end

        `uvm_info(get_type_name(), "Overflow stress complete", UVM_MEDIUM)
    endtask

endclass


// ------------------------------------------------------------
//  full_test_sequence
//  Orchestrates: reset → directed → random → overflow stress
// ------------------------------------------------------------
class full_test_sequence extends uvm_sequence #(accumulator_transaction);

    `uvm_object_utils(full_test_sequence)

    function new(string name = "full_test_sequence");
        super.new(name);
    endfunction

    virtual task body();
        reset_sequence          rst_seq;
        directed_accum_sequence dir_seq;
        random_accum_sequence   rnd_seq;
        reset_sequence          mid_rst;
        overflow_stress_sequence ovf_seq;

        // 1. Clear accumulator
        rst_seq = reset_sequence::type_id::create("rst_seq");
        rst_seq.start(m_sequencer);

        // 2. Directed accumulation for deterministic check
        dir_seq = directed_accum_sequence::type_id::create("dir_seq");
        dir_seq.start(m_sequencer);

        // 3. Mid-test reset
        mid_rst = reset_sequence::type_id::create("mid_rst");
        mid_rst.start(m_sequencer);

        // 4. Random stimulus
        rnd_seq = random_accum_sequence::type_id::create("rnd_seq");
        rnd_seq.num_txns = 30;
        rnd_seq.start(m_sequencer);

        // 5. Mid-test reset before overflow stress
        mid_rst = reset_sequence::type_id::create("mid_rst2");
        mid_rst.start(m_sequencer);

        // 6. Overflow stress
        ovf_seq = overflow_stress_sequence::type_id::create("ovf_seq");
        ovf_seq.num_txns = 5;
        ovf_seq.start(m_sequencer);

        `uvm_info(get_type_name(), "full_test_sequence complete", UVM_LOW)
    endtask

endclass

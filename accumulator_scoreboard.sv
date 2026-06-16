// UVM Scoreboard – reference model for the accumulator
class accumulator_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(accumulator_scoreboard)

    uvm_analysis_imp #(accumulator_transaction, accumulator_scoreboard) analysis_export;

    // Internal reference model state
    local logic [8:0] ref_acc;   // 9-bit to match DUT acc_out width

    // Counters
    int unsigned txn_count;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
        ref_acc         = '0;
        txn_count       = 0;
        pass_count      = 0;
        fail_count      = 0;
    endfunction

    // Called by the monitor's analysis port for every sampled cycle
    function void write(accumulator_transaction txn);
        logic [8:0] expected_acc;
        logic       expected_overflow;

        txn_count++;

        // Mirror the DUT behaviour
        if (txn.clear)
            ref_acc = '0;
        else if (txn.acc_en)
            ref_acc = ref_acc + {1'b0, txn.data_in};

        expected_acc      = ref_acc;
        expected_overflow = ref_acc[8];

        if ((txn.acc_out == expected_acc) && (txn.overflow == expected_overflow)) begin
            pass_count++;
            `uvm_info(get_type_name(),
                      $sformatf("PASS [%0d]: %s | exp_acc=0x%0h exp_ovf=%0b",
                                txn_count, txn.convert2string(),
                                expected_acc, expected_overflow),
                      UVM_HIGH)
        end else begin
            fail_count++;
            `uvm_error(get_type_name(),
                       $sformatf("FAIL [%0d]: %s | exp_acc=0x%0h exp_ovf=%0b",
                                 txn_count, txn.convert2string(),
                                 expected_acc, expected_overflow))
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
                  $sformatf("Scoreboard summary: total=%0d pass=%0d fail=%0d",
                             txn_count, pass_count, fail_count),
                  UVM_LOW)
        if (fail_count > 0)
            `uvm_error(get_type_name(), "TEST FAILED – scoreboard mismatches detected")
        else
            `uvm_info(get_type_name(), "TEST PASSED", UVM_LOW)
    endfunction

endclass

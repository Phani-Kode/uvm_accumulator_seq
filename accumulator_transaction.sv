// UVM Transaction item for the accumulator
class accumulator_transaction extends uvm_sequence_item;

    `uvm_object_utils(accumulator_transaction)

    // ------------------------------------------------------------------ //
    //  Stimulus fields
    // ------------------------------------------------------------------ //
    rand logic        acc_en;   // enable accumulation this cycle
    rand logic        clear;    // synchronous clear
    rand logic [7:0]  data_in;  // 8-bit input value

    // ------------------------------------------------------------------ //
    //  Response / expected fields (filled by monitor / scoreboard)
    // ------------------------------------------------------------------ //
    logic [8:0]  acc_out;   // 9-bit accumulated result (DATA_WIDTH+1)
    logic        overflow;

    // ------------------------------------------------------------------ //
    //  Randomisation constraints
    // ------------------------------------------------------------------ //

    // clear and acc_en are mutually exclusive in typical usage; allow both
    // low (idle) but never simultaneous clear+acc_en
    constraint c_no_simultaneous_clear_acc {
        !(clear && acc_en);
    }

    // Bias: accumulate more often than clear, idle occasionally
    constraint c_op_dist {
        acc_en dist {1 := 70, 0 := 30};
        clear  dist {1 := 10, 0 := 90};
    }

    // Uniformly distributed input data across the full range
    constraint c_data_range {
        data_in inside {[0:255]};
    }

    // ------------------------------------------------------------------ //
    //  Constructor
    // ------------------------------------------------------------------ //
    function new(string name = "accumulator_transaction");
        super.new(name);
    endfunction

    // ------------------------------------------------------------------ //
    //  UVM field utilities
    // ------------------------------------------------------------------ //
    function void do_copy(uvm_object rhs);
        accumulator_transaction rhs_t;
        super.do_copy(rhs);
        $cast(rhs_t, rhs);
        acc_en   = rhs_t.acc_en;
        clear    = rhs_t.clear;
        data_in  = rhs_t.data_in;
        acc_out  = rhs_t.acc_out;
        overflow = rhs_t.overflow;
    endfunction

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        accumulator_transaction rhs_t;
        $cast(rhs_t, rhs);
        return (super.do_compare(rhs, comparer) &&
                (acc_out  == rhs_t.acc_out)     &&
                (overflow == rhs_t.overflow));
    endfunction

    function string convert2string();
        return $sformatf(
            "acc_en=%0b clear=%0b data_in=0x%0h | acc_out=0x%0h overflow=%0b",
            acc_en, clear, data_in, acc_out, overflow);
    endfunction

endclass

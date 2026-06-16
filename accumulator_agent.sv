// UVM Agent for the accumulator
class accumulator_agent extends uvm_agent;

    `uvm_component_utils(accumulator_agent)

    // Sub-components
    accumulator_driver   driver;
    accumulator_monitor  monitor;
    uvm_sequencer #(accumulator_transaction) sequencer;

    // Expose monitor's analysis port upward
    uvm_analysis_port #(accumulator_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap       = new("ap", this);
        monitor  = accumulator_monitor::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            driver    = accumulator_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer #(accumulator_transaction)::type_id::create("sequencer", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);

        // Propagate monitor AP to the agent boundary
        monitor.ap.connect(ap);
    endfunction

endclass

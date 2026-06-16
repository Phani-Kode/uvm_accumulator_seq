// UVM Monitor for the accumulator
// Samples DUT outputs every clock cycle and broadcasts transactions on the AP.
class accumulator_monitor extends uvm_monitor;

    `uvm_component_utils(accumulator_monitor)

    // Analysis port – connects to scoreboard / coverage collector
    uvm_analysis_port #(accumulator_transaction) ap;

    virtual accum_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual accum_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        accumulator_transaction txn;

        // Wait for reset to deassert before sampling
        @(posedge vif.monitor_cb.rst_n);
        `uvm_info(get_type_name(), "Reset deasserted – monitor active", UVM_MEDIUM)

        forever begin
            @(vif.monitor_cb);
            txn = accumulator_transaction::type_id::create("mon_txn");

            // Capture stimulus
            txn.acc_en  = vif.monitor_cb.acc_en;
            txn.clear   = vif.monitor_cb.clear;
            txn.data_in = vif.monitor_cb.data_in;

            // Capture response
            txn.acc_out  = vif.monitor_cb.acc_out;
            txn.overflow = vif.monitor_cb.overflow;

            `uvm_info(get_type_name(), txn.convert2string(), UVM_HIGH)
            ap.write(txn);
        end
    endtask

endclass

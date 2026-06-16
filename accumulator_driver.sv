// UVM Driver for the accumulator
class accumulator_driver extends uvm_driver #(accumulator_transaction);

    `uvm_component_utils(accumulator_driver)

    // Virtual interface handle
    virtual accum_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual accum_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        accumulator_transaction txn;

        // Initialise outputs before reset deasserts
        vif.driver_cb.acc_en  <= 1'b0;
        vif.driver_cb.clear   <= 1'b0;
        vif.driver_cb.data_in <= 8'h00;
        vif.driver_cb.rst_n   <= 1'b0;

        // Hold reset for 3 cycles
        repeat (3) @(vif.driver_cb);
        vif.driver_cb.rst_n <= 1'b1;
        @(vif.driver_cb);

        forever begin
            seq_item_port.get_next_item(txn);
            drive_txn(txn);
            seq_item_port.item_done();
        end
    endtask

    // Drive a single transaction onto the DUT pins
    protected task drive_txn(accumulator_transaction txn);
        @(vif.driver_cb);
        vif.driver_cb.acc_en  <= txn.acc_en;
        vif.driver_cb.clear   <= txn.clear;
        vif.driver_cb.data_in <= txn.data_in;

        `uvm_info(get_type_name(),
                  $sformatf("Driving: acc_en=%0b clear=%0b data_in=0x%0h",
                             txn.acc_en, txn.clear, txn.data_in),
                  UVM_HIGH)
    endtask

endclass

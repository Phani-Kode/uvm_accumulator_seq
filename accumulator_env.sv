// UVM Environment for the accumulator testbench
class accumulator_env extends uvm_env;

    `uvm_component_utils(accumulator_env)

    accumulator_agent      agent;
    accumulator_scoreboard scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = accumulator_agent::type_id::create("agent", this);
        scoreboard = accumulator_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // Wire agent's monitor analysis port to the scoreboard
        agent.ap.connect(scoreboard.analysis_export);
    endfunction

endclass

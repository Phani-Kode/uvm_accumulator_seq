# UVM Accumulator Sequence Testbench

A complete **UVM (Universal Verification Methodology)** verification environment for an 8-bit accumulator, demonstrating reusable transaction-level stimulus generation with sophisticated randomisation constraints.

---

## Repository Structure

```
uvm_accumulator_seq/
├── accumulator.sv            # DUT – 8-bit synchronous accumulator
├── accum_if.sv               # SystemVerilog interface + clocking blocks
├── accumulator_pkg.sv        # Package that bundles all UVM classes
├── accumulator_transaction.sv# UVM sequence item with rand constraints
├── accumulator_sequences.sv  # Sequence library (5 sequences)
├── accumulator_driver.sv     # UVM driver – pins → DUT
├── accumulator_monitor.sv    # UVM monitor – DUT → analysis port
├── accumulator_scoreboard.sv # Reference model + pass/fail checker
├── accumulator_agent.sv      # UVM agent (active: driver+mon+seqr)
├── accumulator_env.sv        # UVM environment
├── base_test.sv              # Test library (base_test, random_test,
│                             #   directed_test, full_test)
├── tb_top.sv                 # Testbench top – DUT + interface + run_test
├── filelist.f                # Compilation file list
└── Makefile                  # Build targets for Xcelium / Questa / VCS
```

---

## DUT – `accumulator.sv`

| Signal     | Dir | Width | Description                          |
|------------|-----|-------|--------------------------------------|
| `clk`      | in  | 1     | System clock                         |
| `rst_n`    | in  | 1     | Active-low synchronous reset         |
| `acc_en`   | in  | 1     | Enable accumulation this cycle       |
| `clear`    | in  | 1     | Synchronous clear (takes precedence) |
| `data_in`  | in  | 8     | Input value to accumulate            |
| `acc_out`  | out | 9     | Running total (extra bit for carry)  |
| `overflow` | out | 1     | Alias for `acc_out[8]`               |

---

## UVM Component Hierarchy

```
uvm_test_top  (base_test / random_test / directed_test / full_test)
└── env       (accumulator_env)
    ├── agent (accumulator_agent – ACTIVE)
    │   ├── sequencer  (uvm_sequencer)
    │   ├── driver     (accumulator_driver)
    │   └── monitor    (accumulator_monitor)  ──► ap
    └── scoreboard (accumulator_scoreboard) ◄── ap
```

---

## Sequence Library

| Sequence | Purpose |
|---|---|
| `accum_base_sequence` | Base class with `send_txn()` helper |
| `random_accum_sequence` | N fully randomised transactions (default 20) |
| `reset_sequence` | Issues one synchronous clear cycle |
| `directed_accum_sequence` | Fixed inputs: 10+20+30+40 = 100 |
| `overflow_stress_sequence` | Large values (192–255) to force overflow |
| `full_test_sequence` | Orchestrates all of the above in order |

---

## Transaction Constraints (`accumulator_transaction`)

```systemverilog
// clear and acc_en are mutually exclusive
constraint c_no_simultaneous_clear_acc { !(clear && acc_en); }

// Bias toward accumulate (70%), seldom clear (10%), idle sometimes
constraint c_op_dist {
    acc_en dist {1 := 70, 0 := 30};
    clear  dist {1 := 10, 0 := 90};
}

// Full 8-bit range for input data
constraint c_data_range { data_in inside {[0:255]}; }
```

---

## Running Simulations

### Prerequisites
- Cadence **Xcelium** (default), Mentor **Questa**, or Synopsys **VCS**
- UVM 1.2 library (bundled with all three simulators)

### Quick Start

```bash
# Compile + run the random test (Xcelium)
make run_random TOOL=xcelium

# Compile + run the directed test
make run_directed

# Compile + run the full orchestrated sequence
make run_full

# Run all three tests in sequence
make regress

# Use a specific seed for reproducibility
make run_random SEED=42

# Questa
make run_random TOOL=questa

# VCS
make run_random TOOL=vcs
```

### Command-line Test Selection

```bash
# Xcelium example – run full_test with verbose logging
xsim tb_top_sim +UVM_TESTNAME=full_test +UVM_VERBOSITY=UVM_HIGH
```

---

## Scoreboard

The scoreboard mirrors the DUT behaviour in pure SystemVerilog:

```
if (clear)       ref_acc = 0
else if (acc_en) ref_acc = ref_acc + data_in
```

Every monitored transaction is compared against the reference. A summary is printed at the end of `report_phase`:

```
[SCOREBOARD] Scoreboard summary: total=65 pass=65 fail=0
[SCOREBOARD] TEST PASSED
```

---

## Waveforms

A VCD dump (`accum_waves.vcd`) is generated automatically. Open with:

```bash
gtkwave accum_waves.vcd
```

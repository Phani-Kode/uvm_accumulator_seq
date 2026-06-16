## Makefile for UVM Accumulator Sequence Testbench
## Targets: compile | run_random | run_directed | run_full | clean
##
## Requires: Cadence Xcelium  – adjust TOOL variable for Questa / VCS

TOOL      ?= xcelium
TEST      ?= random_test
SEED      ?= 1
UVM_HOME  ?= $(shell printenv UVM_HOME)

# ------------------------------------------------------------------ #
#  Xcelium                                                            #
# ------------------------------------------------------------------ #
ifeq ($(TOOL), xcelium)
COMP_CMD = xvlog -sv -uvm -f filelist.f
ELAB_CMD = xelab tb_top -s tb_top_sim -uvm
SIM_CMD  = xsim tb_top_sim \
           +UVM_TESTNAME=$(TEST) \
           +ntb_random_seed=$(SEED) \
           +UVM_VERBOSITY=UVM_MEDIUM \
           -R
endif

# ------------------------------------------------------------------ #
#  Questa / ModelSim                                                  #
# ------------------------------------------------------------------ #
ifeq ($(TOOL), questa)
COMP_CMD = vlog -sv -mfcu +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv \
           -f filelist.f
ELAB_CMD = vopt tb_top -o tb_top_opt
SIM_CMD  = vsim -batch tb_top_opt \
           +UVM_TESTNAME=$(TEST) \
           +ntb_random_seed=$(SEED) \
           +UVM_VERBOSITY=UVM_MEDIUM \
           -do "run -all; quit -f"
endif

# ------------------------------------------------------------------ #
#  VCS                                                                #
# ------------------------------------------------------------------ #
ifeq ($(TOOL), vcs)
COMP_CMD = vcs -sverilog -ntb_opts uvm-1.2 -f filelist.f -o simv
ELAB_CMD = @echo "VCS: elab merged into compile step"
SIM_CMD  = ./simv \
           +UVM_TESTNAME=$(TEST) \
           +ntb_random_seed=$(SEED) \
           +UVM_VERBOSITY=UVM_MEDIUM
endif

# ------------------------------------------------------------------ #
#  Phony targets                                                      #
# ------------------------------------------------------------------ #
.PHONY: compile run run_random run_directed run_full regress clean

compile:
	$(COMP_CMD)
	$(ELAB_CMD)

run: compile
	$(SIM_CMD)

run_random: compile
	$(MAKE) run TEST=random_test

run_directed: compile
	$(MAKE) run TEST=directed_test

run_full: compile
	$(MAKE) run TEST=full_test

# Run all three tests in sequence
regress: run_random run_directed run_full

clean:
	rm -rf xsim.dir *.log *.pb *.jou *.vcd work/ csrc/ simv *.key
	rm -rf AN.DB xcelium.d *.diag

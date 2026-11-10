# AXI4 UVM Verification Environment

This repository contains a SystemVerilog/UVM verification environment for an
AMBA AXI4 slave connected to a synchronous single-port memory. The environment
generates constrained-random AXI traffic, observes the internal memory
interface, checks protocol and data behavior, and produces QuestaSim coverage
reports.

The project is intentionally split into:

- **RTL:** the AXI4 slave and its internal memory.
- **Active AXI agent:** drives read, write, idle, and reset scenarios.
- **Passive memory agent:** observes memory operations without driving the DUT.
- **Scoreboards:** compare AXI and memory behavior against reference models.
- **Coverage:** measures AXI transaction and memory-access scenarios.
- **Assertions:** checks selected AXI channel relationships during simulation.

## Contents

- [Repository status](#repository-status)
- [Problem being solved](#problem-being-solved)
- [Verification approach](#verification-approach)
- [DUT architecture](#dut-architecture)
- [Parameters and interface](#parameters-and-interface)
- [Verification architecture](#verification-architecture)
- [Stimulus and scenarios](#stimulus-and-scenarios)
- [Checking and coverage](#checking-and-coverage)
- [Repository layout](#repository-layout)
- [Prerequisites](#prerequisites)
- [Running the simulation](#running-the-simulation)
- [Coverage reports](#coverage-reports)
- [Known implementation boundaries](#known-implementation-boundaries)

## Repository status

The checked-in coverage reports show 100% of the measured bins for the
included regression:

- AXI functional coverage: **57/57 bins**
- Memory functional coverage: **7/7 bins**
- RTL statement, branch, condition, expression, FSM, and toggle coverage:
  **100%**

These results are the reports currently stored in `coverage/`. They are not a
promise that every future simulator run will produce the same result. The
simulation script also applies explicit RTL coverage exclusions; see
[`scripts/run.do`](scripts/run.do).

## Problem being solved

An AXI4 slave must correctly coordinate independent address, data, response,
and read-data channels while connecting those transactions to a synchronous
memory. Bugs can occur when:

- AXI `VALID` and `READY` handshakes are accepted in the wrong cycle.
- A burst has the wrong number of data beats or incorrect `WLAST`/`RLAST`.
- Synchronous memory latency is not handled before returning read data.
- Byte addresses are converted to incorrect word addresses.
- An access exceeds the available memory or crosses a 4-KB boundary.
- Reset leaves the interface or memory state in an invalid condition.

The purpose of this project is to find these errors through repeatable,
constrained-random verification rather than relying only on a few manually
selected transactions. It checks both the externally visible AXI behavior and
the internal memory operations that implement that behavior.

## Verification approach

The environment combines several complementary verification techniques:

1. **Constrained-random stimulus** explores read, write, idle, reset, burst,
   safe-address, out-of-range, and boundary-focused scenarios.
2. **An active AXI UVM agent** drives transactions through a sequencer and
   driver while an AXI monitor observes the resulting bus activity.
3. **A passive memory agent** monitors the internal memory interface without
   changing DUT behavior.
4. **Reference-model scoreboards** independently predict AXI responses and
   memory contents, then compare those predictions with observed behavior.
5. **Functional coverage** measures whether address regions, burst lengths,
   operations, and memory access types were exercised.
6. **SystemVerilog Assertions** check selected protocol relationships during
   simulation and report violations at the cycle where they occur.
7. **UVM factory override** replaces the base AXI driver with a delayed driver
   to introduce additional timing variation without changing the test or
   environment structure.
8. **RTL code coverage** measures exercised statements, branches, conditions,
   expressions, FSM states/transitions, and signal toggles.

## DUT architecture

The top-level DUT is the `axi4` module in [`rtl/axi4.v`](rtl/axi4.v). It
contains independent write and read state machines and instantiates
[`axi4_memory`](rtl/axi_memory.v).

### Write path

The write state machine uses these states:

```text
W_IDLE -> W_ADDR -> W_DATA -> W_RESP -> W_IDLE
```

It accepts an AXI write address, receives one or more data beats, writes valid
transfers to memory, and returns `BRESP` after the final beat.

### Read path

The read state machine uses these states:

```text
R_IDLE -> R_ADDR -> R_WAIT -> R_DATA -> R_IDLE
```

The `R_WAIT` state accounts for the synchronous memory read. Read data and
`RRESP` are then presented on the AXI read-data channel.

### Address handling

The external AXI address is byte-oriented. The DUT converts it to a word
address with `address >> 2` before accessing the 1024-word memory.

The DUT checks:

- Whether the address maps inside the configured memory depth.
- Whether a burst crosses a 4-KB boundary.

An invalid address or boundary-crossing burst returns `2'b10` (`SLVERR`) and
does not perform a normal memory transfer.

## Parameters and interface

The default design configuration is:

| Parameter | Value | Meaning |
|---|---:|---|
| `DATA_WIDTH` | 32 | AXI and memory data width |
| `ADDR_WIDTH` | 16 | External AXI address width |
| `MEMORY_DEPTH` / `DEPTH` | 1024 | Number of memory words |
| Memory word size | 4 bytes | 32-bit word |
| Total memory size | 4096 bytes | 4 KiB |

The main AXI parameters are defined in
[`tb/axi_para.sv`](tb/axi_para.sv). The memory scoreboard uses the matching
configuration in [`tb/MEM_Parameter_pkg.sv`](tb/MEM_Parameter_pkg.sv).

The AXI interface contains the standard five channels:

- Write address: `AWADDR`, `AWLEN`, `AWSIZE`, `AWVALID`, `AWREADY`
- Write data: `WDATA`, `WVALID`, `WLAST`, `WREADY`
- Write response: `BRESP`, `BVALID`, `BREADY`
- Read address: `ARADDR`, `ARLEN`, `ARSIZE`, `ARVALID`, `ARREADY`
- Read data: `RDATA`, `RRESP`, `RVALID`, `RLAST`, `RREADY`

## Verification architecture

```text
top
 |
 +-- axi4 DUT
 |    |
 |    +-- axi4_memory
 |    +-- bound mem_if
 |
 +-- axi_test
      |
      +-- axi_env
           |
           +-- Active AXI agent
           |    +-- axi_sequence
           |    +-- axi_sequencer
           |    +-- axi_driver
           |    +-- axi_monitor
           |
           +-- Passive memory agent
           |    +-- mem_monitor
           |
           +-- axi_scoreboard
           +-- mem_scoreboard
           +-- axi_coverage
           +-- mem_coverage
```

The top-level module is [`tb/a_top_tb.sv`](tb/a_top_tb.sv). It:

1. Instantiates `axi4`.
2. Generates a 4 ns-period clock.
3. Binds `mem_if` to the internal memory signals.
4. Places virtual interfaces in the UVM configuration database.
5. Starts `axi_test`.

The environment and its analysis connections are defined in
[`tb/a_env.sv`](tb/a_env.sv).

## Stimulus and scenarios

[`tb/a_sequence.sv`](tb/a_sequence.sv) generates 2,000 randomized
`axi_transaction` items. The transaction constraints in
[`tb/a_transaction.sv`](tb/a_transaction.sv) provide:

- `WRITE`, `READ`, and `IDLE` operations.
- An operation distribution of 35% write, 35% read, and 30% idle.
- Approximately 5% reset assertions.
- Single-beat and multi-beat bursts, with `AWLEN`/`ARLEN` ranging from 0 to
  255.
- Safe, boundary-focused, and out-of-range address modes.
- Invalid transactions intended to exercise `SLVERR` responses.

The test applies the UVM factory override shown in
[`tb/a_test.sv`](tb/a_test.sv):

```text
axi_driver -> axi_driver_delay
```

[`tb/a_delay_driver.sv`](tb/a_delay_driver.sv) inserts a random delay of zero
to three clock cycles before forwarding each item to the base driver's
`drive()` task.

Although burst length is randomized, the current driver forces `AWSIZE` and
`ARSIZE` to `3'd2`, which corresponds to 4-byte transfers. Burst-size
coverage is therefore not a separately randomized verification dimension.

## Checking and coverage

### AXI scoreboard

[`tb/a_scoreboard.sv`](tb/a_scoreboard.sv) maintains a reference memory and
checks:

- Reset values for AXI outputs.
- Write data and `WLAST`.
- `BRESP` for valid and invalid writes.
- Read data against previously written reference values.
- `RRESP` and `RLAST`.
- Idle-channel behavior.

The scoreboard prints pass and fail totals during its report phase.

### Memory scoreboard

[`tb/mem_scb.sv`](tb/mem_scb.sv) models the synchronous memory behavior and
checks reset, read, write, and idle cycles observed by
[`tb/mem_monitor.sv`](tb/mem_monitor.sv).

### Functional coverage

AXI functional coverage is implemented in
[`tb/a_coverage.sv`](tb/a_coverage.sv) and covers:

- Read and write address ranges.
- Read and write burst lengths.
- `AWVALID` and `ARVALID`.
- Operation type.
- Address mode.
- Operation/address-mode cross coverage.
- Address/length cross coverage.

Memory coverage is implemented in
[`tb/mem_coverage.sv`](tb/mem_coverage.sv) and covers:

- Five memory-address regions.
- Read versus write operation.

The checked-in report shows all 57 AXI bins and all 7 memory bins covered.

### Assertions

The interface in [`tb/AXI_intrf.sv`](tb/AXI_intrf.sv) instantiates eight
properties from [`tb/AXI_properties_pkg.sv`](tb/AXI_properties_pkg.sv). They
check selected relationships including:

- `BVALID` following a completed final write beat.
- `RREADY` behavior after a final read beat.
- `AWREADY` behavior after accepting an address.
- Mutual exclusion of selected `LAST`, address-valid, and ready signals.

The repository does not contain a separate assertion-coverage report.

## Repository layout

```text
AXI4-UVM-Verification-main/
|
|-- rtl/
|   |-- axi4.v                 AXI4 slave/controller
|   `-- axi_memory.v           Synchronous single-port memory
|
|-- tb/
|   |-- a_top_tb.sv            Simulation top
|   |-- a_test.sv              UVM test and factory override
|   |-- a_env.sv               UVM environment
|   |-- a_agent.sv             Active AXI agent
|   |-- a_transaction.sv       AXI sequence item and constraints
|   |-- a_sequence.sv          2,000-item randomized sequence
|   |-- a_sequencer.sv         AXI sequencer
|   |-- a_driver.sv            AXI driver
|   |-- a_delay_driver.sv      Delayed driver override
|   |-- a_monitor.sv           AXI monitor
|   |-- a_scoreboard.sv        AXI reference scoreboard
|   |-- a_coverage.sv          AXI functional coverage
|   |-- mem_agent.sv           Passive memory agent
|   |-- mem_monitor.sv         Memory monitor
|   |-- mem_transaction.sv     Memory transaction
|   |-- mem_scb.sv             Memory reference scoreboard
|   |-- mem_coverage.sv        Memory functional coverage
|   |-- AXI_intrf.sv           AXI interface and assertion instances
|   |-- mem_if.sv              Bound memory interface
|   |-- AXI_properties_pkg.sv  SVA property package
|   |-- axi_para.sv            AXI parameters and operation enum
|   |-- MEM_Parameter_pkg.sv   Memory scoreboard parameters
|   |-- common_cfg.sv          Shared UVM event configuration
|   `-- axi_pkg.sv             Package wrapper
|
|-- scripts/
|   |-- run.do                 QuestaSim compile/run/coverage script
|   |-- wave.do                Waveform setup
|   |-- dut_files.txt          RTL file list
|   |-- tb_files.txt           Testbench file list
|   `-- files.txt              Combined/reference file list
|
|-- coverage/                  Checked-in QuestaSim text reports
|-- docs/                      Project report PDF
`-- README.md
```

## Prerequisites

- QuestaSim or ModelSim with SystemVerilog and UVM 1.2 support.
- A simulator installation whose `vlog`, `vsim`, `vlib`, and `vcover`
  commands are available.
- A working directory containing this repository.

The supplied script compiles the RTL with code coverage and compiles the
testbench without RTL code coverage instrumentation:

```text
vlog -f dut_files.txt +cover -covercells
vlog -f tb_files.txt
```

## Running the simulation

`run.do` refers to `dut_files.txt` and `tb_files.txt` by their local names.
For that reason, start QuestaSim in the `scripts` directory, or change the
simulator working directory to `scripts` before running the script.

From the QuestaSim/ModelSim transcript:

```tcl
cd scripts
do run.do
```

Alternatively, open the simulator with `scripts` as its working directory and
run:

```tcl
do run.do
```

The script:

1. Creates the `work` library.
2. Compiles [`rtl/axi4.v`](rtl/axi4.v) and
   [`rtl/axi_memory.v`](rtl/axi_memory.v).
3. Compiles the UVM testbench from `tb_files.txt`.
4. Starts `work.top` with assertions and coverage enabled.
5. Loads [`scripts/wave.do`](scripts/wave.do).
6. Runs until the testbench completes.
7. Saves `coverage/cov.ucdb`.
8. Generates the text reports in `coverage/`.

The test name is selected in the top-level module with
`run_test("axi_test")`; a `+UVM_TESTNAME` plusarg is not required for the
provided setup.

## Coverage reports

The run script writes these reports directly under `coverage/`:

| Report | Contents |
|---|---|
| `cov.ucdb` | QuestaSim coverage database |
| `functional_coverage.txt` | AXI and memory covergroups |
| `all_code_coverage.txt` | Combined DUT code coverage |
| `line_coverage.txt` | Statement/line coverage |
| `toggle_coverage.txt` | Toggle coverage |
| `branch_coverage.txt` | Branch coverage |
| `condition_coverage.txt` | Condition coverage |
| `expression_coverage.txt` | Expression coverage |
| `fsm_coverage.txt` | FSM state and transition coverage |

The script applies exclusions for selected unreachable or intentionally
excluded RTL items before saving the UCDB. Review those exclusions in
[`scripts/run.do`](scripts/run.do) when interpreting percentages.

## Known implementation boundaries

The current repository is a verification project rather than a generic AXI4
VIP. In particular:

- The driver currently uses 4-byte transfers (`AWSIZE`/`ARSIZE = 2`).
- The DUT exposes only the AXI signals used by this project; IDs, strobes, and
other optional AXI features are not modeled. Burst support is limited to the
address, length, size, and last-beat behavior implemented here.
- The checked-in coverage reports are DUT-focused. The testbench itself is
  compiled without code coverage instrumentation.
- No separate assertion-coverage report is checked in.
- The run script uses relative file-list and output paths, so the simulator
  working directory determines where the generated `work` library and
  `coverage/` directory are created.
- The source file `MEM_Parameter_pkg.sv` declares the package
  `parameters_pkg`; the filename and package name are therefore intentionally
  different.

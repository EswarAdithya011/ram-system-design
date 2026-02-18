# BRAM IP System Design and Validation

A robust hardware verification architecture designed to automate the testing and validation of FPGA Block RAM (BRAM). This subsystem ensures data integrity by managing a high-speed data path that generates, stores, and validates deterministic patterns across the memory fabric without requiring external processor intervention.

---

### System Architecture

The **ram_system_design** project is a specialized hardware controller that orchestrates a closed-loop data lifecycle. It is built to ensure that every bit written to memory is precisely what is read back, even under high-speed operation.

* **Pattern Generation Phase**: The system utilizes a hardware-based data generator to populate the BRAM with predictable, incremental 32-bit data streams.
* **Frame-Based Control**: A dedicated controller manages the transition between write and read cycles, ensuring 64-beat burst alignment for every diagnostic frame.
* **Real-Time Validation**: The subsystem triggers a validation cycle where the BRAM output is compared against a cycle-accurate internal reference model.
* **Diagnostic Telemetry**: Rather than a simple pass/fail, the system tracks an `error_data_cntr` to provide granular insight into exactly how many data mismatches occurred within a frame.

---

### Repository Hierarchy

```text
├── .gitignore               # Optimized for Vivado to exclude logs and cache
├── rtl/                     # Synthesizable Verilog Source Code
│   ├── top_module.v         # System Controller & Top-Level Integration
│   ├── data_generator.v     # Parametric pattern generation logic
│   └── data_checker.v       # Diagnostic comparison and error tracking
├── tb/                      # Verification Suite
│   └── top_module_tb.v      # Manual frame-control testbench
├── Imgs/                    # Technical diagrams and waveform screenshots
└── sim/                     # Vivado project structure and simulation files

```

---

### Features

#### **Dynamic Fault Simulation (Error Injection)**

To prove the reliability of the validation logic, this design features a **Configurable Error Injection** port. This allows an engineer to intentionally flip bits at specific memory addresses during the write phase (Addresses 10, 20, and 30). This verifies that the diagnostic checker correctly identifies, counts, and flags hardware mismatches as they happen.

#### **Pipeline Synchronization**

The design handles the inherent latency of the Block RAM (1 clock cycle for read access) by utilizing a multi-stage pipeline delay unit. This ensures that the reference data and the actual RAM data arrive at the comparator at the exact same clock edge for a true cycle-accurate check.

#### **Hardware Configuration**

* **`i_start_system` / `i_stop_system`**: Physical control pins that allow for one-shot frame testing or continuous diagnostic loops.
* **`i_error_en`**: A hardware switch to toggle the error injection engine for validation testing.

---

### Execution Guide

#### **Simulation Workflow**

1. **Initialize**: Open Vivado and load the source files from `rtl/` and `tb/`.
2. **Configuration**: Set the simulation runtime to **5000ns** to allow for full frame processing and inter-frame pauses.
3. **Observation**: Monitor the `data_sets_generated` and `data_sets_matched` counters in the waveform to verify system health.

#### **Validation Scenarios**

The included testbench is programmed to run three sequential validation cycles:

* **Cycle 1**: Error Injection enabled (Result: `data_sets_matched` stays at 0 as errors are detected).
* **Cycle 2**: Normal Operation (Result: `data_sets_matched` increments to 1).
* **Cycle 3**: Error Injection re-enabled to confirm diagnostic repeatability.

---

### Impact & Utility

This subsystem provides a scalable template for any FPGA project requiring high-reliability memory storage. By combining **Autonomous Control** with **Deterministic Validation**, it creates a "self-verifying" memory path essential for mission-critical digital systems.

---

**Engineer:** Korrapolu Eswar Adithya

**Environment:** Xilinx Vivado (2024.1), Verilog HDL, Git

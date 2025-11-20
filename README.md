# Caravel User Project - AES & SHA256 Cryptographic Accelerators

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Initial User Prompt
Create a user project with SHA and AES

## Project Overview
This Caravel user project integrates two cryptographic accelerators (AES-128/192/256 and SHA-256) into the Efabless Caravel SoC framework. Both peripherals are accessible via Wishbone B4 (classic) bus interface, providing hardware-accelerated encryption and hashing capabilities for embedded applications.

## Key Features
- **AES Accelerator (EF_AES)**
  - Supports AES-128, AES-192, and AES-256
  - Configurable encryption/decryption modes
  - Wishbone B4 interface
  - Hardware-optimized implementation
  
- **SHA-256 Accelerator (EF_SHA256)**
  - Hardware implementation of SHA-256 hash function
  - Wishbone B4 interface
  - Optimized for performance and area

- **Programmable Interrupt Controller**
  - 16 IRQ sources with 4-level priority
  - Per-IRQ enable masks + global enable
  - Edge and level triggering support

## Address Map
Base address: `0x3000_0000`

| Peripheral | Base Address | Size | Description |
|-----------|--------------|------|-------------|
| AES       | 0x3000_0000  | 64KB | AES Cryptographic Engine |
| SHA256    | 0x3001_0000  | 64KB | SHA-256 Hash Engine |
| PIC       | 0x3002_0000  | 64KB | Programmable Interrupt Controller |

## Current Status
🟡 **In Progress** - Project Setup Phase

### Implementation Progress
- [x] Caravel template copied
- [x] Initial documentation structure created
- [ ] IP integration in progress
- [ ] RTL development pending
- [ ] Verification pending
- [ ] Physical design pending

## Project Structure
```
AES_SHA/
├── docs/                      # Documentation
│   ├── register_map.md       # Register definitions
│   ├── pad_map.md           # GPIO pad assignments
│   ├── integration_notes.md # Integration guide
│   └── retrospective.md     # Project retrospective
├── verilog/
│   ├── rtl/                 # RTL source files
│   ├── gl/                  # Gate-level netlists
│   └── dv/                  # Design verification
│       └── cocotb/          # Cocotb testbenches
├── openlane/                # OpenLane configurations
│   ├── user_project/
│   └── user_project_wrapper/
├── fw/                      # Firmware examples
└── gds/                     # Final GDSII files
```

## Technology Stack
- **PDK**: SKY130A (Google/Skywater 130nm)
- **HDL**: Verilog-2005
- **Bus Protocol**: Wishbone B4 Classic
- **Verification**: cocotb + caravel-cocotb
- **Synthesis & PnR**: OpenLane/LibreLane
- **IPs**: NativeChips verified IP library

## Next Steps
1. Integrate AES and SHA256 IP cores from /nc/ip
2. Implement Wishbone bus infrastructure
3. Create user_project and user_project_wrapper modules
4. Develop comprehensive verification tests
5. Generate firmware drivers and examples
6. Complete physical design flow

## Documentation
- [Register Map](docs/register_map.md) - Peripheral register definitions
- [Pad Map](docs/pad_map.md) - GPIO configuration and assignments
- [Integration Notes](docs/integration_notes.md) - Design integration details

## License
Apache License 2.0
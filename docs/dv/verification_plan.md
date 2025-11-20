# Verification Plan - AES & SHA256 Caravel User Project

## Overview
This document outlines the verification strategy for the AES and SHA256 cryptographic accelerators integrated into the Caravel SoC framework.

## Verification Environment
- **Framework**: caravel-cocotb
- **Clock Frequency**: 40 MHz (25 ns period)
- **PDK**: SKY130A
- **Simulation Types**: RTL, Gate-Level (GL)

## Verification Strategy

### 1. Communication Protocol
- **VGPIO Handshake**: All tests use Virtual GPIO (VGPIO) at address `0x30FFFFFC` for firmware-testbench synchronization
- **Pulse Mapping**: Firmware writes milestone values (1, 2, 3, etc.) to VGPIO output; Python testbench waits for these values
- **IP Type**: Register-only peripherals (Template 2) - no external GPIO interfaces required

### 2. Test Organization

#### Test Categories
1. **Peripheral Integration Tests** - Individual IP verification
   - AES peripheral test
   - SHA256 peripheral test
2. **System Integration Test** - Full system verification
   - Bus decoding and addressing
   - IRQ integration
   - Multi-peripheral interaction

### 3. Test Plan Details

#### Test 1: AES Peripheral Integration (`aes_test`)
**Objective**: Verify AES-128 encryption functionality

**Firmware Flow**:
1. VGPIO=1: Firmware ready, user interface enabled
2. VGPIO=2: AES peripheral enabled via GCLK
3. VGPIO=3: Key and plaintext written to AES registers
4. VGPIO=4: Encryption initiated (INIT + NEXT commands)
5. VGPIO=5: Ciphertext read and validated
6. VGPIO=6: PASS (if correct) or VGPIO=7: FAIL (if incorrect)

**Test Vectors**:
- Algorithm: AES-128
- Key: `0x2b7e151628aed2a6abf7158809cf4f3c`
- Plaintext: `0x3243f6a8885a308d313198a2e0370734`
- Expected Ciphertext: `0x3925841d02dc09fbdc118597196a0b32`

**Verification Checks**:
- Wishbone bus transactions complete successfully
- AES READY status bit asserts after operation
- Output ciphertext matches golden reference
- IRQ assertion on completion (optional)

**Timeout**: 1,000,000 cycles

---

#### Test 2: SHA256 Peripheral Integration (`sha256_test`)
**Objective**: Verify SHA-256 hash computation

**Firmware Flow**:
1. VGPIO=1: Firmware ready, user interface enabled
2. VGPIO=2: SHA256 peripheral enabled via GCLK
3. VGPIO=3: Input message block written to SHA256 registers
4. VGPIO=4: Hash initiated (INIT + NEXT commands)
5. VGPIO=5: Digest read and validated
6. VGPIO=6: PASS (if correct) or VGPIO=7: FAIL (if incorrect)

**Test Vectors**:
- Input: `"abc"` (single block, padded per SHA-256 spec)
- Expected Digest: `0xba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad`

**Verification Checks**:
- Wishbone bus transactions complete successfully
- SHA256 READY status bit asserts after operation
- Output digest matches NIST reference
- IRQ assertion on completion (optional)

**Timeout**: 1,500,000 cycles

---

#### Test 3: System Integration (`system_test`)
**Objective**: Verify full system operation with multiple peripherals and IRQ controller

**Firmware Flow**:
1. VGPIO=1: Firmware ready
2. VGPIO=2: AES operation completed
3. VGPIO=3: SHA256 operation completed
4. VGPIO=4: PIC configuration verified
5. VGPIO=5: Sequential peripheral access verified
6. VGPIO=6: PASS

**Verification Checks**:
- Address decoding works correctly (AES @ 0x3000_0000, SHA256 @ 0x3001_0000, PIC @ 0x3002_0000)
- No bus collisions or decode errors
- IRQ lines properly routed to PIC
- PIC consolidates peripheral IRQs to user_irq[0]
- Sequential peripheral operations do not interfere

**Timeout**: 2,000,000 cycles

---

### 4. Coverage Metrics

#### Functional Coverage
- [x] AES-128 encryption (basic operation)
- [ ] AES-192 encryption (extended)
- [ ] AES-256 encryption (extended)
- [ ] AES decryption (extended)
- [x] SHA-256 single-block hash
- [ ] SHA-256 multi-block hash (extended)
- [x] Wishbone read/write transactions
- [x] Address decoding (3 peripherals)
- [x] IRQ generation and routing
- [ ] PIC priority handling (extended)
- [ ] PIC edge/level triggering (extended)

#### Code Coverage Goals
- **Line Coverage**: >90% for user_project RTL
- **Branch Coverage**: >85% for bus splitter and control logic
- **Toggle Coverage**: >80% for peripheral interfaces

### 5. Success Criteria

**Minimum Passing Criteria (RTL)**:
- All 3 tests pass with correct VGPIO=6 (PASS) signal
- No bus protocol violations
- No timing violations in RTL simulation
- All peripheral operations produce correct results

**Gate-Level Passing Criteria**:
- All RTL tests also pass in GL simulation
- No X-propagation issues
- Timing checks clean (for GL_SDF)

### 6. Known Limitations
- Tests focus on register-only verification (no external GPIO exercised)
- No exhaustive cryptographic validation (minimal test vectors)
- PIC verification is basic (priority and trigger modes not fully tested)
- No power state transitions tested

### 7. Microagent Knowledge Requirements
Before creating tests for each peripheral, trigger the appropriate verification microagents:
- AES: `echo "wakeup_aes_verification"` - **MUST DO BEFORE AES TEST**
- SHA256: `echo "wakeup_sha256_verification"` - **MUST DO BEFORE SHA256 TEST**

### 8. Test Development Order
1. Create VirtualGPIOModel.py (common infrastructure)
2. **aes_test** (trigger AES microagent first)
3. **sha256_test** (trigger SHA256 microagent first)
4. **system_test** (integration)
5. Run all tests in RTL
6. Fix any failures
7. Run all tests in GL
8. Generate verification summary

---

## References
- EF_AES IP Documentation: `/workspace/AES_SHA/ip/EF_AES/README.md`
- EF_SHA256 IP Documentation: `/workspace/AES_SHA/ip/EF_SHA256/README.md`
- Register Map: `/workspace/AES_SHA/docs/register_map.md`
- Integration Notes: `/workspace/AES_SHA/docs/integration_notes.md`

# Register Map

## Overview
This document defines the register-level interface for all peripherals in the AES_SHA Caravel user project.

**Base Address**: `0x3000_0000`

| Peripheral | Base Address | End Address | Size |
|-----------|--------------|-------------|------|
| AES       | 0x3000_0000  | 0x3000_FFFF | 64KB |
| SHA256    | 0x3001_0000  | 0x3001_FFFF | 64KB |
| PIC       | 0x3002_0000  | 0x3002_FFFF | 64KB |

---

## AES Cryptographic Engine

**Base Address**: `0x3000_0000`

### Register Summary

| Name | Offset | Reset Value | Access | Description |
|------|--------|-------------|--------|-------------|
| STATUS | 0x0000 | 0x00000000 | R | Status register (bit 6: ready, bit 7: valid) |
| CTRL | 0x0004 | 0x00000000 | W | Control register (init, next, encdec, keylen) |
| KEY0 | 0x0008 | 0x00000000 | W | Key bits [31:0] |
| KEY1 | 0x000C | 0x00000000 | W | Key bits [63:32] |
| KEY2 | 0x0010 | 0x00000000 | W | Key bits [95:64] |
| KEY3 | 0x0014 | 0x00000000 | W | Key bits [127:96] |
| KEY4 | 0x0018 | 0x00000000 | W | Key bits [159:128] (256-bit only) |
| KEY5 | 0x001C | 0x00000000 | W | Key bits [191:160] (256-bit only) |
| KEY6 | 0x0020 | 0x00000000 | W | Key bits [223:192] (256-bit only) |
| KEY7 | 0x0024 | 0x00000000 | W | Key bits [255:224] (256-bit only) |
| BLOCK0 | 0x0028 | 0x00000000 | W | Input block bits [31:0] |
| BLOCK1 | 0x002C | 0x00000000 | W | Input block bits [63:32] |
| BLOCK2 | 0x0030 | 0x00000000 | W | Input block bits [95:64] |
| BLOCK3 | 0x0034 | 0x00000000 | W | Input block bits [127:96] |
| RESULT0 | 0x0038 | 0x00000000 | R | Output result bits [31:0] |
| RESULT1 | 0x003C | 0x00000000 | R | Output result bits [63:32] |
| RESULT2 | 0x0040 | 0x00000000 | R | Output result bits [95:64] |
| RESULT3 | 0x0044 | 0x00000000 | R | Output result bits [127:96] |
| IM | 0xFF00 | 0x00000000 | RW | Interrupt Mask Register |
| MIS | 0xFF04 | 0x00000000 | R | Masked Interrupt Status |
| RIS | 0xFF08 | 0x00000000 | R | Raw Interrupt Status |
| IC | 0xFF0C | 0x00000000 | W | Interrupt Clear Register |
| GCLK | 0xFF10 | 0x00000000 | RW | Gated Clock Enable |

### STATUS Register [0x0000]

| Bits | Name | Type | Reset | Description |
|------|------|------|-------|-------------|
| 31:8 | - | - | 0x0 | Reserved |
| 7 | VALID | R | 0 | Result is valid (1 = valid, 0 = invalid) |
| 6 | READY | R | 0 | Ready to start operation (1 = ready, 0 = busy) |
| 5:0 | - | - | 0x0 | Reserved |

### CTRL Register [0x0004]

| Bits | Name | Type | Reset | Description |
|------|------|------|-------|-------------|
| 31:4 | - | - | 0x0 | Reserved |
| 3 | KEYLEN | W | 0 | Key length (0 = 128-bit, 1 = 256-bit) |
| 2 | ENCDEC | W | 0 | Operation mode (0 = decrypt, 1 = encrypt) |
| 1 | NEXT | W | 0 | Process next block (pulse) |
| 0 | INIT | W | 0 | Initialize with new key (pulse) |

---

## SHA-256 Hash Engine

**Base Address**: `0x3001_0000`

### Register Summary

| Name | Offset | Reset Value | Access | Description |
|------|--------|-------------|--------|-------------|
| STATUS | 0x0000 | 0x00000000 | R | Status register (bit 6: ready, bit 7: valid) |
| CTRL | 0x0004 | 0x00000000 | W | Control register (init, next, mode) |
| BLOCK0 | 0x0008 | 0x00000000 | W | Input block bits [31:0] |
| BLOCK1 | 0x000C | 0x00000000 | W | Input block bits [63:32] |
| BLOCK2 | 0x0010 | 0x00000000 | W | Input block bits [95:64] |
| BLOCK3 | 0x0014 | 0x00000000 | W | Input block bits [127:96] |
| BLOCK4 | 0x0018 | 0x00000000 | W | Input block bits [159:128] |
| BLOCK5 | 0x001C | 0x00000000 | W | Input block bits [191:160] |
| BLOCK6 | 0x0020 | 0x00000000 | W | Input block bits [223:192] |
| BLOCK7 | 0x0024 | 0x00000000 | W | Input block bits [255:224] |
| BLOCK8 | 0x0028 | 0x00000000 | W | Input block bits [287:256] |
| BLOCK9 | 0x002C | 0x00000000 | W | Input block bits [319:288] |
| BLOCK10 | 0x0030 | 0x00000000 | W | Input block bits [351:320] |
| BLOCK11 | 0x0034 | 0x00000000 | W | Input block bits [383:352] |
| BLOCK12 | 0x0038 | 0x00000000 | W | Input block bits [415:384] |
| BLOCK13 | 0x003C | 0x00000000 | W | Input block bits [447:416] |
| BLOCK14 | 0x0040 | 0x00000000 | W | Input block bits [479:448] |
| BLOCK15 | 0x0044 | 0x00000000 | W | Input block bits [511:480] |
| DIGEST0 | 0x0048 | 0x00000000 | R | Output digest bits [31:0] |
| DIGEST1 | 0x004C | 0x00000000 | R | Output digest bits [63:32] |
| DIGEST2 | 0x0050 | 0x00000000 | R | Output digest bits [95:64] |
| DIGEST3 | 0x0054 | 0x00000000 | R | Output digest bits [127:96] |
| DIGEST4 | 0x0058 | 0x00000000 | R | Output digest bits [159:128] |
| DIGEST5 | 0x005C | 0x00000000 | R | Output digest bits [191:160] |
| DIGEST6 | 0x0060 | 0x00000000 | R | Output digest bits [223:192] |
| DIGEST7 | 0x0064 | 0x00000000 | R | Output digest bits [255:224] |
| IM | 0xFF00 | 0x00000000 | RW | Interrupt Mask Register |
| MIS | 0xFF04 | 0x00000000 | R | Masked Interrupt Status |
| RIS | 0xFF08 | 0x00000000 | R | Raw Interrupt Status |
| IC | 0xFF0C | 0x00000000 | W | Interrupt Clear Register |
| GCLK | 0xFF10 | 0x00000000 | RW | Gated Clock Enable |

### STATUS Register [0x0000]

| Bits | Name | Type | Reset | Description |
|------|------|------|-------|-------------|
| 31:8 | - | - | 0x0 | Reserved |
| 7 | DIGEST_VALID | R | 0 | Digest is valid (1 = valid, 0 = invalid) |
| 6 | READY | R | 0 | Ready to start operation (1 = ready, 0 = busy) |
| 5:0 | - | - | 0x0 | Reserved |

### CTRL Register [0x0004]

| Bits | Name | Type | Reset | Description |
|------|------|------|-------|-------------|
| 31:3 | - | - | 0x0 | Reserved |
| 2 | MODE | W | 0 | Hash mode (0 = SHA-224, 1 = SHA-256) |
| 1 | NEXT | W | 0 | Process next block (pulse) |
| 0 | INIT | W | 0 | Initialize hash operation (pulse) |

---

## Programmable Interrupt Controller (PIC)

**Base Address**: `0x3002_0000`

### Register Summary

| Name | Offset | Reset Value | Access | Description |
|------|--------|-------------|--------|-------------|
| IM | 0x0000 | 0x00000000 | RW | Interrupt Mask (per-IRQ enable) |
| RIS | 0x0004 | 0x00000000 | R | Raw Interrupt Status |
| MIS | 0x0008 | 0x00000000 | R | Masked Interrupt Status |
| IC | 0x000C | 0x00000000 | W | Interrupt Clear (W1C) |
| GE | 0x0010 | 0x00000000 | RW | Global Enable |
| TRIG | 0x0014 | 0x00000000 | RW | Trigger Mode (0=level, 1=edge) |
| PRIO0 | 0x0018 | 0x00000000 | RW | Priority for IRQ[3:0] |
| PRIO1 | 0x001C | 0x00000000 | RW | Priority for IRQ[7:4] |
| PRIO2 | 0x0020 | 0x00000000 | RW | Priority for IRQ[11:8] |
| PRIO3 | 0x0024 | 0x00000000 | RW | Priority for IRQ[15:12] |

### Interrupt Sources

| IRQ# | Source | Description |
|------|--------|-------------|
| 0 | AES | AES operation complete |
| 1 | SHA256 | SHA-256 hash complete |
| 2-15 | - | Reserved for future use |

### Priority Encoding

Each IRQ can be assigned one of 4 priority levels (2 bits):
- `00`: Priority 0 (Highest)
- `01`: Priority 1
- `10`: Priority 2
- `11`: Priority 3 (Lowest)

---

## Programming Examples

### AES Encryption Example

```c
// 1. Write key (128-bit example)
*(uint32_t*)(0x3000_0008) = key_word0;
*(uint32_t*)(0x3000_000C) = key_word1;
*(uint32_t*)(0x3000_0010) = key_word2;
*(uint32_t*)(0x3000_0014) = key_word3;

// 2. Initialize with key
*(uint32_t*)(0x3000_0004) = 0x05;  // INIT=1, ENCDEC=1 (encrypt)

// 3. Wait for ready
while (!(*(uint32_t*)(0x3000_0000) & 0x40));

// 4. Write plaintext block
*(uint32_t*)(0x3000_0028) = plain_word0;
*(uint32_t*)(0x3000_002C) = plain_word1;
*(uint32_t*)(0x3000_0030) = plain_word2;
*(uint32_t*)(0x3000_0034) = plain_word3;

// 5. Start encryption
*(uint32_t*)(0x3000_0004) = 0x06;  // NEXT=1, ENCDEC=1

// 6. Wait for valid
while (!(*(uint32_t*)(0x3000_0000) & 0x80));

// 7. Read ciphertext
cipher_word0 = *(uint32_t*)(0x3000_0038);
cipher_word1 = *(uint32_t*)(0x3000_003C);
cipher_word2 = *(uint32_t*)(0x3000_0040);
cipher_word3 = *(uint32_t*)(0x3000_0044);
```

### SHA-256 Hashing Example

```c
// 1. Initialize hash
*(uint32_t*)(0x3001_0004) = 0x05;  // INIT=1, MODE=1 (SHA-256)

// 2. Wait for ready
while (!(*(uint32_t*)(0x3001_0000) & 0x40));

// 3. Write message block (512 bits)
*(uint32_t*)(0x3001_0008) = block_word0;
// ... write all 16 words
*(uint32_t*)(0x3001_0044) = block_word15;

// 4. Process block
*(uint32_t*)(0x3001_0004) = 0x06;  // NEXT=1, MODE=1

// 5. Wait for valid
while (!(*(uint32_t*)(0x3001_0000) & 0x80));

// 6. Read digest (256 bits)
digest_word0 = *(uint32_t*)(0x3001_0048);
// ... read all 8 words
digest_word7 = *(uint32_t*)(0x3001_0064);
```

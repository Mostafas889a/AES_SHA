#include <firmware_apis.h>
#include "EF_AES.h"

// Virtual GPIO register address
#define VGPIO_REG_ADDR 0x30FFFFFC

// Virtual GPIO APIs
void vgpio_write_output(uint16_t value)
{
    volatile uint32_t *vgpio_reg = (volatile uint32_t *)VGPIO_REG_ADDR;
    uint32_t reg_val = *vgpio_reg;
    reg_val = (reg_val & 0xFFFF0000) | (value & 0xFFFF);
    *vgpio_reg = reg_val;
}

uint16_t vgpio_read_input(void)
{
    volatile uint32_t *vgpio_reg = (volatile uint32_t *)VGPIO_REG_ADDR;
    uint32_t reg_val = *vgpio_reg;
    return (uint16_t)((reg_val >> 16) & 0xFFFF);
}

void vgpio_wait_val(uint16_t val)
{
    while (vgpio_read_input() != val);
}

void main(void)
{
    // Disable housekeeping SPI
    enableHkSpi(false);
    
    // Configure GPIOs (no external pads needed for AES)
    GPIOs_loadConfigs();
    
    // Enable user interface for Wishbone access
    User_enableIF();
    
    // Signal firmware ready
    vgpio_write_output(1);
    
    // Set AES base address (peripheral 0 at 0x30000000)
    AES_setBaseAddress(0x30000000);
    
    // Enable AES peripheral via GCLK
    AES_enableGCLK();
    
    // Signal peripheral enabled
    vgpio_write_output(2);
    
    // Test vectors for AES-128 encryption
    // Key: 2b7e151628aed2a6abf7158809cf4f3c
    uint32_t key[4] = {0x2b7e1516, 0x28aed2a6, 0xabf71588, 0x09cf4f3c};
    
    // Plaintext: 3243f6a8885a308d313198a2e0370734
    uint32_t plaintext[4] = {0x3243f6a8, 0x885a308d, 0x313198a2, 0xe0370734};
    
    // Expected ciphertext: 3925841d02dc09fbdc118597196a0b32
    uint32_t expected_ciphertext[4] = {0x3925841d, 0x02dc09fb, 0xdc118597, 0x196a0b32};
    
    uint32_t ciphertext[4];
    
    // Signal key and plaintext written
    vgpio_write_output(3);
    
    // Perform AES-128 encryption
    AES_Status_t status = AES_encrypt128(key, plaintext, ciphertext, 0);
    
    // Signal encryption initiated
    vgpio_write_output(4);
    
    if (status != AES_OK) {
        // Encryption failed
        vgpio_write_output(7);  // FAIL
        return;
    }
    
    // Signal ciphertext read
    vgpio_write_output(5);
    
    // Verify ciphertext matches expected value
    int match = 1;
    for (int i = 0; i < 4; i++) {
        if (ciphertext[i] != expected_ciphertext[i]) {
            match = 0;
            break;
        }
    }
    
    if (match) {
        vgpio_write_output(6);  // PASS
    } else {
        vgpio_write_output(7);  // FAIL
    }
}

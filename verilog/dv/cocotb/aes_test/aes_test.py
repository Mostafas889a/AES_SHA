import cocotb
from caravel_cocotb.caravel_interfaces import test_configure, report_test
import sys
sys.path.append("..")
from VirtualGPIOModel import VirtualGPIOModel

@cocotb.test()
@report_test
async def aes_test(dut):
    """Test AES-128 encryption functionality"""
    
    # Configure environment with extended timeout for crypto operations
    caravelEnv = await test_configure(dut, timeout_cycles=1000000)
    cocotb.log.info("[TEST] Starting AES peripheral test")
    await caravelEnv.release_csb()
    
    # Initialize virtual GPIO model
    vgpio = VirtualGPIOModel(caravelEnv)
    vgpio.start()
    
    cocotb.log.info("[TEST] Waiting for firmware Virtual GPIO events...")
    
    # 1. Firmware ready
    await vgpio.wait_output(1)
    cocotb.log.info("[TEST] ✓ Firmware ready, user interface enabled")
    
    # 2. Peripheral enabled
    await vgpio.wait_output(2)
    cocotb.log.info("[TEST] ✓ AES peripheral enabled via GCLK")
    
    # 3. Key and plaintext written
    await vgpio.wait_output(3)
    cocotb.log.info("[TEST] ✓ Test vectors loaded (Key and Plaintext)")
    
    # 4. Encryption initiated
    await vgpio.wait_output(4)
    cocotb.log.info("[TEST] ✓ AES-128 encryption operation initiated")
    
    # 5. Ciphertext read
    await vgpio.wait_output(5)
    cocotb.log.info("[TEST] ✓ Ciphertext read from AES peripheral")
    
    # 6. Wait for PASS (6) or FAIL (7)
    final_output = 0
    max_wait = 100000
    wait_count = 0
    
    while wait_count < max_wait:
        final_output = vgpio.get_output()
        if final_output == 6 or final_output == 7:
            break
        await cocotb.triggers.RisingEdge(caravelEnv.clk)
        wait_count += 1
    
    if final_output == 6:
        cocotb.log.info("[TEST] ✓ PASS: Ciphertext matches expected value")
        cocotb.log.info("[TEST] AES-128 encryption test completed successfully!")
    elif final_output == 7:
        cocotb.log.error("[TEST] ✗ FAIL: Ciphertext does not match expected value")
        assert False, "AES encryption produced incorrect result"
    else:
        cocotb.log.error(f"[TEST] ✗ TIMEOUT: Final output stuck at {final_output}")
        assert False, "Test timed out waiting for result"
    
    cocotb.log.info("[TEST] === AES Test Summary ===")
    cocotb.log.info("[TEST] Test Vector: AES-128")
    cocotb.log.info("[TEST] Key:       0x2b7e151628aed2a6abf7158809cf4f3c")
    cocotb.log.info("[TEST] Plaintext: 0x3243f6a8885a308d313198a2e0370734")
    cocotb.log.info("[TEST] Expected:  0x3925841d02dc09fbdc118597196a0b32")
    cocotb.log.info("[TEST] Result:    PASS")

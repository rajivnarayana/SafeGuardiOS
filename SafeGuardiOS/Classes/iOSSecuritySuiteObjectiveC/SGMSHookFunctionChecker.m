#import "SGMSHookFunctionChecker.h"
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <sys/mman.h>

// ARM64 instruction masks and values
#define LDR_X16_MASK    0xFFF00000
#define LDR_X16_VALUE   0x58000000
#define BR_X16_MASK     0xFFFFFC1F
#define BR_X16_VALUE    0xD61F0200

typedef NS_ENUM(NSInteger, SGMSHookInstruction) {
    SGMSHookInstructionLDRX16,
    SGMSHookInstructionBRX16
};

@implementation SGMSHookFunctionChecker

+ (BOOL)amIMSHooked:(void *)functionAddr {
#if defined(__arm64__)
    if (!functionAddr) {
        return NO;
    }
    
    uint32_t *instructions = (uint32_t *)functionAddr;
    
    // Check for LDR X16 instruction
    uint32_t ldrInstruction = instructions[0];
    if ((ldrInstruction & LDR_X16_MASK) != LDR_X16_VALUE) {
        return NO;
    }
    
    // Check for BR X16 instruction
    uint32_t brInstruction = instructions[1];
    if ((brInstruction & BR_X16_MASK) != BR_X16_VALUE) {
        return NO;
    }
    
    return YES;
#else
    return NO;
#endif
}

+ (void *)denyMSHook:(void *)functionAddr {
#if defined(__arm64__)
    if (!functionAddr || ![self amIMSHooked:functionAddr]) {
        return NULL;
    }
    
    // Size of replaced instructions (16 bytes on ARM64)
    const size_t hookSize = 16;
    uint32_t *instructions = (uint32_t *)functionAddr;
    
    // Get the hook target address
    uint64_t targetAddr;
    memcpy(&targetAddr, instructions + 2, sizeof(uint64_t));
    
    // Get page size
    size_t pageSize = sysconf(_SC_PAGESIZE);
    uintptr_t pageStart = (uintptr_t)functionAddr & ~(pageSize - 1);
    
    // Make the page writable
    if (mprotect((void *)pageStart, pageSize, PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
        return NULL;
    }
    
    // Copy original instructions from hook target
    uint32_t originalInstructions[hookSize / sizeof(uint32_t)];
    memcpy(originalInstructions, (void *)targetAddr, hookSize);
    
    // Restore original instructions
    memcpy(functionAddr, originalInstructions, hookSize);
    
    // Restore page protection
    mprotect((void *)pageStart, pageSize, PROT_READ | PROT_EXEC);
    
    return (void *)targetAddr;
#else
    return NULL;
#endif
}

@end

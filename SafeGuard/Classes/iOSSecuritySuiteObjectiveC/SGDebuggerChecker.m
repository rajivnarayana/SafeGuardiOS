#import "SGDebuggerChecker.h"
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach/mach.h>

@implementation SGDebuggerChecker

// https://developer.apple.com/library/archive/qa/qa1361/_index.html
+ (BOOL)amIDebugged {
    struct kinfo_proc info;
    size_t size = sizeof(info);
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    
    int sysctlRet = sysctl(mib, 4, &info, &size, NULL, 0);
    
    if (sysctlRet != 0) {
        NSLog(@"Error occurred when calling sysctl(). The debugger check may not be reliable");
    }
    
    return (info.kp_proc.p_flag & P_TRACED) != 0;
}

+ (void)denyDebugger {
    // bind ptrace()
    void *pointerToPtrace = (void *)-2;
    void *ptracePtr = dlsym(pointerToPtrace, "ptrace");
    
    // Function pointer type for ptrace
    typedef int (*PtraceType)(int, pid_t, int, int);
    PtraceType ptrace = (PtraceType)ptracePtr;
    
    // PT_DENY_ATTACH == 31
    int ptraceRet = ptrace(31, 0, 0, 0);
    
    if (ptraceRet != 0) {
        NSLog(@"Error occurred when calling ptrace(). Denying debugger may not be reliable");
    }
}

#if defined(__arm64__)
+ (BOOL)hasBreakpointAtAddress:(const void *)functionAddr functionSize:(vm_size_t)functionSize {
    vm_address_t vmStart = (vm_address_t)functionAddr;
    vm_size_t vmSize = 0;
    vm_region_basic_info_data_64_t vmInfo;
    mach_msg_type_number_t infoCount = VM_REGION_BASIC_INFO_COUNT_64;
    mach_port_t objectName = 0;
    
    kern_return_t kr = vm_region_64(mach_task_self(),
                                   &vmStart,
                                   &vmSize,
                                   VM_REGION_BASIC_INFO_64,
                                   (vm_region_info_t)&vmInfo,
                                   &infoCount,
                                   &objectName);
    
    if (kr != KERN_SUCCESS) {
        return NO;
    }
    
    uint8_t *bytes = (uint8_t *)functionAddr;
    if (functionSize == 0) {
        functionSize = vmSize - ((vm_address_t)functionAddr - vmStart);
    }
    
    for (vm_size_t i = 0; i < functionSize; i++) {
        if (bytes[i] == 0x1) {
            return YES;
        }
    }
    
    return NO;
}
#endif

@end

#import "SGSecuritySuite.h"
#import "SGJailbreakChecker.h"
#import "SGDebuggerChecker.h"
#import "SGReverseEngineeringToolsChecker.h"
#import "SGRuntimeHookChecker.h"
#import "SGIntegrityChecker.h"
#import "SGEmulatorChecker.h"
#import "SGNetworkChecker.h"
#import "SGModesChecker.h"
#import "SGMSHookFunctionChecker.h"

@implementation SGSecuritySuite

#pragma mark - Jailbreak Detection

+ (BOOL)amIJailbroken {
    return [SGJailbreakChecker amIJailbroken];
}

+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailMessage {
    return [SGJailbreakChecker amIJailbrokenWithFailMessage];
}

+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailedChecks {
    return [SGJailbreakChecker amIJailbrokenWithFailedChecks];
}

#pragma mark - Debugger Detection

+ (BOOL)amIDebugged {
    return [SGDebuggerChecker amIDebugged];
}

+ (void)denyDebugger {
    [SGDebuggerChecker denyDebugger];
}

#pragma mark - Reverse Engineering Detection

+ (BOOL)amIReverseEngineered {
    return [SGReverseEngineeringToolsChecker amIReverseEngineered];
}

+ (NSDictionary<NSString *, id> *)amIReverseEngineeredWithFailedChecks {
    return [SGReverseEngineeringToolsChecker amIReverseEngineeredWithFailedChecks];
}

#pragma mark - Runtime Manipulation Detection

+ (BOOL)amIRuntimeHookWithDyldAllowList:(NSArray<NSString *> *)dyldAllowList
                         detectionClass:(Class)detectionClass
                             selector:(SEL)selector
                        isClassMethod:(BOOL)isClassMethod {
    return [SGRuntimeHookChecker amIRuntimeHookWithDyldAllowList:dyldAllowList
                                                 detectionClass:detectionClass
                                                     selector:selector
                                                isClassMethod:isClassMethod];
}

#pragma mark - Integrity Checking

+ (NSDictionary<NSString *, id> *)amITamperedWithChecks:(NSArray *)checks {
    SGIntegrityCheckResult *result = [SGIntegrityChecker amITamperedWithChecks:checks];
    return @{
        @"tampered": @(result.result),
        @"hitChecks": result.hitChecks
    };
}

#pragma mark - Emulator Detection

+ (BOOL)amIRunInEmulator {
    return [SGEmulatorChecker amIRunInEmulator];
}

#pragma mark - Proxy Detection

+ (BOOL)amIProxied {
    return [SGNetworkChecker amIProxied];
}

#pragma mark - Mode Detection

+ (BOOL)amIInLockdownMode {
    return [SGModesChecker amIInLockdownMode];
}

#if defined(__arm64__)
#pragma mark - MSHook Detection

+ (BOOL)amIMSHooked:(void *)functionAddr {
    return [SGMSHookFunctionChecker amIMSHooked:functionAddr];
}

+ (void *)denyMSHook:(void *)functionAddr {
    return [SGMSHookFunctionChecker denyMSHook:functionAddr];
}

+ (BOOL)hasBreakpointAt:(const void *)functionAddr functionSize:(vm_size_t)functionSize {
    return YES;
//    return [SGDebuggerChecker hasBreakpointAt:functionAddr functionSize:functionSize];
}
#endif

@end

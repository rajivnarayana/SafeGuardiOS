#import "SGEmulatorChecker.h"

@implementation SGEmulatorChecker

+ (BOOL)amIRunInEmulator {
    return [self checkCompile] || [self checkRuntime];
}

+ (BOOL)checkRuntime {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    return environment[@"SIMULATOR_DEVICE_NAME"] != nil;
}

+ (BOOL)checkCompile {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

@end

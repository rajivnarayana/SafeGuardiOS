#import "SGModesChecker.h"

@implementation SGModesChecker

+ (BOOL)amIInLockdownMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"LDMGlobalEnabled"];
}

@end

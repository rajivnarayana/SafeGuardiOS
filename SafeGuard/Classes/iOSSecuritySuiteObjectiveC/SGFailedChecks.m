#import "SGFailedChecks.h"

@implementation SGFailedCheck

+ (instancetype)failedCheckWithType:(SGFailedCheckType)type message:(NSString *)message {
    SGFailedCheck *check = [[SGFailedCheck alloc] init];
    check.checkType = type;
    check.failMessage = message;
    return check;
}

@end

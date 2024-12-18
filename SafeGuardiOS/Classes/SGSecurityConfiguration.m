#import "SGSecurityConfiguration.h"

@implementation SGSecurityConfiguration

+ (instancetype)defaultConfiguration {
    return [[self alloc] initWithDefaultConfiguration];
}

- (instancetype)initWithDefaultConfiguration {
    self = [super init];
    if (self) {
        _developerOptionsLevel = SGSecurityLevelWarning;
        _mockLocationLevel = SGSecurityLevelWarning;
        _timeManipulationLevel = SGSecurityLevelWarning;
        _usbDebuggingLevel = SGSecurityLevelWarning;
        _rootDetectionLevel = SGSecurityLevelWarning;
        _screenSharingLevel = SGSecurityLevelWarning;
        _signatureVerificationLevel = SGSecurityLevelWarning;
        _networkSecurityLevel = SGSecurityLevelWarning;
    }
    return self;
}

@end

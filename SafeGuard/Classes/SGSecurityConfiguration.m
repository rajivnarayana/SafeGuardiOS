#import "SGSecurityConfiguration.h"

@implementation SGSecurityConfiguration

+ (instancetype)defaultConfiguration {
    return [[self alloc] initWithDefaultConfiguration];
}
/*
 emulatorLevel;
@property (nonatomic, assign) SGSecurityLevel proxyLevel;
@property (nonatomic, assign) SGSecurityLevel reverseEngineerLevel;
@property (nonatomic, assign) SGSecurityLevel audioCallLevel;
@property (nonatomic, assign) SGSecurityLevel malwareLevel;
@property (nonatomic, assign) SGSecurityLevel rootClockingLevel;
@property (nonatomic, assign) SGSecurityLevel screenRecordingLevel;
@property (nonatomic, assign) SGSecurityLevel screenShotLevel;
@property (nonatomic, assign) SGSecurityLevel spoofingLevel;
@property (nonatomic, assign) SGSecurityLevel tapJackLevel;
@property (nonatomic, assign) SGSecurityLevel vpnCheckLevel;
@property (nonatomic, assign) SGSecurityLevel checkSumLevel;
@property (nonatomic, assign) SGSecurityLevel keyLoggersLevel;
 */
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
        _signatureErrorDebug = NO;
        _networkSecurityLevel = SGSecurityLevelWarning;
        _emulatorLevel = SGSecurityLevelWarning;
        _proxyLevel = SGSecurityLevelWarning;
        _reverseEngineerLevel = SGSecurityLevelWarning;
        _audioCallLevel = SGSecurityLevelWarning;
        _malwareLevel = SGSecurityLevelWarning;
        _rootClockingLevel = SGSecurityLevelWarning;
        _screenRecordingLevel = SGSecurityLevelWarning;
        _screenShotLevel = SGSecurityLevelWarning;
        _spoofingLevel = SGSecurityLevelWarning;
        _tapJackLevel = SGSecurityLevelWarning;
        _vpnCheckLevel = SGSecurityLevelWarning;
        _checkSumLevel = SGSecurityLevelWarning;
        _keyLoggersLevel = SGSecurityLevelWarning;
        _fidaaDetatctionLevel =  SGSecurityLevelWarning;
    }
    return self;
}

@end

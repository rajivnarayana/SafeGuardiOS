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
        _developerOptionsLevel = SGSecurityLevelError;
        _mockLocationLevel = SGSecurityLevelError;
        _timeManipulationLevel = SGSecurityLevelError;
        _usbDebuggingLevel = SGSecurityLevelError;
        _rootDetectionLevel = SGSecurityLevelError;
        _screenSharingLevel = SGSecurityLevelError;
        _signatureVerificationLevel = SGSecurityLevelError;
        _signatureErrorDebug = NO;
        _networkSecurityLevel = SGSecurityLevelError;
        _emulatorLevel = SGSecurityLevelError;
        _proxyLevel = SGSecurityLevelError;
        _reverseEngineerLevel = SGSecurityLevelError;
        _audioCallLevel = SGSecurityLevelError;
        _malwareLevel = SGSecurityLevelError;
        _rootClockingLevel = SGSecurityLevelError;
        _screenRecordingLevel = SGSecurityLevelError;
        _screenShotLevel = SGSecurityLevelError;
        _spoofingLevel = SGSecurityLevelError;
        _tapJackLevel = SGSecurityLevelError;
        _vpnCheckLevel = SGSecurityLevelError;
        _checkSumLevel = SGSecurityLevelError;
        _keyLoggersLevel = SGSecurityLevelError;
        _fidaaDetatctionLevel =  SGSecurityLevelError;
        _osVersionLevel = SGSecurityLevelError;
    }
    return self;
}

@end

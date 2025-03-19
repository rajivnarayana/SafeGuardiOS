#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SGSecurityLevel) {
    SGSecurityLevelDisable = 0,
    SGSecurityLevelWarning,
    SGSecurityLevelError
};

@interface SGSecurityConfiguration : NSObject

@property (nonatomic, assign) SGSecurityLevel developerOptionsLevel;
@property (nonatomic, assign) SGSecurityLevel mockLocationLevel;
@property (nonatomic, assign) SGSecurityLevel timeManipulationLevel;
@property (nonatomic, assign) SGSecurityLevel usbDebuggingLevel;
@property (nonatomic, assign) SGSecurityLevel rootDetectionLevel;
@property (nonatomic, assign) SGSecurityLevel screenSharingLevel;
@property (nonatomic, assign) SGSecurityLevel signatureVerificationLevel;
@property (nonatomic, assign) BOOL signatureErrorDebug;
@property (nonatomic, assign) SGSecurityLevel networkSecurityLevel;
@property (nonatomic, assign) SGSecurityLevel emulatorLevel;
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

@property (nonatomic, assign) NSString *expectedBundleIdentifier;
@property (nonatomic, assign) NSString *expectedSignature;

+ (instancetype)defaultConfiguration;
- (instancetype)initWithDefaultConfiguration;

@end

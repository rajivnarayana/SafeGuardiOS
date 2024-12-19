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
@property (nonatomic, assign) SGSecurityLevel networkSecurityLevel;
@property (nonatomic, assign) NSString *expectedBundleIdentifier;
@property (nonatomic, assign) NSString *expectedSignature;

+ (instancetype)defaultConfiguration;
- (instancetype)initWithDefaultConfiguration;

@end

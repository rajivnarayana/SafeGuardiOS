#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGSecurityMessages : NSObject

+ (NSString *)tapJackingAlert;
+ (NSString *)rootedCritical;
+ (NSString *)rootedWarning;
+ (NSString *)vpnWarning;
+ (NSString *)proxyWarning;
+ (NSString *)unsecuredNetworkWarning;
+ (NSString *)autoTimeWarning;
+ (NSString *)developerOptionsWarning;
+ (NSString *)mockLocationWarning;
+ (NSString *)usbDebuggingWarning;
+ (NSString *)appSpoofingWarning;
+ (NSString *)accessibilityWarning;
+ (NSString *)accessibilityNotWarning;
+ (NSString *)screenSharingWarning;
+ (NSString *)screenMirroringWarning;
+ (NSString *)screenRecordingWarning;
+ (NSString *)appSignatureWarning;
+ (NSString *)appSignatureCritical;
+ (NSString *)inCallWarning;
+ (NSString *)inCallCritical;
+ (NSString *)ongoingCallWarning;
+ (NSString *)ongoingCallCritical;

// Additional Security Messages
+ (NSString *)malwareWarning;
+ (NSString *)rootClockingWarning;
+ (NSString *)screenShotWarning;
+ (NSString *)spoofingWarning;
+ (NSString *)tapJackWarning;
+ (NSString *)checksumWarning;
+ (NSString *)keyLoggersWarning;

@end

NS_ASSUME_NONNULL_END

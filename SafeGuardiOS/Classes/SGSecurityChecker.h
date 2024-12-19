#import <Foundation/Foundation.h>
#import "SGSecurityConfiguration.h"

typedef NS_ENUM(NSInteger, SGSecurityCheckResult) {
    SGSecurityCheckResultSuccess,
    SGSecurityCheckResultWarning,
    SGSecurityCheckResultError
};

typedef void(^SGSecurityAlertHandler)(NSString *title, NSString *message, SGSecurityLevel level, void(^completion)(BOOL shouldQuit));

@interface SGSecurityChecker : NSObject

@property (nonatomic, strong, readonly) SGSecurityConfiguration *configuration;
@property (nonatomic, copy) SGSecurityAlertHandler alertHandler;

+ (instancetype)sharedInstance;
- (instancetype)initWithConfiguration:(SGSecurityConfiguration *)configuration;

// Show security alert
- (void)showSecurityAlert:(NSString *)title message:(NSString *)message level:(SGSecurityLevel)level;

// Run all security checks
- (void)performAllSecurityChecks;

// Individual checks - returns YES if check passed
- (SGSecurityCheckResult)checkDeveloperOptions;
- (SGSecurityCheckResult)checkMockLocation;
- (SGSecurityCheckResult)checkTimeManipulation;
- (SGSecurityCheckResult)checkUSBDebugging;
- (SGSecurityCheckResult)checkRoot;
- (SGSecurityCheckResult)checkScreenSharing;
- (SGSecurityCheckResult)checkSignature;
- (SGSecurityCheckResult)checkNetworkSecurity;

// Network monitoring
- (void)startNetworkMonitoring;
- (void)stopNetworkMonitoring;
- (void)cleanup;

-(void)LocationALert;

@end

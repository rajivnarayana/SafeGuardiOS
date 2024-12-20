#import <Foundation/Foundation.h>
#import "SGSecurityConfiguration.h"
#import "CoreLocation/CoreLocation.h"

typedef NS_ENUM(NSInteger, SGSecurityCheckResult) {
    SGSecurityCheckResultSuccess,
    SGSecurityCheckResultWarning,
    SGSecurityCheckResultError
};

typedef void(^SGSecurityAlertHandler)(NSString *title, NSString *message, SGSecurityLevel level, void(^completion)(BOOL shouldQuit));

@interface SGSecurityChecker : NSObject<CLLocationManagerDelegate>

@property (nonatomic, strong) SGSecurityConfiguration *configuration;
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
- (void)checkTimeManipulationWithCompletion:(void(^)(BOOL isSynchronized))completion;
- (SGSecurityCheckResult)checkUSBDebugging;
- (SGSecurityCheckResult)checkRoot;
- (SGSecurityCheckResult)checkScreenSharing;
- (SGSecurityCheckResult)checkSignature;
- (SGSecurityCheckResult)checkNetworkSecurity;
- (SGSecurityCheckResult)checkSpoofing;

// Network monitoring
- (void)startNetworkMonitoring;
- (void)stopNetworkMonitoring;
- (void)cleanup;



@end

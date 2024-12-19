#import "SGSecurityChecker.h"
#import "SGDeveloperOptionsCheck.h"
#import <Network/Network.h>
#import "SGRootDetection.h"
#import "SGMockLocation.h"
#import "SGMalwareDetected.h"
#import "SGDeveloperEnabled.h"
#import "SGAppSignature.h"
#import "SGAudioCallDetection.h"
#import "SGChecksumValidation.h"
#import "SGKeyLoggers.h"
#import "SGReAuthticateUser.h"
#import "SGRootClocking.h"
#import "SGScreenMirroring.h"
#import "SGScreenRecording.h"
#import "SGScreenShotPrevention.h"
#import "SGSpoofingDetected.h"
#import "SGTapJacked.h"
#import "SGTimeManipulation.h"
#import "SGVPNConnection.h"
#import "SGWifiSecure.h"







@interface SGSecurityChecker ()

@property (nonatomic, strong) NSMutableArray *alertQueue;
@property (nonatomic, assign) BOOL isShowingAlert;
@property (nonatomic, strong) dispatch_queue_t securityQueue;
@property (nonatomic, strong) nw_path_monitor_t networkMonitor;
@property (nonatomic, strong) SGSecurityConfiguration *configuration;

@end

@implementation SGSecurityChecker

+ (instancetype)sharedInstance {
    static SGSecurityChecker *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SGSecurityChecker alloc] initWithConfiguration:[SGSecurityConfiguration defaultConfiguration]];
    });
    return sharedInstance;
}

- (instancetype)initWithConfiguration:(SGSecurityConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _alertQueue = [NSMutableArray new];
        _isShowingAlert = NO;
        _securityQueue = dispatch_queue_create("com.safeguard.securitycheck", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Alert Management

- (void)showSecurityAlert:(NSString *)title message:(NSString *)message level:(SGSecurityLevel)level {
    NSDictionary *alert = @{
        @"title": title,
        @"message": message,
        @"level": @(level)
    };
    
    [self.alertQueue addObject:alert];
    [self showNextAlertIfNeeded];
}

- (void)showNextAlertIfNeeded {
    if (self.isShowingAlert || self.alertQueue.count == 0) {
        return;
    }
    
    self.isShowingAlert = YES;
    NSDictionary *alert = self.alertQueue.firstObject;
    [self.alertQueue removeObjectAtIndex:0];
    
    if (self.alertHandler) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            self.alertHandler(alert[@"title"],
                            alert[@"message"],
                            [alert[@"level"] integerValue],
                            ^(BOOL shouldQuit) {
                                if (shouldQuit) {
                                    exit(0);
                                } else {
                                    weakSelf.isShowingAlert = NO;
                                    [weakSelf showNextAlertIfNeeded];
                                }
                            });
        });
    }
}

#pragma mark - Security Checks

- (void)performAllSecurityChecks {
    dispatch_async(self.securityQueue, ^{
        SGSecurityCheckResult result;
        
        result = [self checkDeveloperOptions];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Developer Options" 
                          message:@"Developer options are enabled" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkRoot];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Root Access" 
                          message:@"Device is rooted" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkMockLocation];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Mock Location" 
                          message:@"Mock location is enabled" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkTimeManipulation];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Time Manipulation" 
                          message:@"Time manipulation is detected" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkUSBDebugging];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"USB Debugging" 
                          message:@"USB debugging is enabled" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkScreenSharing];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Screen Sharing" 
                          message:@"Screen sharing is enabled" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkSignature];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Signature Verification" 
                          message:@"Signature verification failed" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkNetworkSecurity];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Network Security" 
                          message:@"Network security check failed" 
                           level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
    });
}

- (SGSecurityCheckResult)checkDeveloperOptions {
    if (self.configuration.developerOptionsLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    #if DEBUG
        return (self.configuration.developerOptionsLevel == SGSecurityLevelError) ? 
               SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    #else
        return SGSecurityCheckResultSuccess;
    #endif
}

- (SGSecurityCheckResult)checkRoot {
    if (self.configuration.rootDetectionLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    SGRootDetection *rootDetection = [[SGRootDetection alloc] init];
       BOOL rootDetected = [rootDetection isRootDetected];
    
    // Check for jailbreak indicators
    // Implementation will be added
    return rootDetected;
}

- (SGSecurityCheckResult)checkMockLocation {
    if (self.configuration.mockLocationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGMockLocation *mL = [[SGMockLocation alloc] init];
       BOOL isMockLocation = [mL isMockLocation];
    // Check if location services are enabled and authorized
    // Implementation will be added
    return isMockLocation;
}

- (SGSecurityCheckResult)checkTimeManipulation {
    if (self.configuration.timeManipulationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGTimeManipulation *mL = [[SGTimeManipulation alloc] init];
       BOOL isTimeManipulated = [mL isTimeManipulation];
    
    // Compare system time with network time
    // Implementation will be added
    return isTimeManipulated;
}

- (SGSecurityCheckResult)checkUSBDebugging {
    if (self.configuration.usbDebuggingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    // Check if device is connected to Xcode
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkScreenSharing {
    if (self.configuration.screenSharingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenMirroring *mL = [[SGScreenMirroring alloc] init];
       BOOL isScreenShare = [mL isScreenMirrored];
    // Check for screen recording or mirroring
    // Implementation will be added
    return isScreenShare;
}

- (SGSecurityCheckResult)checkSignature {
    if (self.configuration.signatureVerificationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGAppSignature *mL = [[SGAppSignature alloc] init];
       BOOL appSign = [mL isAppSignatureValid];
    // Verify app signature and integrity
    // Implementation will be added
    return appSign;
}

- (SGSecurityCheckResult)checkNetworkSecurity {
    if (self.configuration.networkSecurityLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGWifiSecure *mL = [[SGWifiSecure alloc] init];
    BOOL networkConnection = [mL isWifiSecure];
    // Check for VPN, proxy, and insecure networks
    // Implementation will be added
    return networkConnection;
}

#pragma mark - Network Monitoring

- (void)handleNetworkPathUpdate:(nw_path_t)path {
    if (self.configuration.networkSecurityLevel == SGSecurityLevelDisable) {
        return;
    }
    
    BOOL isVPN = nw_path_uses_interface_type(path, nw_interface_type_other);
    if (isVPN) {
        [self showSecurityAlert:@"Network Security"
                      message:@"VPN connection detected"
                       level:self.configuration.networkSecurityLevel];
    }
}

- (void)cleanup {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationUserDidTakeScreenshotNotification
                                                  object:nil];
    
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIScreenCapturedDidChangeNotification
                                                      object:nil];
    } else {
        // Fallback on earlier versions
    }
    
    [self stopNetworkMonitoring];
    [self.alertQueue removeAllObjects];
}

- (void)dealloc {
    [self cleanup];
}

@end

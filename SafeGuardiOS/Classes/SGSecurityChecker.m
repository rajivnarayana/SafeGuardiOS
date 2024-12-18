#import "SGSecurityChecker.h"
#import "SGDeveloperOptionsCheck.h"
#import <Network/Network.h>

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
    
    // Check for jailbreak indicators
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkMockLocation {
    if (self.configuration.mockLocationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    // Check if location services are enabled and authorized
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkTimeManipulation {
    if (self.configuration.timeManipulationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    // Compare system time with network time
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
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
    
    // Check for screen recording or mirroring
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkSignature {
    if (self.configuration.signatureVerificationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    // Verify app signature and integrity
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkNetworkSecurity {
    if (self.configuration.networkSecurityLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    // Check for VPN, proxy, and insecure networks
    // Implementation will be added
    return SGSecurityCheckResultSuccess;
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
    [self stopNetworkMonitoring];
    [self.alertQueue removeAllObjects];
}

- (void)dealloc {
    [self cleanup];
}

@end

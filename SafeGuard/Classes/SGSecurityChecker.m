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
#import "SGTimeTamperingDetector.h"
#import "SGVPNConnection.h"
#import "SGWifiSecure.h"
#import "SGChecksumValidation.h"
#import "iOSSecuritySuiteObjectiveC/SGIntegrityChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGJailbreakChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGDebuggerChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGEmulatorChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGReverseEngineeringToolsChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGNetworkChecker.h"





@interface SGSecurityChecker ()<SGAudioCallAlertProtocol>

@property (nonatomic, strong) NSMutableArray *alertQueue;
@property (nonatomic, assign) BOOL isShowingAlert;
@property (nonatomic, strong) dispatch_queue_t securityQueue;
@property (nonatomic, strong) nw_path_monitor_t networkMonitor;
@property (nonatomic, strong) SGWifiSecure *wifiMonitor;
@property (nonatomic, strong) SGMockLocation *locationManager;
@property (nonatomic, strong) SGTimeTamperingDetector *timeTamperingDetector;
@property (nonatomic, strong) SGAudioCallDetection *audioCallDetector;

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
        _wifiMonitor = [[SGWifiSecure alloc] init];
        _locationManager = [[SGMockLocation alloc] init];
        _timeTamperingDetector = [[SGTimeTamperingDetector alloc] init];
        _audioCallDetector = [[SGAudioCallDetection alloc] init];
        _audioCallDetector.delegate = self;
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
        
        [self checkTimeManipulationWithCompletion:^(BOOL isSynchronized) {
            if (!isSynchronized) {
                [self showSecurityAlert:@"Time Manipulation" 
                                message:@"Time manipulation is detected" 
                                  level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
            }
        }];
        
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
        
        result = [self checkEmulator];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Emulator Check"
                            message:@"App running in Virtual device / Simulator"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        
        result = [self checkProxy];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Proxy Check"
                            message:@"Network check, App Running in a Proxy Network "
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkReverseEngineer];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Reverse Engineer"
                            message:@"Reverse Engineer Check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkAudioCall];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Audio Call Detected"
                            message:@"Audio Call Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkMalware];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Malware Detected"
                            message:@"Malware Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkRootClocking];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Root Clocking Detected"
                            message:@"Root Clocking Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkScreenRecording];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Screen Recording Detected"
                            message:@"Screen Recording Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkScreenShotPrevention];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"ScreenShot Detected"
                            message:@"ScreenShot Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkSpoofing];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Spoofing Detected"
                            message:@"Spoofing Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkTapJack];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"TapJack Detected"
                            message:@"TapJack Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkVpnCheck];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"VpnCheck Detected"
                            message:@"VpnCheck Detected check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkCheckSumValue];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"Checksum not matched"
                            message:@"Checksum not check"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
        result = [self checkKeyLoggers];
        if (result != SGSecurityCheckResultSuccess) {
            [self showSecurityAlert:@"KeyLoggers Detected"
                            message:@"KeyLoggers Detected"
                              level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
        }
        
    });
}

- (SGSecurityCheckResult)checkKeyLoggers {
    if (self.configuration.keyLoggersLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGKeyLoggers *mL = [[SGKeyLoggers alloc] init];
    return  [mL isKeyLoggerDetected];
}

- (SGSecurityCheckResult)checkCheckSumValue {
    if (self.configuration.checkSumLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGChecksumValidation *mL = [[SGChecksumValidation alloc] init];
    mL.hashValue = @"org.cocoapods.demo.SafeGuardiOS-Example";
    return  [mL isChecksumValid];
}

- (SGSecurityCheckResult)checkSpoofing {
    if (self.configuration.spoofingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGFileIntegrityCheck *fileIntegrityCheck = [SGFileIntegrityCheck bundleIDCheck:self.configuration.expectedBundleIdentifier];
    SGIntegrityCheckResult *result = [SGIntegrityChecker amITamperedWithChecks:@[fileIntegrityCheck]];
    return  result.result == YES ? SGSecurityCheckResultSuccess : self.configuration.spoofingLevel == SGSecurityLevelError ? SGSecurityCheckResultError: SGSecurityCheckResultWarning;
}

- (SGSecurityCheckResult)checkTapJack {
    if (self.configuration.tapJackLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGTapJacked *mL = [[SGTapJacked alloc] init];
    return  [mL isTapJackedDevice];
}

- (SGSecurityCheckResult)checkVpnCheck {
    if (self.configuration.vpnCheckLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGVPNConnection *mL = [[SGVPNConnection alloc] init];
    return  [mL isVPNConnected];
}


- (SGSecurityCheckResult)checkScreenRecording {
    if (self.configuration.screenRecordingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenRecording *mL = [[SGScreenRecording alloc] init];
    return  [mL isScreenBeingCaptured];
}

- (SGSecurityCheckResult)checkScreenShotPrevention {
    if (self.configuration.screenShotLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenShotPrevention *mL = [[SGScreenShotPrevention alloc] init];
    [mL preventScreenShot];
    return  [mL isSSTaken];
}

- (SGSecurityCheckResult)checkDeveloperOptions {
    if (self.configuration.developerOptionsLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    SGDeveloperEnabled *mL = [[SGDeveloperEnabled alloc] init];
    return  [mL isDeveloperEnabled];
    
//#if DEBUG
//    return (self.configuration.developerOptionsLevel == SGSecurityLevelError) ? 
//    SGSecurityCheckResultError : SGSecurityCheckResultWarning;
//#else
//    return SGSecurityCheckResultSuccess;
//#endif
}
- (SGSecurityCheckResult)checkMalware {
    if (self.configuration.malwareLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGMalwareDetected *mL = [[SGMalwareDetected alloc] init];
    return  [mL malwareDetected];
}

- (SGSecurityCheckResult)checkRootClocking {
    if (self.configuration.rootClockingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGRootClocking *mL = [[SGRootClocking alloc] init];
    return  [mL isRootClocking];
}
- (SGSecurityCheckResult)checkAudioCall {
    if (self.configuration.audioCallLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGAudioCallDetection *mL = [[SGAudioCallDetection alloc] init];
    return  [mL isAudioCallDetected];
}

- (SGSecurityCheckResult)checkRoot {
    if (self.configuration.rootDetectionLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    BOOL rootDetected =   [SGJailbreakChecker amIJailbroken];
    return rootDetected;
}

- (SGSecurityCheckResult)checkMockLocation {
    if (self.configuration.mockLocationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGMockLocation *mL = [[SGMockLocation alloc] init];
    BOOL isMockLocation = [mL isMockLocation];
    return isMockLocation;
}

- (void)checkTimeManipulationWithCompletion:(void(^)(BOOL isSynchronized))completion {
    if (self.configuration.timeManipulationLevel == SGSecurityLevelDisable) {
        return;
    }
    [_timeTamperingDetector verifyTimeWithNTPCompletion:completion];
}

- (SGSecurityCheckResult)checkUSBDebugging {
    if (self.configuration.usbDebuggingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    return [SGDebuggerChecker amIDebugged];
}

- (SGSecurityCheckResult)checkEmulator {
    if (self.configuration.emulatorLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    return [SGEmulatorChecker amIRunInEmulator];
}

- (SGSecurityCheckResult)checkReverseEngineer {
    if (self.configuration.reverseEngineerLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    return [SGReverseEngineeringToolsChecker amIReverseEngineered];
}

- (SGSecurityCheckResult)checkProxy {
    if (self.configuration.proxyLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    return [SGNetworkChecker amIProxied];
}


- (SGSecurityCheckResult)checkScreenSharing {
    if (self.configuration.screenSharingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenMirroring *mL = [[SGScreenMirroring alloc] init];
    BOOL isScreenShare = [mL isScreenBeingCaptured];
    // Check for screen recording or mirroring
    // Implementation will be added
    return isScreenShare;
}

- (SGSecurityCheckResult)checkSignature {
    if (self.configuration.signatureVerificationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGFileIntegrityCheck *fileIntegrityCheck = [SGFileIntegrityCheck mobileProvisionCheck:self.configuration.expectedSignature];
    SGIntegrityCheckResult *result = [SGIntegrityChecker amITamperedWithChecks:@[fileIntegrityCheck]];
    return  result.result == YES ? SGSecurityCheckResultSuccess : self.configuration.spoofingLevel == SGSecurityLevelError ? SGSecurityCheckResultError: SGSecurityCheckResultWarning;
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
    [self stopLocationMonitoring];
    [self.alertQueue removeAllObjects];
}

- (void)startNetworkMonitoring {
    // Do nothing. Automatically
}

- (void)stopNetworkMonitoring {
    [_wifiMonitor stopMonitoring];
}

- (void)stopLocationMonitoring {
    [_locationManager stopMontiring];
}

- (void)dealloc {
    [self cleanup];
}

- (void)callStarted { 
    SGSecurityCheckResult result = [self checkAudioCall];
    if (result != SGSecurityCheckResultSuccess) {
        [self showSecurityAlert:@"Audio Call Detected"
                        message:@"Audio Call Detected check"
                          level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
    }
}

@end

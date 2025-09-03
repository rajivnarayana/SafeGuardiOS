#import "SGSecurityChecker.h"
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
#import "SGFidaDetection.h"
//#import "SGWifiSecure.h"
#import "iOSSecuritySuiteObjectiveC/SGIntegrityChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGJailbreakChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGDebuggerChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGEmulatorChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGReverseEngineeringToolsChecker.h"
#import "iOSSecuritySuiteObjectiveC/SGNetworkChecker.h"
#import "SGSecurityMessages.h"

@interface SGSecurityChecker ()<SGAudioCallAlertProtocol>

@property (nonatomic, strong) NSMutableArray *alertQueue;
@property (nonatomic, assign) BOOL isShowingAlert;
@property (nonatomic, strong) dispatch_queue_t securityQueue;
@property (nonatomic, strong) nw_path_monitor_t networkMonitor;
//@property (nonatomic, strong) SGWifiSecure *wifiMonitor;
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
//        _wifiMonitor = [[SGWifiSecure alloc] init];
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

- (void)clearQueue {
    [self.alertQueue removeAllObjects];
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
        [self checkFridaDetection];
        [self checkDeveloperOptions];
        [self checkRoot];
        [self checkMockLocation];
        [self checkTimeManipulationWithCompletion:^(BOOL isSynchronized) {
            if (!isSynchronized) {
                [self showSecurityAlert:@"Time Manipulation" 
                                message:[SGSecurityMessages autoTimeWarning]
                                  level:self.configuration.timeManipulationLevel];
            }
        }];
        [self checkUSBDebugging];
        [self checkScreenSharing];
        [self checkSignature];
        [self checkNetworkSecurity];
        [self checkEmulator];
        [self checkReverseEngineer];
        [self checkAudioCall];
        [self checkMalware];
        [self checkRootClocking];
        [self checkScreenRecording];
        [self checkScreenShotPrevention];
        [self checkSpoofing];
        [self checkTapJack];
//        [self checkCheckSumValue];
        [self checkKeyLoggers];
    });
}

- (SGSecurityCheckResult)checkKeyLoggers {
    if (self.configuration.keyLoggersLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGKeyLoggers *mL = [[SGKeyLoggers alloc] init];
    if ([mL isKeyLoggerDetected]) {
        [self showSecurityAlert:@"KeyLoggers Detected"
                        message:[SGSecurityMessages keyLoggersWarning]
                          level:self.configuration.keyLoggersLevel];
        return (self.configuration.keyLoggersLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkCheckSumValue {
    if (self.configuration.checkSumLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGChecksumValidation *mL = [[SGChecksumValidation alloc] init];
    mL.hashValue = @"org.cocoapods.demo.SafeGuardiOS-Example";
    if (![mL isChecksumValid]) {
        [self showSecurityAlert:@"Checksum not matched"
                        message:[SGSecurityMessages checksumWarning]
                          level:self.configuration.checkSumLevel];
        return (self.configuration.checkSumLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkSpoofing {
    if (self.configuration.spoofingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGFileIntegrityCheck *fileIntegrityCheck = [SGFileIntegrityCheck bundleIDCheck:self.configuration.expectedBundleIdentifier];
    SGIntegrityCheckResult *result = [SGIntegrityChecker amITamperedWithChecks:@[fileIntegrityCheck]];
    if (result.result == NO) {
        [self showSecurityAlert:@"Spoofing Detected"
                        message:[SGSecurityMessages spoofingWarning]
                          level:self.configuration.spoofingLevel];
        return (self.configuration.spoofingLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkTapJack {
    if (self.configuration.tapJackLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGTapJacked *mL = [[SGTapJacked alloc] init];
    if ([mL isTapJackedDevice]) {
        [self showSecurityAlert:@"TapJack Detected"
                        message:[SGSecurityMessages tapJackWarning]
                          level:self.configuration.tapJackLevel];
        return (self.configuration.tapJackLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkVpnCheck {
    if (self.configuration.vpnCheckLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGVPNConnection *mL = [[SGVPNConnection alloc] init];
    if ([mL isVPNConnected]) {
        [self showSecurityAlert:@"VpnCheck Detected"
                        message:[SGSecurityMessages vpnWarning]
                          level:self.configuration.vpnCheckLevel];
        return (self.configuration.vpnCheckLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkScreenRecording {
    if (self.configuration.screenRecordingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenRecording *mL = [[SGScreenRecording alloc] init];
    if ([mL isScreenBeingCaptured]) {
        [self showSecurityAlert:@"Screen Recording Detected"
                        message:[SGSecurityMessages screenRecordingWarning]
                          level:self.configuration.screenRecordingLevel];
        return (self.configuration.screenRecordingLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkScreenShotPrevention {
    if (self.configuration.screenShotLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenShotPrevention *mL = [[SGScreenShotPrevention alloc] init];
    [mL preventScreenShot];
    if ([mL isSSTaken]) {
        [self showSecurityAlert:@"ScreenShot Detected"
                        message:[SGSecurityMessages screenShotWarning]
                          level:self.configuration.screenShotLevel];
        return (self.configuration.screenShotLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkDeveloperOptions {
    if (self.configuration.developerOptionsLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    
    SGDeveloperEnabled *mL = [[SGDeveloperEnabled alloc] init];
    BOOL isDeveloperOptionsEnabled = [mL isDeveloperEnabled];
    
    if (isDeveloperOptionsEnabled) {
        [self showSecurityAlert:@"Developer Options" 
                        message:[SGSecurityMessages developerOptionsWarning]
                          level:self.configuration.developerOptionsLevel];
        return (self.configuration.developerOptionsLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkMalware {
    if (self.configuration.malwareLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGMalwareDetected *mL = [[SGMalwareDetected alloc] init];
    if ([mL malwareDetected]) {
        [self showSecurityAlert:@"Malware Detected"
                        message:[SGSecurityMessages malwareWarning]
                          level:self.configuration.malwareLevel];
        return (self.configuration.malwareLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkRootClocking {
    if (self.configuration.rootClockingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGRootClocking *mL = [[SGRootClocking alloc] init];
    if ([mL isRootClocking]) {
        [self showSecurityAlert:@"Root Clocking Detected"
                        message:[SGSecurityMessages rootClockingWarning]
                          level:self.configuration.rootClockingLevel];
        return (self.configuration.rootClockingLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkAudioCall {
    if (self.configuration.audioCallLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGAudioCallDetection *mL = [[SGAudioCallDetection alloc] init];
    if ([mL isAudioCallDetected]) {
        [self showSecurityAlert:@"Audio Call Detected"
                        message:(self.configuration.audioCallLevel == SGSecurityLevelError ? 
                                [SGSecurityMessages inCallCritical] : 
                                [SGSecurityMessages inCallWarning])
                          level:self.configuration.audioCallLevel];
        return (self.configuration.audioCallLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkRoot {
    if (self.configuration.rootDetectionLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    BOOL rootDetected = [SGReverseEngineeringToolsChecker amIReverseEngineered];

    //[SGJailbreakChecker amIJailbroken];
    if (rootDetected) {
        [self showSecurityAlert:@"Root Access" 
                        message:(self.configuration.rootDetectionLevel == SGSecurityLevelError ? 
                                [SGSecurityMessages rootedCritical] : 
                                [SGSecurityMessages rootedWarning])
                          level:self.configuration.rootDetectionLevel];
        return (self.configuration.rootDetectionLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}


- (SGSecurityCheckResult)checkFridaDetection {
    if (self.configuration.fidaaDetatctionLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    BOOL isFidaDetection = [SGFidaDetection detectFrida];
    if (isFidaDetection) {
        exit(0);
//        [self showSecurityAlert:@"Root Detection Frida"
//                        message:[SGSecurityMessages rootedCritical]
//                          level:self.configuration.fidaaDetatctionLevel];
//        return (self.configuration.fidaaDetatctionLevel == SGSecurityLevelError) ?
//            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkMockLocation {
    if (self.configuration.mockLocationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGMockLocation *mL = [[SGMockLocation alloc] init];
    BOOL isMockLocation = [mL isMockLocation];
    if (isMockLocation) {
        [self showSecurityAlert:@"Mock Location" 
                        message:[SGSecurityMessages mockLocationWarning]
                          level:self.configuration.mockLocationLevel];
        return (self.configuration.mockLocationLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
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
    if ([SGDebuggerChecker amIDebugged]) {
        [self showSecurityAlert:@"USB Debugging" 
                        message:[SGSecurityMessages usbDebuggingWarning]
                          level:self.configuration.usbDebuggingLevel];
        return (self.configuration.usbDebuggingLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkEmulator {
    if (self.configuration.emulatorLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    if ([SGEmulatorChecker amIRunInEmulator]) {
        [self showSecurityAlert:@"Emulator Check"
                        message:(self.configuration.emulatorLevel == SGSecurityLevelError ? 
                                [SGSecurityMessages rootedCritical] : 
                                [SGSecurityMessages rootedWarning])
                          level:self.configuration.emulatorLevel];
        return (self.configuration.emulatorLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkReverseEngineer {
    if (self.configuration.reverseEngineerLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    if ([SGReverseEngineeringToolsChecker amIReverseEngineered]) {
        [self showSecurityAlert:@"Reverse Engineer"
                        message:[SGSecurityMessages appSpoofingWarning]
                          level:self.configuration.reverseEngineerLevel];
        return (self.configuration.reverseEngineerLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkProxy {
    if (self.configuration.proxyLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
 
    if ([SGNetworkChecker amIProxied]) {
        [self showSecurityAlert:@"Proxy Check"
                        message:[SGSecurityMessages proxyWarning]
                          level:self.configuration.proxyLevel];
        return (self.configuration.proxyLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkScreenSharing {
    if (self.configuration.screenSharingLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGScreenMirroring *check = [[SGScreenMirroring alloc] init];
    if ([check isScreenBeingCaptured]) {
        [self showSecurityAlert:@"Screen Sharing"
                        message:[SGSecurityMessages screenSharingWarning]
                          level:self.configuration.screenSharingLevel];
        return (self.configuration.screenSharingLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkSignature {
    if (self.configuration.signatureVerificationLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGFileIntegrityCheck *fileIntegrityCheck = [SGFileIntegrityCheck mobileProvisionCheck:self.configuration.expectedSignature];
    SGIntegrityCheckResult *result = [SGIntegrityChecker amITamperedWithChecks:@[fileIntegrityCheck]];
    if (result.result == NO) {
        NSString *message = (self.configuration.signatureVerificationLevel == SGSecurityLevelError ? 
                                [SGSecurityMessages appSignatureCritical] : 
                                [SGSecurityMessages appSignatureWarning]);
        message = self.configuration.signatureErrorDebug ? [NSString stringWithFormat: @"Expected Signature: %@, Actual Signature: %@", self.configuration.expectedSignature, [SGIntegrityChecker actualSignatureHash]]: message;
        [self showSecurityAlert:@"Signature Verification"
                        message:message
                          level:self.configuration.signatureVerificationLevel];
        return (self.configuration.signatureVerificationLevel == SGSecurityLevelError) ? 
            SGSecurityCheckResultError : SGSecurityCheckResultWarning;
    }
    return SGSecurityCheckResultSuccess;
}

- (SGSecurityCheckResult)checkNetworkSecurity {
    if (self.configuration.networkSecurityLevel == SGSecurityLevelDisable) {
        return SGSecurityCheckResultSuccess;
    }
    SGSecurityCheckResult result = [self checkProxy];
    if ( result != SGSecurityCheckResultSuccess) {
        return result;
    }
    result = [self checkVpnCheck];
    if ( result != SGSecurityCheckResultSuccess) {
        return result;
    }
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
                        message:[SGSecurityMessages vpnWarning]
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
//    [_wifiMonitor stopMonitoring];
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
                        message:(result == SGSecurityCheckResultError ? [SGSecurityMessages inCallCritical] : [SGSecurityMessages inCallWarning])
                          level:(result == SGSecurityCheckResultError ? SGSecurityLevelError : SGSecurityLevelWarning)];
    }
}

@end

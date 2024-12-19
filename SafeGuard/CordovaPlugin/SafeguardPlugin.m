#import "SafeguardPlugin.h"
#import "SGSecurityConfiguration.h"
#import <UIKit/UIKit.h>

@implementation SafeguardPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    
    // Get preferences from config.xml
    SGSecurityConfiguration *config = [[SGSecurityConfiguration alloc] init];
    
    config.rootDetectionLevel = [self getSecurityLevelFromPreferences:@"ROOT_CHECK_STATE" defaultValue:SGSecurityLevelError];
    config.developerOptionsLevel = [self getSecurityLevelFromPreferences:@"DEVELOPER_OPTIONS_CHECK_STATE" defaultValue:SGSecurityLevelWarning];
    config.signatureVerificationLevel = [self getSecurityLevelFromPreferences:@"MALWARE_CHECK_STATE" defaultValue:SGSecurityLevelWarning];
    config.networkSecurityLevel = [self getSecurityLevelFromPreferences:@"NETWORK_SECURITY_CHECK_STATE" defaultValue:SGSecurityLevelWarning];
    config.screenSharingLevel = [self getSecurityLevelFromPreferences:@"SCREEN_SHARING_CHECK_STATE" defaultValue:SGSecurityLevelWarning];
    
    self.securityChecker = [[SGSecurityChecker alloc] initWithConfiguration:config];
    
    // Set up alert handler
    __weak typeof(self) weakSelf = self;
    self.securityChecker.alertHandler = ^(NSString *title, NSString *message, SGSecurityLevel level, void(^completion)(BOOL shouldQuit)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            NSString *buttonTitle = (level == SGSecurityLevelError) ? @"Quit" : @"Continue Anyway";
            UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                completion(level == SGSecurityLevelError);
            }];
            
            [alert addAction:action];
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootViewController presentViewController:alert animated:YES completion:nil];
        });
    };
}

- (SGSecurityLevel)getSecurityLevelFromPreferences:(NSString *)preferenceName defaultValue:(SGSecurityLevel)defaultValue {
    NSString *value = [self.commandDelegate.settings objectForKey:preferenceName];
    if ([value isEqualToString:@"ERROR"]) {
        return SGSecurityLevelError;
    } else if ([value isEqualToString:@"WARNING"]) {
        return SGSecurityLevelWarning;
    } else if ([value isEqualToString:@"DISABLE"]) {
        return SGSecurityLevelDisable;
    }
    return defaultValue;
}

- (void)handleSecurityCheckResult:(SGSecurityCheckResult)result 
                      checkName:(NSString *)checkName 
                       command:(CDVInvokedUrlCommand*)command {
    if (result == SGSecurityCheckResultSuccess) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                        messageAsString:[NSString stringWithFormat:@"%@: Passed", checkName]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        NSString *message = [NSString stringWithFormat:@"%@: Failed", checkName];
        BOOL isCritical = (result == SGSecurityCheckResultError);
        
        // Show alert on main thread
        [self.securityChecker showAlertWithTitle:checkName message:message level:(isCritical ? SGSecurityLevelError : SGSecurityLevelWarning)];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                                        messageAsString:message];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark - Plugin Methods

- (void)checkRoot:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        SGSecurityCheckResult result = [self.securityChecker checkRoot];
        [self handleSecurityCheckResult:result checkName:@"Root Access Check" command:command];
    }];
}

- (void)checkDeveloperOptions:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        SGSecurityCheckResult result = [self.securityChecker checkDeveloperOptions];
        [self handleSecurityCheckResult:result checkName:@"Developer Options Check" command:command];
    }];
}

- (void)checkMalware:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        SGSecurityCheckResult result = [self.securityChecker checkSignature];
        [self handleSecurityCheckResult:result checkName:@"Malware Check" command:command];
    }];
}

- (void)checkNetwork:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        SGSecurityCheckResult result = [self.securityChecker checkNetworkSecurity];
        [self handleSecurityCheckResult:result checkName:@"Network Security Check" command:command];
    }];
}

- (void)checkScreenMirroring:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        SGSecurityCheckResult result = [self.securityChecker checkScreenSharing];
        [self handleSecurityCheckResult:result checkName:@"Screen Mirroring Check" command:command];
    }];
}

- (void)checkAppSpoofing:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        // Implementation pending
        [self handleSecurityCheckResult:SGSecurityCheckResultSuccess checkName:@"App Spoofing Check" command:command];
    }];
}

- (void)checkKeyLogger:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        // Implementation pending
        [self handleSecurityCheckResult:SGSecurityCheckResultSuccess checkName:@"Keylogger Check" command:command];
    }];
}

- (void)checkAll:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [self.securityChecker performAllSecurityChecks];
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)onReset {
    [super onReset];
    [self.securityChecker cleanup];
}

@end

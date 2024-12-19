#import <Cordova/CDVPlugin.h>
#import "SGSecurityChecker.h"

@interface SafeguardPlugin : CDVPlugin

@property (nonatomic, strong) SGSecurityChecker *securityChecker;

- (void)checkRoot:(CDVInvokedUrlCommand*)command;
- (void)checkDeveloperOptions:(CDVInvokedUrlCommand*)command;
- (void)checkMalware:(CDVInvokedUrlCommand*)command;
- (void)checkNetwork:(CDVInvokedUrlCommand*)command;
- (void)checkScreenMirroring:(CDVInvokedUrlCommand*)command;
- (void)checkAppSpoofing:(CDVInvokedUrlCommand*)command;
- (void)checkKeyLogger:(CDVInvokedUrlCommand*)command;
- (void)checkAll:(CDVInvokedUrlCommand*)command;

@end

#import "SGNetworkChecker.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation SGNetworkChecker

+ (BOOL)amIProxied {
    CFDictionaryRef unmanagedSettings = CFNetworkCopySystemProxySettings();
    if (!unmanagedSettings) {
        return NO;
    }
    
    NSDictionary *settings = (__bridge_transfer NSDictionary *)unmanagedSettings;
    
    // VPN Check (always enabled as per requirement)
    NSDictionary *scoped = settings[@"__SCOPED__"];
    if (scoped) {
        NSArray *vpnInterfaces = @[@"tap", @"tun", @"ppp", @"ipsec", @"utun"];
        
        for (NSString *interface in scoped.allKeys) {
            for (NSString *vpnType in vpnInterfaces) {
                if ([interface containsString:vpnType]) {
                    NSLog(@"VPN interface detected: %@", interface);
                    return YES;
                }
            }
        }
    }
    
    // Proxy Check
    return ([settings.allKeys containsObject:@"HTTPProxy"] || 
            [settings.allKeys containsObject:@"HTTPSProxy"]);
}

@end

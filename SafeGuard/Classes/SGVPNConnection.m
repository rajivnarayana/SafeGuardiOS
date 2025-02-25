//
//  SGVPNConnection.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGVPNConnection.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation SGVPNConnection

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (BOOL)isVPNConnected {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    BOOL isVPNConnected = NO;

    if (getifaddrs(&interfaces) == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            NSString *interfaceName = [NSString stringWithUTF8String:temp_addr->ifa_name];

            if ([interfaceName containsString:@"utun"] ||   // Used for VPN connections
                [interfaceName containsString:@"ppp"] ||   // Used for PPTP VPN
                [interfaceName containsString:@"ipsec"]) { // Used for IPSec VPN
                isVPNConnected = YES;
                break;
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return isVPNConnected;
}


@end

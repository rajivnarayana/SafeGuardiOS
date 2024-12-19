//
//  SGVPNConnection.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGVPNConnection.h"

@implementation SGVPNConnection

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isVPNConnected {
    if (@available(iOS 9.0, *)) { // Ensure the code runs on supported versions
        NEVPNManager *vpnManager = [NEVPNManager sharedManager];
        NEVPNConnection *connection = vpnManager.connection;
        
        switch (connection.status) {
            case NEVPNStatusConnected:
                return YES; // VPN is connected
            default:
                return NO; // VPN is not connected
        }
    } else {
        NSLog(@"VPN status check is not supported on this iOS version.");
        return NO;
    }
}

@end

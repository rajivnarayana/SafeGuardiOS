//
//  SGWifiSecure.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGWifiSecure.h"

@interface SGWifiSecure ()
@property (nonatomic, strong) nw_path_monitor_t pathMonitor;

@end

@implementation SGWifiSecure
- (instancetype)init {
    self = [super init];
    if (self) {
        _isWIFiINSecure = NO;
        [self startMonitoringNetwork];
    }
    return self;
}


- (void)startMonitoringNetwork {
    if (@available(iOS 12.0, *)) {
        _pathMonitor = nw_path_monitor_create();
        nw_path_monitor_set_update_handler(_pathMonitor, ^(nw_path_t path) {
            // Check if the device is connected to Wi-Fi
            if (nw_path_is_expensive(path)) {
                NSLog(@"Using cellular data.");
            } else {
                NSLog(@"Connected to Wi-Fi.");
                [self checkWiFiSecurity];
            }
        });
        nw_path_monitor_start(_pathMonitor);
    } else {
        // Fallback on earlier versions
    }
}

// Check the current Wi-Fi SSID
- (void)checkWiFiSecurity {
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info) {
            NSString *SSID = info[@"SSID"];
//            NSString *BSSID = info[@"BSSID"];
            NSLog(@"Connected to Wi-Fi Network: %@", SSID);
            // Here you can check if SSID or BSSID matches your secured network list
            [self checkWiFiSecurityStatusForSSID:SSID];
        }
    }
}

// Example of a method to check if the Wi-Fi is secured or not
- (void)checkWiFiSecurityStatusForSSID:(NSString *)SSID {
    // You can compare SSID with a known list of secured networks, or check for specific conditions.
    // However, iOS does not provide direct access to the security type (open, WEP, WPA) of a network.
    
    _isWIFiINSecure = NO;
}

- (void)stopMonitoring {
    nw_path_monitor_cancel(_pathMonitor);
}

-(BOOL)isWifiSecure{
    return _isWIFiINSecure;
}

@end

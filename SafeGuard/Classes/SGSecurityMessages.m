#import "SGSecurityMessages.h"

@implementation SGSecurityMessages

+ (NSBundle *)resourceBundle {
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleURL = [mainBundle URLForResource:@"SafeGuard" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}

+ (NSString *)localizedStringForKey:(NSString *)key {
    NSBundle *bundle = [self resourceBundle];
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

+ (NSString *)tapJackingAlert {
    return [self localizedStringForKey:@"tap_jacking_alert"];
}

+ (NSString *)rootedCritical {
    return [self localizedStringForKey:@"rooted_critical"];
}

+ (NSString *)rootedWarning {
    return [self localizedStringForKey:@"rooted_warning"];
}

+ (NSString *)vpnWarning {
    return [self localizedStringForKey:@"vpn_warning"];
}

+ (NSString *)proxyWarning {
    return [self localizedStringForKey:@"proxy_warning"];
}

+ (NSString *)unsecuredNetworkWarning {
    return [self localizedStringForKey:@"unsecured_network_warning"];
}

+ (NSString *)autoTimeWarning {
    return [self localizedStringForKey:@"auto_time_warning"];
}

+ (NSString *)developerOptionsWarning {
    return [self localizedStringForKey:@"developer_options_warning"];
}

+ (NSString *)mockLocationWarning {
    return [self localizedStringForKey:@"mock_location_warning"];
}

+ (NSString *)usbDebuggingWarning {
    return [self localizedStringForKey:@"usb_debugging_warning"];
}

+ (NSString *)appSpoofingWarning {
    return [self localizedStringForKey:@"app_spoofing_warning"];
}

+ (NSString *)accessibilityWarning {
    return [self localizedStringForKey:@"accessibility_warning"];
}

+ (NSString *)accessibilityNotWarning {
    return [self localizedStringForKey:@"accessibility_not_warning"];
}

+ (NSString *)screenSharingWarning {
    return [self localizedStringForKey:@"screen_sharing_warning"];
}

+ (NSString *)screenMirroringWarning {
    return [self localizedStringForKey:@"screen_mirroring_warning"];
}

+ (NSString *)screenRecordingWarning {
    return [self localizedStringForKey:@"screen_recording_warning"];
}

+ (NSString *)appSignatureWarning {
    return [self localizedStringForKey:@"app_signature_warning"];
}

+ (NSString *)appSignatureCritical {
    return [self localizedStringForKey:@"app_signature_critical"];
}

+ (NSString *)inCallWarning {
    return [self localizedStringForKey:@"in_call_warning"];
}

+ (NSString *)inCallCritical {
    return [self localizedStringForKey:@"in_call_critical"];
}

+ (NSString *)ongoingCallWarning {
    return [self localizedStringForKey:@"ongoing_call_warning"];
}

+ (NSString *)ongoingCallCritical {
    return [self localizedStringForKey:@"ongoing_call_critical"];
}

+ (NSString *)malwareWarning {
    return [self localizedStringForKey:@"malware_warning"];
}

+ (NSString *)rootClockingWarning {
    return [self localizedStringForKey:@"root_clocking_warning"];
}

+ (NSString *)screenShotWarning {
    return [self localizedStringForKey:@"screen_shot_warning"];
}

+ (NSString *)spoofingWarning {
    return [self localizedStringForKey:@"spoofing_warning"];
}

+ (NSString *)tapJackWarning {
    return [self localizedStringForKey:@"tap_jack_warning"];
}

+ (NSString *)checksumWarning {
    return [self localizedStringForKey:@"checksum_warning"];
}

+ (NSString *)keyLoggersWarning {
    return [self localizedStringForKey:@"key_loggers_warning"];
}

@end

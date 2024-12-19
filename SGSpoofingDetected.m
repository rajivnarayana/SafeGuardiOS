//
//  SGSpoofingDetected.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGSpoofingDetected.h"

@implementation SGSpoofingDetected

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isSpoofingDetected {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleIdentifier isEqualToString:@"com.KFintech.CyberSheildiOS"]) {
        NSLog(@"Potential application spoofing detected.");
        return YES;
    }
    return NO;
}
@end

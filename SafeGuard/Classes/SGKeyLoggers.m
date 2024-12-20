//
//  SGKeyLoggers.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGKeyLoggers.h"

@implementation SGKeyLoggers

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isKeyLoggerDetected {
    // Check for enabled keyboard extensions
    NSArray *keyboards = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleKeyboards"];
    // Check if any third-party keyboard has full access
    for (NSString *keyboard in keyboards) {
        if (![keyboard hasPrefix:@"com.apple"]) {
            if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"keyboard-settings://"]]) {
                return YES;
            }
        }
    }
    return NO;
}



@end

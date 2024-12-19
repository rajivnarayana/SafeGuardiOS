//
//  SGRootDetection.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGRootDetection.h"

@implementation SGRootDetection

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(BOOL)isRootDetected{
    // 1. Check for existence of jailbreak files
    NSArray *jailbreakPaths = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/private/var/lib/apt/",
        @"/usr/bin/ssh"
    ];
    for (NSString *path in jailbreakPaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSLog(@"Jailbreak file found: %@", path);
            return YES;
        }
    }
    return NO;
}
@end

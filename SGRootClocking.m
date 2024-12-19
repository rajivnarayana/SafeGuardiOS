//
//  SGRootClocking.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGRootClocking.h"
#import <sys/stat.h>

@implementation SGRootClocking
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(BOOL)isRootClocking{
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
    
    // 2. Check for the ability to write outside sandbox
    NSError *error = nil;
    NSString *testPath = @"/private/jailbreak.txt";
    NSString *testString = @"Test Jailbreak";
    [testString writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        // Can write to outside sandbox, device is jailbroken
        [[NSFileManager defaultManager] removeItemAtPath:testPath error:nil];
        return YES;
    }
    
    // 3. Check for suspicious symbolic links
    struct stat s;
    if (lstat("/Applications", &s) == 0) {
        if (s.st_mode & S_IFLNK) {
            NSLog(@"Suspicious symbolic link found: /Applications");
            return YES;
        }
    }
    
    // 4. Check for suspicious system calls
    FILE *f = fopen("/bin/bash", "r");
    if (f != NULL) {
        fclose(f);
        return YES;
    }
    
    return NO;
}
@end

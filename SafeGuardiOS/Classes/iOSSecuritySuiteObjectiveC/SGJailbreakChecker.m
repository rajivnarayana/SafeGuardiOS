#import "SGJailbreakChecker.h"
#import "SGFailedChecks.h"
#import "SGEmulatorChecker.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/stat.h>
#import <objc/runtime.h>

@implementation SGJailbreakStatus
@end

@implementation SGJailbreakChecker

typedef struct {
    BOOL passed;
    NSString *failMessage;
} CheckResult;

+ (BOOL)amIJailbroken {
    return ![self performChecks].passed;
}

+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailMessage {
    SGJailbreakStatus *status = [self performChecks];
    return @{
        @"jailbroken": @(!status.passed),
        @"failMessage": status.failMessage
    };
}

+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailedChecks {
    SGJailbreakStatus *status = [self performChecks];
    return @{
        @"jailbroken": @(!status.passed),
        @"failedChecks": status.failedChecks
    };
}

+ (CheckResult)canOpenUrlFromList:(NSArray<NSString *> *)urlSchemes {
    for (NSString *urlScheme in urlSchemes) {
        NSURL *url = [NSURL URLWithString:urlScheme];
        if (url && [[UIApplication sharedApplication] canOpenURL:url]) {
            return (CheckResult){NO, [NSString stringWithFormat:@"%@ URL scheme detected", urlScheme]};
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkURLSchemes {
    NSArray<NSString *> *urlSchemes = @[
        @"cydia://",
        @"undecimus://",
        @"sileo://",
        @"zbra://",
        @"filza://",
        @"activator://"
    ];
    return [self canOpenUrlFromList:urlSchemes];
}

+ (CheckResult)checkExistenceOfSuspiciousFiles {
    NSArray<NSString *> *paths = @[
        @"/var/mobile/Library/Preferences/ABPattern",  // A-Bypass
        @"/usr/lib/ABDYLD.dylib",  // A-Bypass
        @"/usr/lib/ABSubLoader.dylib",  // A-Bypass
        @"/private/var/lib/apt",
        @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log",
        @"/Applications/Cydia.app",
        @"/Applications/FakeCarrier.app",
        @"/Applications/Sileo.app",
        @"/Applications/Zebra.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib"
    ];
    
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious file exists: %@", path]};
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkSuspiciousFilesCanBeOpened {
    NSArray<NSString *> *paths = @[
        @"/.installed_unc0ver",
        @"/.bootstrapped_electra",
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/etc/apt",
        @"/var/log/apt"
    ];
    
    for (NSString *path in paths) {
        FILE *file = fopen([path UTF8String], "r");
        if (file) {
            fclose(file);
            return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious file can be opened: %@", path]};
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkRestrictedDirectoriesWriteable {
    NSArray<NSString *> *paths = @[
        @"/",
        @"/private/",
        @"/private/var/",
        @"/private/var/mobile/",
        @"/private/var/mobile/Library/",
        @"/private/var/mobile/Library/Preferences/",
        @"/private/var/mobile/Library/Caches/",
        @"/private/var/mobile/Library/WebKit/"
    ];
    
    for (NSString *path in paths) {
        NSString *file = [path stringByAppendingPathComponent:@"write_test"];
        if ([@"test" writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
            [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
            return (CheckResult){NO, [NSString stringWithFormat:@"Restricted directory is writeable: %@", path]};
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkFork {
    pid_t pid = fork();
    if (pid == 0) {
        exit(0);
    }
    if (pid >= 0) {
        return (CheckResult){NO, @"Fork was able to create a new process"};
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkSymbolicLinks {
    NSArray<NSString *> *paths = @[
        @"/var/lib/undecimus/apt",
        @"/Applications",
        @"/Library/Ringtones",
        @"/Library/Wallpaper",
        @"/usr/arm-apple-darwin9",
        @"/usr/include",
        @"/usr/libexec",
        @"/usr/share"
    ];
    
    struct stat stat_info;
    for (NSString *path in paths) {
        if (lstat([path UTF8String], &stat_info) == 0) {
            if (S_ISLNK(stat_info.st_mode)) {
                return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious symbolic link found: %@", path]};
            }
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkDYLD {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        NSString *imageName = [NSString stringWithUTF8String:_dyld_get_image_name(i)];
        if ([imageName containsString:@"MobileSubstrate"] ||
            [imageName containsString:@"substrate"] ||
            [imageName containsString:@"substitute"] ||
            [imageName containsString:@"TweakInject"] ||
            [imageName containsString:@"libhooker"]) {
            return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious dyld image found: %@", imageName]};
        }
    }
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkSuspiciousObjCClasses {
    Class shadowRulesetClass = objc_getClass("ShadowRuleset");
    if (shadowRulesetClass) {
        SEL selector = NSSelectorFromString(@"internalDictionary");
        if (class_getInstanceMethod(shadowRulesetClass, selector)) {
            return (CheckResult){NO, @"Shadow anti-anti-jailbreak detector detected :-)"};
        }
    }
    return (CheckResult){YES, @""};
}

+ (SGJailbreakStatus *)performChecks {
    BOOL passed = YES;
    NSMutableString *failMessage = [NSMutableString string];
    NSMutableArray<NSValue *> *failedChecks = [NSMutableArray array];
    
    NSArray<NSNumber *> *allChecks = @[
        @(SGFailedCheckURLSchemes),
        @(SGFailedCheckExistenceOfSuspiciousFiles),
        @(SGFailedCheckSuspiciousFilesCanBeOpened),
        @(SGFailedCheckRestrictedDirectoriesWriteable),
        @(SGFailedCheckFork),
        @(SGFailedCheckSymbolicLinks),
        @(SGFailedCheckDYLD),
        @(SGFailedCheckSuspiciousObjCClasses)
    ];
    
    for (NSNumber *checkNum in allChecks) {
        SGFailedCheckType check = [checkNum integerValue];
        CheckResult result = [self getResultFromCheck:check];
        
        passed = passed && result.passed;
        
        if (!result.passed) {
            SGFailedCheckType failedCheck = {check, result.failMessage};
            [failedChecks addObject:[NSValue value:&failedCheck withObjCType:@encode(SGFailedCheckType)]];
            
            if (failMessage.length > 0) {
                [failMessage appendString:@", "];
            }
            [failMessage appendString:result.failMessage];
        }
    }
    
    SGJailbreakStatus *status = [[SGJailbreakStatus alloc] init];
    status.passed = passed;
    status.failMessage = failMessage;
    status.failedChecks = failedChecks;
    
    return status;
}

+ (CheckResult)getResultFromCheck:(SGFailedCheckType)check {
    switch (check) {
        case SGFailedCheckURLSchemes:
            return [self checkURLSchemes];
        case SGFailedCheckExistenceOfSuspiciousFiles:
            return [self checkExistenceOfSuspiciousFiles];
        case SGFailedCheckSuspiciousFilesCanBeOpened:
            return [self checkSuspiciousFilesCanBeOpened];
        case SGFailedCheckRestrictedDirectoriesWriteable:
            return [self checkRestrictedDirectoriesWriteable];
        case SGFailedCheckFork:
            if (![SGEmulatorChecker amIRunInEmulator]) {
                return [self checkFork];
            } else {
                NSLog(@"App run in the emulator, skipping the fork check.");
                return (CheckResult){YES, @""};
            }
        case SGFailedCheckSymbolicLinks:
            return [self checkSymbolicLinks];
        case SGFailedCheckDYLD:
            return [self checkDYLD];
        case SGFailedCheckSuspiciousObjCClasses:
            return [self checkSuspiciousObjCClasses];
        default:
            return (CheckResult){YES, @""};
    }
}

@end

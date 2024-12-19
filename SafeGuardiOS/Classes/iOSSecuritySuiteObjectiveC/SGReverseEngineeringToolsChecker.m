#import "SGReverseEngineeringToolsChecker.h"
#import <mach-o/dyld.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation SGReverseEngineeringToolsStatus

+ (instancetype)statusWithPassed:(BOOL)passed failedChecks:(NSArray<SGFailedCheck *> *)failedChecks {
    SGReverseEngineeringToolsStatus *status = [[SGReverseEngineeringToolsStatus alloc] init];
    status.passed = passed;
    status.failedChecks = failedChecks;
    return status;
}

@end

@implementation SGReverseEngineeringToolsChecker

typedef struct {
    BOOL passed;
    NSString *failMessage;
} CheckResult;

+ (BOOL)amIReverseEngineered {
    return ![self performChecks].passed;
}

+ (NSDictionary<NSString *, id> *)amIReverseEngineeredWithFailedChecks {
    SGReverseEngineeringToolsStatus *status = [self performChecks];
    return @{
        @"reverseEngineered": @(!status.passed),
        @"failedChecks": status.failedChecks
    };
}

+ (SGReverseEngineeringToolsStatus *)performChecks {
    BOOL passed = YES;
    NSMutableArray<SGFailedCheck *> *failedChecks = [NSMutableArray array];
    CheckResult result;
    
    // Check for suspicious files
    result = [self checkExistenceOfSuspiciousFiles];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckExistenceOfSuspiciousFiles
                                                         message:result.failMessage]];
    }
    
    // Check DYLD
    result = [self checkDYLD];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckDYLD
                                                         message:result.failMessage]];
    }
    
    // Check opened ports
    result = [self checkOpenedPorts];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckOpenedPorts
                                                         message:result.failMessage]];
    }
    
    // Check P_SELECT flag
    result = [self checkPSelectFlag];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckPSelectFlag
                                                         message:result.failMessage]];
    }
    
    return [SGReverseEngineeringToolsStatus statusWithPassed:passed failedChecks:failedChecks];
}

+ (CheckResult)checkDYLD {
    NSSet<NSString *> *suspiciousLibraries = [NSSet setWithArray:@[
        @"FridaGadget",
        @"frida",     // Needle injects frida-somerandom.dylib
        @"cynject",
        @"libcycript"
    ]];
    
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *cImageName = _dyld_get_image_name(i);
        if (!cImageName) continue;
        
        NSString *imageName = @(cImageName);
        for (NSString *library in suspiciousLibraries) {
            NSRange range = [imageName rangeOfString:library options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious library loaded: %@", imageName]};
            }
        }
    }
    
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkExistenceOfSuspiciousFiles {
    NSArray<NSString *> *paths = @[
        @"/usr/sbin/frida-server"
    ];
    
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return (CheckResult){NO, [NSString stringWithFormat:@"Suspicious file found: %@", path]};
        }
    }
    
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkOpenedPorts {
    NSArray<NSNumber *> *ports = @[
        @27042,    // default Frida
        @4444,     // default Needle
        @22,       // OpenSSH
        @44        // checkra1n
    ];
    
    for (NSNumber *port in ports) {
        if ([self canOpenLocalConnection:port.intValue]) {
            return (CheckResult){NO, [NSString stringWithFormat:@"Port %@ is open", port]};
        }
    }
    
    return (CheckResult){YES, @""};
}

+ (CheckResult)checkPSelectFlag {
    int result = getppid();
    if (result <= 0) {
        return (CheckResult){NO, @"Suspicious parent PID found"};
    }
    
    return (CheckResult){YES, @""};
}

+ (BOOL)canOpenLocalConnection:(int)port {
    struct sockaddr_in addr;
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return NO;
    }
    
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    inet_pton(AF_INET, "127.0.0.1", &addr.sin_addr);
    
    int result = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
    close(sock);
    
    return result == 0;
}

@end

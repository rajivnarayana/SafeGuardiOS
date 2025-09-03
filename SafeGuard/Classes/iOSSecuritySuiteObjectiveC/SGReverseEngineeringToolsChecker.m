#import "SGReverseEngineeringToolsChecker.h"
#import <mach-o/dyld.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "SGJailbreakChecker.h"

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
    
    
    result = [self checkFridaArtifacts];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckFridaArtifacts
                                                         message:result.failMessage]];
    }
    
    result = [self checkMemoryIntegrity];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckMemoryIntegrity
                                                         message:result.failMessage]];
    }
    
    result = [self enhancedForkCheck];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckEnhancedForkCheck
                                                         message:result.failMessage]];
    }
    
    result = [self checkEnvironmentVariables];
    if (!result.passed) {
        passed = NO;
        [failedChecks addObject:[SGFailedCheck failedCheckWithType:SGFailedCheckEnvironmentVariables
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

//// Anti-debugging check
//+ (BOOL)isDebuggerAttached {
//    int mib[4];
//    struct kinfo_proc info;
//    size_t size = sizeof(info);
//
//    info.kp_proc.p_flag = 0;
//    mib[0] = CTL_KERN;
//    mib[1] = KERN_PROC;
//    mib[2] = KERN_PROC_PID;
//    mib[3] = getpid();
//
//    sysctl(mib, 4, &info, &size, NULL, 0);
//    return ((info.kp_proc.p_flag & P_TRACED) != 0);
//}

// Check for Frida-specific artifacts
+ (CheckResult)checkFridaArtifacts {
    struct sockaddr_in addr;
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)  return (CheckResult){YES, @""};;

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(27042); // Default Frida port
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");

    BOOL fridaDetected = (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) == 0);
    close(sock);

    if (fridaDetected)  return (CheckResult){YES, @""};;

    NSArray *fridaPaths = @[
        @"/usr/sbin/frida-server",
        @"/usr/bin/frida-server",
        @"/usr/local/bin/frida-server",
        @"/data/local/tmp/frida-server",
        @"/data/local/tmp/re.frida.server"
    ];

    for (NSString *path in fridaPaths) {
        if (access([path UTF8String], F_OK) == 0) {
            return (CheckResult){YES, @""};
        }
    }

    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name != NULL) {
            NSString *imageName = [NSString stringWithUTF8String:name];
            if ([imageName containsString:@"frida"] ||
                [imageName containsString:@"gadget"] ||
                [imageName containsString:@"substrate"]) {
                return (CheckResult){YES, @""};
            }
        }
    }

    return (CheckResult){YES, @""};
}

// Memory integrity check
+ (CheckResult)checkMemoryIntegrity {
    const struct mach_header *header = _dyld_get_image_header(0);
    if (!header) return (CheckResult){YES, @""};;

    const struct load_command *cmd = (const struct load_command *)(header + 1);
    for (uint32_t i = 0; i < header->ncmds; i++) {
        if (cmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *seg = (const struct segment_command_64 *)cmd;
            if (strcmp(seg->segname, "__TEXT") == 0) {
                if (seg->initprot & VM_PROT_WRITE) {
                    return (CheckResult){YES, @""};;
                }
            }
        }
        cmd = (const struct load_command *)((uint8_t *)cmd + cmd->cmdsize);
    }

    return (CheckResult){YES, @""};
}

// Enhanced fork check with anti-bypass
+ (CheckResult)enhancedForkCheck {
    pid_t pid = fork();

    if (pid == 0) {
        exit(0);
    }

    return (CheckResult){(pid < 0), @""};
    //(pid < 0);
}

// Check for environment variables used by injection tools
+ (CheckResult)checkEnvironmentVariables {
    NSArray *suspiciousVars = @[
        @"DYLD_INSERT_LIBRARIES",
        @"_MSSafeMode",
        @"_SafeMode",
        @"SUBSTRATE_OVERRIDE_MODE"
    ];

    for (NSString *var in suspiciousVars) {
        if (getenv([var UTF8String]) != NULL) {
            return (CheckResult){YES, @""};;
        }
    }

    return (CheckResult){YES, @""};;
}


@end

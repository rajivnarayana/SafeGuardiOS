//
//  SGFidaDetection.m
//  SafeGuardiOS
//
//  Created by Khousic on 21/07/25.
//


#import "SGFidaDetection.h"
#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>



@implementation SGFidaDetection

+ (BOOL)detectFrida {
    BOOL fridaPorts = [self checkFridaPorts];
    BOOL fridaLibs = [self checkFridaLibraries];
    BOOL fridaTracer = [self checkFridaTracer];
    BOOL debugger = [self isDebuggerAttached];

    BOOL detected = fridaPorts || fridaLibs || fridaTracer || debugger;

    if (detected) {
        NSLog(@"[Security] Frida detected: Ports=%d, Libraries=%d, Tracer=%d, Debugger=%d",
              fridaPorts, fridaLibs, fridaTracer, debugger);
    }

    return detected;
}

+ (BOOL)checkFridaPorts {
    // iOS doesn't allow direct port scanning or netstat,
    // but we can scan common Frida ports (e.g., 27042, 27043) with BSD sockets if needed.
    NSArray *fridaPorts = @[@27042, @27043];
    for (NSNumber *port in fridaPorts) {
        int sock = socket(AF_INET, SOCK_STREAM, 0);
        if (sock < 0) continue;

        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(port.intValue);
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK); // localhost

        int result = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
        close(sock);

        if (result == 0) {
            return YES; // Frida server might be running
        }
    }
    return NO;
}

+ (BOOL)checkFridaLibraries {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && (strstr(name, "frida") || strstr(name, "gum-js"))) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)checkFridaTracer {
#if DEBUG
    return NO; // Always appears traced in simulator
#endif
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    struct kinfo_proc info;
    size_t size = sizeof(info);

    memset(&info, 0, sizeof(info));
    if (sysctl(mib, 4, &info, &size, NULL, 0) == 0) {
        return ((info.kp_proc.p_flag & P_TRACED) != 0);
    }
    return NO;
    
//    int mib[4];
//    struct kinfo_proc info;
//    size_t size;
//
//    info.kp_proc.p_flag = 0;
//    mib[0] = CTL_KERN;
//    mib[1] = KERN_PROC;
//    mib[2] = KERN_PROC_PID;
//    mib[3] = getpid();
//
//    size = sizeof(info);
//    int sysctlResult = sysctl(mib, 4, &info, &size, NULL, 0);
//    if (sysctlResult == 0) {
//        return ((info.kp_proc.p_flag & P_TRACED) != 0);
//    }
//
//    return NO;
}

+ (BOOL)isDebuggerAttached {
   
#if DEBUG
    return NO; // Simulator always reports debugger attached
#endif
    int mib[4];
    struct kinfo_proc info;
    size_t size = sizeof(info);
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    sysctl(mib, 4, &info, &size, NULL, 0);
    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

@end


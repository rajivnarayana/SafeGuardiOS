//
//  SGDeveloperEnabled.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGDeveloperEnabled.h"
#include <sys/sysctl.h>

@implementation SGDeveloperEnabled

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)isDeveloperEnabled {
    int name[4];
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();
    
    info.kp_proc.p_flag = 0;
    
    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        return NO;
    }
    return (info.kp_proc.p_flag & P_TRACED) != 0;
}

@end

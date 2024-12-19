#import "SGFileChecker.h"
#import <sys/mount.h>

@implementation SGMountedVolumeInfo

+ (instancetype)infoWithFileSystem:(NSString *)fileSystem
                    directoryName:(NSString *)directoryName
                         isRoot:(BOOL)isRoot
                     isReadOnly:(BOOL)isReadOnly {
    SGMountedVolumeInfo *info = [[SGMountedVolumeInfo alloc] init];
    info.fileSystemName = fileSystem;
    info.directoryName = directoryName;
    info.isRoot = isRoot;
    info.isReadOnly = isReadOnly;
    return info;
}

@end

@implementation SGFileChecker

+ (nullable SGMountedVolumeInfo *)getMountedVolumeInfoForPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    
    struct statfs statBuffer;
    if (statfs([path UTF8String], &statBuffer) != 0) {
        return nil;
    }
    
    NSString *fileSystemName = [NSString stringWithUTF8String:statBuffer.f_fstypename];
    NSString *directoryName = [NSString stringWithUTF8String:statBuffer.f_mntonname];
    BOOL isRoot = [directoryName isEqualToString:@"/"];
    BOOL isReadOnly = (statBuffer.f_flags & MNT_RDONLY) != 0;
    
    return [SGMountedVolumeInfo infoWithFileSystem:fileSystemName
                                    directoryName:directoryName
                                         isRoot:isRoot
                                     isReadOnly:isReadOnly];
}

+ (nullable NSArray<SGMountedVolumeInfo *> *)getAllMountedVolumes {
    int fscount = getfsstat(NULL, 0, MNT_NOWAIT);
    if (fscount <= 0) {
        return nil;
    }
    
    size_t bufsize = (size_t)(fscount * sizeof(struct statfs));
    struct statfs *buf = (struct statfs *)malloc(bufsize);
    if (!buf) {
        return nil;
    }
    
    fscount = getfsstat(buf, (int)bufsize, MNT_NOWAIT);
    if (fscount <= 0) {
        free(buf);
        return nil;
    }
    
    NSMutableArray<SGMountedVolumeInfo *> *volumes = [NSMutableArray array];
    
    for (int i = 0; i < fscount; i++) {
        NSString *fileSystemName = [NSString stringWithUTF8String:buf[i].f_fstypename];
        NSString *directoryName = [NSString stringWithUTF8String:buf[i].f_mntonname];
        BOOL isRoot = [directoryName isEqualToString:@"/"];
        BOOL isReadOnly = (buf[i].f_flags & MNT_RDONLY) != 0;
        
        SGMountedVolumeInfo *info = [SGMountedVolumeInfo infoWithFileSystem:fileSystemName
                                                            directoryName:directoryName
                                                                 isRoot:isRoot
                                                             isReadOnly:isReadOnly];
        [volumes addObject:info];
    }
    
    free(buf);
    return volumes;
}

+ (nullable SGMountedVolumeInfo *)getMountedVolumeInfoForName:(NSString *)name {
    NSArray<SGMountedVolumeInfo *> *volumes = [self getAllMountedVolumes];
    if (!volumes) {
        return nil;
    }
    
    for (SGMountedVolumeInfo *info in volumes) {
        if ([info.fileSystemName isEqualToString:name]) {
            return info;
        }
    }
    
    return nil;
}

@end

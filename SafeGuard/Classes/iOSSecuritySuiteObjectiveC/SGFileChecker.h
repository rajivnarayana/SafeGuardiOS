#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SGFileMode) {
    SGFileModeReadable,
    SGFileModeWritable
};

@interface SGMountedVolumeInfo : NSObject

@property (nonatomic, copy) NSString *fileSystemName;
@property (nonatomic, copy) NSString *directoryName;
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, assign) BOOL isReadOnly;

+ (instancetype)infoWithFileSystem:(NSString *)fileSystem
                    directoryName:(NSString *)directoryName
                         isRoot:(BOOL)isRoot
                     isReadOnly:(BOOL)isReadOnly;

@end

@interface SGFileChecker : NSObject

/**
 * Gets information about mounted volumes via statfs
 * @param path The pathname of any file within the mounted file system
 * @return Returns nil if statfs() gives a non-zero result
 */
+ (nullable SGMountedVolumeInfo *)getMountedVolumeInfoForPath:(NSString *)path;

/**
 * Gets information about mounted volumes via getfsstat
 * @param name Name of the volume to search for
 * @return Returns volume info if found, nil otherwise
 */
+ (nullable SGMountedVolumeInfo *)getMountedVolumeInfoForName:(NSString *)name;

/**
 * Gets a list of all mounted volumes
 * @return Array of SGMountedVolumeInfo objects
 */
+ (nullable NSArray<SGMountedVolumeInfo *> *)getAllMountedVolumes;

@end

NS_ASSUME_NONNULL_END

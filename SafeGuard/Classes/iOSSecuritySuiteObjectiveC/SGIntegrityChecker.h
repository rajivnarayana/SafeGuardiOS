#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SGFileIntegrityCheckType) {
    SGFileIntegrityCheckTypeBundleID,
    SGFileIntegrityCheckTypeMobileProvision,
    SGFileIntegrityCheckTypeMachO
};

@interface SGFileIntegrityCheck : NSObject

@property (nonatomic, assign) SGFileIntegrityCheckType type;
@property (nonatomic, copy) NSString *expectedValue;
@property (nonatomic, copy, nullable) NSString *imageName;  // Only used for MachO type

+ (instancetype)bundleIDCheck:(NSString *)expectedBundleID;
+ (instancetype)mobileProvisionCheck:(NSString *)expectedSha256;
+ (instancetype)machOCheck:(NSString *)imageName expectedHash:(NSString *)expectedSha256;

- (NSString *)description;

@end

@interface SGIntegrityCheckResult : NSObject

@property (nonatomic, assign) BOOL result;
@property (nonatomic, strong) NSArray<SGFileIntegrityCheck *> *hitChecks;

@end

@interface SGIntegrityChecker : NSObject

+ (SGIntegrityCheckResult *)amITamperedWithChecks:(NSArray<SGFileIntegrityCheck *> *)checks;

@end

NS_ASSUME_NONNULL_END

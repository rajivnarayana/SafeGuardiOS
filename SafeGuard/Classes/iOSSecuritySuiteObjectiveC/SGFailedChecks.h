#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SGFailedCheckType) {
    SGFailedCheckURLSchemes,
    SGFailedCheckExistenceOfSuspiciousFiles,
    SGFailedCheckSuspiciousFilesCanBeOpened,
    SGFailedCheckRestrictedDirectoriesWriteable,
    SGFailedCheckFork,
    SGFailedCheckSymbolicLinks,
    SGFailedCheckDYLD,
    SGFailedCheckOpenedPorts,
    SGFailedCheckPSelectFlag,
    SGFailedCheckFridaArtifacts,
    SGFailedCheckMemoryIntegrity,
    SGFailedCheckEnhancedForkCheck,
    SGFailedCheckEnvironmentVariables,
    SGFailedCheckSuspiciousObjCClasses
};

@interface SGFailedCheck : NSObject

@property (nonatomic, assign) SGFailedCheckType checkType;
@property (nonatomic, copy) NSString *failMessage;

+ (instancetype)failedCheckWithType:(SGFailedCheckType)type message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END

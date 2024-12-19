#import <Foundation/Foundation.h>
#import "SGFailedChecks.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGReverseEngineeringToolsStatus : NSObject

@property (nonatomic, assign) BOOL passed;
@property (nonatomic, strong) NSArray<SGFailedCheck *> *failedChecks;

+ (instancetype)statusWithPassed:(BOOL)passed failedChecks:(NSArray<SGFailedCheck *> *)failedChecks;

@end

@interface SGReverseEngineeringToolsChecker : NSObject

/**
 * Checks if the app is being reverse engineered
 * @return YES if reverse engineering is detected, NO otherwise
 */
+ (BOOL)amIReverseEngineered;

/**
 * Checks if the app is being reverse engineered and returns detailed failure information
 * @return Dictionary containing:
 *         - @"reverseEngineered": @(BOOL)
 *         - @"failedChecks": NSArray<SGFailedCheck *>
 */
+ (NSDictionary<NSString *, id> *)amIReverseEngineeredWithFailedChecks;

@end

NS_ASSUME_NONNULL_END

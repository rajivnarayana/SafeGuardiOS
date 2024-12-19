#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGModesChecker : NSObject

/**
 * Checks if the device is in Lockdown Mode
 * @return YES if in Lockdown Mode, NO otherwise
 */
+ (BOOL)amIInLockdownMode;

@end

NS_ASSUME_NONNULL_END

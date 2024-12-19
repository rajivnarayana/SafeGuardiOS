#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGEmulatorChecker : NSObject

/**
 * Checks if the app is running in an emulator/simulator
 * @return YES if running in emulator, NO if running on a real device
 */
+ (BOOL)amIRunInEmulator;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGNetworkChecker : NSObject

/**
 * Checks if the device is using a proxy or VPN connection.
 * @return YES if a proxy or VPN is detected, NO otherwise.
 */
+ (BOOL)amIProxied;

@end

NS_ASSUME_NONNULL_END

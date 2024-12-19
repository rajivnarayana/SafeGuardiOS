#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGMSHookFunctionChecker : NSObject

/**
 * Checks if a function has been hooked using MSHookFunction
 * @param functionAddr The address of the function to check
 * @return YES if hooked, NO otherwise
 */
+ (BOOL)amIMSHooked:(void *)functionAddr;

/**
 * Attempts to deny MSHook on a function
 * @param functionAddr The address of the function to protect
 * @return The original function address if successful, NULL otherwise
 */
+ (void * _Nullable)denyMSHook:(void *)functionAddr;

@end

NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>
#import "SGFailedChecks.h"

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(9.0))
NS_EXTENSION_UNAVAILABLE_IOS("SGSecuritySuite not available for App extensions")
@interface SGSecuritySuite : NSObject

#pragma mark - Jailbreak Detection
/**
 * Checks if the device is jailbroken
 * @return YES if jailbroken, NO otherwise
 */
+ (BOOL)amIJailbroken;

/**
 * Checks if the device is jailbroken with failure message
 * @return Dictionary containing:
 *         - @"jailbroken": @(BOOL)
 *         - @"failMessage": NSString
 */
+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailMessage;

/**
 * Checks if the device is jailbroken with failed checks
 * @return Dictionary containing:
 *         - @"jailbroken": @(BOOL)
 *         - @"failedChecks": NSArray<SGFailedCheck *>
 */
+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailedChecks;

#pragma mark - Debugger Detection
/**
 * Checks if the app is being debugged
 * @return YES if debugged, NO otherwise
 */
+ (BOOL)amIDebugged;

/**
 * Denies debugger attachment
 */
+ (void)denyDebugger;

#pragma mark - Reverse Engineering Detection
/**
 * Checks if the app is being reverse engineered
 * @return YES if reverse engineered, NO otherwise
 */
+ (BOOL)amIReverseEngineered;

/**
 * Checks if the app is being reverse engineered with failed checks
 * @return Dictionary containing:
 *         - @"reverseEngineered": @(BOOL)
 *         - @"failedChecks": NSArray<SGFailedCheck *>
 */
+ (NSDictionary<NSString *, id> *)amIReverseEngineeredWithFailedChecks;

#pragma mark - Runtime Manipulation Detection
/**
 * Checks if a method has been hooked at runtime
 * @param dyldAllowList List of allowed dyld paths
 * @param detectionClass The class to check
 * @param selector The selector to check
 * @param isClassMethod YES if checking a class method, NO for instance method
 * @return YES if hooked, NO otherwise
 */
+ (BOOL)amIRuntimeHookWithDyldAllowList:(NSArray<NSString *> *)dyldAllowList
                         detectionClass:(Class)detectionClass
                             selector:(SEL)selector
                        isClassMethod:(BOOL)isClassMethod;

#pragma mark - Integrity Checking
/**
 * Checks if the app has been tampered with
 * @param checks Array of integrity checks to perform
 * @return Dictionary containing:
 *         - @"tampered": @(BOOL)
 *         - @"failedChecks": NSArray<SGFailedCheck *>
 */
+ (NSDictionary<NSString *, id> *)amITamperedWithChecks:(NSArray *)checks;

#pragma mark - Emulator Detection
/**
 * Checks if the app is running in an emulator
 * @return YES if in emulator, NO otherwise
 */
+ (BOOL)amIRunInEmulator;

#pragma mark - Proxy Detection
/**
 * Checks if the device is using a proxy
 * @return YES if using proxy, NO otherwise
 */
+ (BOOL)amIProxied;

#pragma mark - Mode Detection
/**
 * Checks if the device is in Lockdown Mode
 * @return YES if in Lockdown Mode, NO otherwise
 */
+ (BOOL)amIInLockdownMode;

#if defined(__arm64__)
#pragma mark - MSHook Detection
/**
 * Checks if a function has been hooked using MSHook
 * @param functionAddr The function address to check
 * @return YES if hooked, NO otherwise
 */
+ (BOOL)amIMSHooked:(void *)functionAddr;

/**
 * Denies MSHook on a function
 * @param functionAddr The function to protect
 * @return Original function address if successful, NULL otherwise
 */
+ (void * _Nullable)denyMSHook:(void *)functionAddr;

/**
 * Checks if a function has a breakpoint
 * @param functionAddr The function address to check
 * @param functionSize Optional size of the function
 * @return YES if breakpoint found, NO otherwise
 */
+ (BOOL)hasBreakpointAt:(const void *)functionAddr functionSize:(vm_size_t)functionSize;
#endif

@end

NS_ASSUME_NONNULL_END

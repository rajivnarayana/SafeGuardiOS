#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGRuntimeHookChecker : NSObject

/**
 * Checks if a method implementation has been hooked at runtime
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

@end

NS_ASSUME_NONNULL_END

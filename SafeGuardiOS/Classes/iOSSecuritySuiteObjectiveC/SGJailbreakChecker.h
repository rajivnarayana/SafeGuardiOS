#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGJailbreakStatus : NSObject
@property (nonatomic, assign) BOOL passed;
@property (nonatomic, copy) NSString *failMessage;
@property (nonatomic, strong) NSArray<NSValue *> *failedChecks;  // Array of SGFailedCheckType wrapped in NSValue
@end

@interface SGJailbreakChecker : NSObject

+ (BOOL)amIJailbroken;
+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailMessage;  // Returns @{@"jailbroken": @(BOOL), @"failMessage": NSString}
+ (NSDictionary<NSString *, id> *)amIJailbrokenWithFailedChecks; // Returns @{@"jailbroken": @(BOOL), @"failedChecks": NSArray<SGFailedCheckType>}

@end

NS_ASSUME_NONNULL_END

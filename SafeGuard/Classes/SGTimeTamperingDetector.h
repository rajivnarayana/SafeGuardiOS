// SGTimeTamperingDetector.h
#import <Foundation/Foundation.h>
#import <Network/Network.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGTimeTamperingDetector : NSObject

- (BOOL)checkForTimeTampering;
- (void)verifyTimeWithNTPCompletion:(void (^)(BOOL isSynchronized))completion;

@end

NS_ASSUME_NONNULL_END


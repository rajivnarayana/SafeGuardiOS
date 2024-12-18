#import <Foundation/Foundation.h>
#import "SGSecurityConfiguration.h"

@protocol SGSecurityCheck <NSObject>

@required
- (void)performCheckWithCompletion:(void(^)(BOOL passed, NSString *failureMessage))completion;
- (SGSecurityLevel)securityLevel;
- (void)setSecurityLevel:(SGSecurityLevel)level;

@end

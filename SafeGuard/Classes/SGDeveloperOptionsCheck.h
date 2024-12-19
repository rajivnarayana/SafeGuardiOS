#import <Foundation/Foundation.h>
#import "SGSecurityCheck.h"

@interface SGDeveloperOptionsCheck : NSObject <SGSecurityCheck>

@property (nonatomic, assign) SGSecurityLevel securityLevel;

@end

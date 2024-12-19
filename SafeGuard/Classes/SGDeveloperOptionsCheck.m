#import "SGDeveloperOptionsCheck.h"

@implementation SGDeveloperOptionsCheck

- (void)performCheckWithCompletion:(void (^)(BOOL, NSString *))completion {
    // On iOS, developer mode is controlled through Xcode and profiles
    // We can check if the app is running in debug mode
    #if DEBUG
        completion(NO, @"App is running in debug mode");
    #else
        completion(YES, nil);
    #endif
}

@end

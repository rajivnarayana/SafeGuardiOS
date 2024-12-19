//
//  SGAppSignature.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGAppSignature.h"

@implementation SGAppSignature

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)runShellCommand:(NSString *)command {
    const char *cmd = [command UTF8String];
    FILE *pipe = popen(cmd, "r");
    
    if (!pipe) {
        return nil;  // Error occurred
    }
    
    char buffer[128];
    NSMutableString *output = [NSMutableString string];
    
    while (fgets(buffer, sizeof(buffer), pipe)) {
        [output appendString:[NSString stringWithUTF8String:buffer]];
    }
    
    fclose(pipe);
    
    return output;
}

- (BOOL)isAppSignatureValid {
    NSString *path = [[NSBundle mainBundle] bundlePath];
      NSString *command = [NSString stringWithFormat:@"codesign --verify --verbose=4 %@", path];
      
      NSString *result = [self runShellCommand:command];
      
      if ([result length] == 0) {
          return NO;  // App signature is valid
      } else {
          NSLog(@"Code signing verification failed: %@", result);
          return YES;  // App signature is invalid
      }
}
@end

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGDebuggerChecker : NSObject

+ (BOOL)amIDebugged;
+ (void)denyDebugger;
+ (BOOL)hasBreakpointAtAddress:(const void *)functionAddr functionSize:(vm_size_t)functionSize;

@end

NS_ASSUME_NONNULL_END

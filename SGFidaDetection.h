//
//  SGFidaDetection.h
//  SafeGuardiOS
//
//  Created by Khousic on 21/07/25.
//


#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/sysctl.h>

@interface SGFidaDetection : NSObject

+ (BOOL)detectFrida;
+ (BOOL)checkFridaPorts;
+ (BOOL)checkFridaLibraries;
+ (BOOL)checkFridaTracer;
+ (BOOL)isDebuggerAttached;

@end

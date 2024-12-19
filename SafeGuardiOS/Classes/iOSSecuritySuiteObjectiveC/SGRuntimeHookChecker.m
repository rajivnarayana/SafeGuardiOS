#import "SGRuntimeHookChecker.h"
#import "SGFishHookChecker.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

@implementation SGRuntimeHookChecker

static dispatch_once_t onceToken;

+ (void)initialize {
    dispatch_once(&onceToken, ^{
#if defined(__arm64__)
        [SGFishHook replaceSymbol:@"dladdr"
                        atImage:_dyld_get_image_header(0)
                    imageSlide:_dyld_get_image_vmaddr_slide(0)
                originalSymbol:NULL
               replacedSymbol:NULL];
#endif
    });
}

+ (BOOL)amIRuntimeHookWithDyldAllowList:(NSArray<NSString *> *)dyldAllowList
                         detectionClass:(Class)detectionClass
                             selector:(SEL)selector
                        isClassMethod:(BOOL)isClassMethod {
    Method method;
    if (isClassMethod) {
        method = class_getClassMethod(detectionClass, selector);
    } else {
        method = class_getInstanceMethod(detectionClass, selector);
    }
    
    if (!method) {
        // method not found
        return YES;
    }
    
    IMP imp = method_getImplementation(method);
    Dl_info info;
    
    // dladdr will look through vm range of allImages for vm range of an Image that contains pointer
    // of method and return info of the Image
    if (dladdr((const void *)imp, &info) != 1) {
        return NO;
    }
    
    NSString *impDyldPath = [[NSString stringWithUTF8String:info.dli_fname] lowercaseString];
    
    // at system framework
    if ([impDyldPath containsString:@"/system/library"]) {
        return NO;
    }
    
    // at binary
    if ([impDyldPath containsString:[[NSBundle mainBundle].bundlePath lowercaseString]]) {
        return NO;
    }
    
    // at allowed list
    for (NSString *allowPath in dyldAllowList) {
        if ([impDyldPath containsString:[allowPath lowercaseString]]) {
            return NO;
        }
    }
    
    return YES;
}

@end

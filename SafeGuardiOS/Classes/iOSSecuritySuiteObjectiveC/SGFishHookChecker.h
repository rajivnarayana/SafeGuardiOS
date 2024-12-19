#import <Foundation/Foundation.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGSymbolFound : NSObject

+ (BOOL)lookSymbol:(NSString *)symbol
            atImage:(const struct mach_header *)image
        imageSlide:(intptr_t)slide
    symbolAddress:(void * _Nullable * _Nullable)symbolAddress;

+ (BOOL)lookExportedSymbol:(NSString *)symbol
           exportImageName:(NSString *)exportImageName
           symbolAddress:(void * _Nullable * _Nullable)symbolAddress;

@end

@interface SGFishHook : NSObject

+ (BOOL)replaceSymbol:(NSString *)symbol
              atImage:(const struct mach_header *)image
          imageSlide:(intptr_t)slide
      originalSymbol:(void * _Nullable * _Nullable)originalSymbol
     replacedSymbol:(void *)replacedSymbol;

@end

NS_ASSUME_NONNULL_END

#import "SGIntegrityChecker.h"
#import <CommonCrypto/CommonDigest.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>

@implementation SGFileIntegrityCheck

+ (instancetype)bundleIDCheck:(NSString *)expectedBundleID {
    SGFileIntegrityCheck *check = [[SGFileIntegrityCheck alloc] init];
    check.type = SGFileIntegrityCheckTypeBundleID;
    check.expectedValue = expectedBundleID;
    return check;
}

+ (instancetype)mobileProvisionCheck:(NSString *)expectedSha256 {
    SGFileIntegrityCheck *check = [[SGFileIntegrityCheck alloc] init];
    check.type = SGFileIntegrityCheckTypeMobileProvision;
    check.expectedValue = expectedSha256;
    return check;
}

+ (instancetype)machOCheck:(NSString *)imageName expectedHash:(NSString *)expectedSha256 {
    SGFileIntegrityCheck *check = [[SGFileIntegrityCheck alloc] init];
    check.type = SGFileIntegrityCheckTypeMachO;
    check.imageName = imageName;
    check.expectedValue = expectedSha256;
    return check;
}

- (NSString *)description {
    switch (self.type) {
        case SGFileIntegrityCheckTypeBundleID:
            return [NSString stringWithFormat:@"The expected bundle identifier was %@", self.expectedValue];
        case SGFileIntegrityCheckTypeMobileProvision:
            return [NSString stringWithFormat:@"The expected hash value of Mobile Provision file was %@", self.expectedValue];
        case SGFileIntegrityCheckTypeMachO:
            return [NSString stringWithFormat:@"The expected hash value of \"__TEXT.__text\" data of %@ Mach-O file was %@", self.imageName, self.expectedValue];
    }
}

@end

@implementation SGIntegrityCheckResult
@end

@interface SGMachOParse : NSObject

@property (nonatomic, assign) const struct mach_header *base;
@property (nonatomic, assign) intptr_t slide;

- (instancetype)init;
- (BOOL)findSegment:(NSString *)segmentName textSectionData:(NSData **)textSectionData;

@end

@implementation SGMachOParse

- (instancetype)init {
    self = [super init];
    if (self) {
        for (uint32_t i = 0; i < _dyld_image_count(); i++) {
            const struct mach_header *header = (const struct mach_header *)_dyld_get_image_header(i);
            if (header->filetype == MH_EXECUTE) {
                _base = header;
                _slide = _dyld_get_image_vmaddr_slide(i);
                break;
            }
        }
    }
    return self;
}

- (BOOL)findSegment:(NSString *)segmentName textSectionData:(NSData **)textSectionData {
    if (!self.base || self.base->magic != MH_MAGIC_64) {
        return NO;
    }
    
    const struct mach_header_64 *header = (const struct mach_header_64 *)self.base;
    const struct load_command *cmd = (const struct load_command *)((uint8_t *)header + sizeof(struct mach_header_64));
    
    for (uint32_t i = 0; i < header->ncmds; i++) {
        if (cmd->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *seg = (const struct segment_command_64 *)cmd;
            if (strcmp(seg->segname, [segmentName UTF8String]) == 0) {
                const struct section_64 *section = (const struct section_64 *)((uint8_t *)seg + sizeof(struct segment_command_64));
                for (uint32_t j = 0; j < seg->nsects; j++) {
                    if (strcmp(section->sectname, "__text") == 0) {
                        uint64_t size = section->size;
                        void *start = (void *)((uint8_t *)self.base + (section->addr - (uint64_t)self.base));
                        *textSectionData = [NSData dataWithBytes:start length:size];
                        return YES;
                    }
                    section++;
                }
            }
        }
        cmd = (const struct load_command *)((uint8_t *)cmd + cmd->cmdsize);
    }
    return NO;
}

@end

@implementation SGIntegrityChecker

+ (NSString *)hexStringFromData:(NSData *)data {
    NSMutableString *hexString = [NSMutableString stringWithCapacity:data.length * 2];
    const unsigned char *bytes = data.bytes;
    for (NSInteger i = 0; i < data.length; i++) {
        [hexString appendFormat:@"%02x", bytes[i]];
    }
    return hexString;
}

+ (BOOL)checkBundleID:(NSString *)expectedBundleID {
    NSString *currentBundleID = [[NSBundle mainBundle] bundleIdentifier];
    return [expectedBundleID isEqualToString:currentBundleID];
}

+ (BOOL)checkMobileProvision:(NSString *)expectedSha256 {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (!path) {
        return NO;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return NO;
    }
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    
    NSData *hashData = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    NSString *hashString = [self hexStringFromData:hashData];
    
    NSLog(@"Expected Hash: %@, Actual Hash: %@", expectedSha256, hashString);
    return [hashString isEqualToString:expectedSha256.lowercaseString];
}

+ (NSString *) actualSignatureHash {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if (!path) {
        return nil;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);
    
    NSData *hashData = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    NSString *hashString = [self hexStringFromData:hashData];
    
    return hashString;
}

+ (BOOL)checkMachO:(NSString *)imageName expectedHash:(NSString *)expectedSha256 {
    SGMachOParse *parser = [[SGMachOParse alloc] init];
    NSData *textSectionData = nil;
    
    if (![parser findSegment:@"__TEXT" textSectionData:&textSectionData]) {
        return NO;
    }
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(textSectionData.bytes, (CC_LONG)textSectionData.length, hash);
    
    NSData *hashData = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    NSString *hashString = [self hexStringFromData:hashData];
    
    return [hashString isEqualToString:expectedSha256.lowercaseString];
}

+ (SGIntegrityCheckResult *)amITamperedWithChecks:(NSArray<SGFileIntegrityCheck *> *)checks {
    SGIntegrityCheckResult *result = [[SGIntegrityCheckResult alloc] init];
    NSMutableArray<SGFileIntegrityCheck *> *hitChecks = [NSMutableArray array];
    BOOL isTampered = NO;
    
    for (SGFileIntegrityCheck *check in checks) {
        BOOL checkResult = NO;
        
        switch (check.type) {
            case SGFileIntegrityCheckTypeBundleID:
                checkResult = [self checkBundleID:check.expectedValue];
                break;
                
            case SGFileIntegrityCheckTypeMobileProvision:
                checkResult = [self checkMobileProvision:check.expectedValue];
                break;
                
            case SGFileIntegrityCheckTypeMachO:
                checkResult = [self checkMachO:check.imageName expectedHash:check.expectedValue];
                break;
        }
        
        if (checkResult) {
            isTampered = YES;
            [hitChecks addObject:check];
        }
    }
    
    result.result = isTampered;
    result.hitChecks = hitChecks;
    
    return result;
}

@end

//
//  SGChecksumValidation.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGChecksumValidation.h"
#import "CryptLib.h"
@implementation SGChecksumValidation

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)calculateSHA256ForAppBinary {
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    NSData *appData = [NSData dataWithContentsOfFile:appPath];
    if (!appData) {
        return nil;
    }
    
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(appData.bytes, (CC_LONG)appData.length, hash);
    
    NSMutableString *checksum = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [checksum appendFormat:@"%02x", hash[i]];
    }
    return checksum;
}


-(BOOL)isChecksumValid{
    NSString *publishedChecksum = @"<published_checksum>";  // paste the checksum string
    NSString *calculatedChecksum = [self calculateSHA256ForAppBinary];
    
    if ([calculatedChecksum isEqualToString:publishedChecksum]) {
        NSLog(@"Checksum validation passed.");
        return YES;
    } else {
        NSLog(@"Checksum validation failed. App may be tampered.");
        return NO;
    }
}

@end

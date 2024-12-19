//
//  SGChecksumValidation.h
//  SafeGuardiOS
//
//  Created by Khousic on 20/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGChecksumValidation : NSObject
@property NSString *hashValue;
-(BOOL)isChecksumValid;
@end

NS_ASSUME_NONNULL_END

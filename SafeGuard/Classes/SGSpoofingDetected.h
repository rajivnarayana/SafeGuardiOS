//
//  SGSpoofingDetected.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGSpoofingDetected : NSObject
- (BOOL)isSpoofingDetected ;
@property NSString *bundleID;
@end

NS_ASSUME_NONNULL_END

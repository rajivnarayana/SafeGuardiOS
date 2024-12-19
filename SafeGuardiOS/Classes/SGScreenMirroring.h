//
//  SGScreenMirroring.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGScreenMirroring : NSObject
@property bool isDetect;
-(BOOL)isScreenMirrored;
@end

NS_ASSUME_NONNULL_END

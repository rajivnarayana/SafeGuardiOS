//
//  SGScreenShotPrevention.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGScreenShotPrevention : NSObject
@property BOOL isSSTaken;
-(void)preventScreenShot;
@end

NS_ASSUME_NONNULL_END

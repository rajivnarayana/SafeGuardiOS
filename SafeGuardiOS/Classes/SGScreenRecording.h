//
//  SGScreenRecording.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGScreenRecording : NSObject
@property bool isDetect;
-(BOOL)isScreenRecorded;
@end

NS_ASSUME_NONNULL_END

//
//  SGAudioCallDetection.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>
#import <CallKit/CallKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SGAudioCallAlertProtocol <NSObject>

-(void)callStarted;

@end

@interface SGAudioCallDetection : NSObject<CXCallObserverDelegate>
@property (nonatomic, strong) CXCallObserver *callObserver;
@property (nonatomic, weak) id<SGAudioCallAlertProtocol> delegate;
@property bool isCallDetect;

- (BOOL)isAudioCallDetected;
@end

NS_ASSUME_NONNULL_END

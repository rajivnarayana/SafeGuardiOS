//
//  SGAudioCallDetection.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGAudioCallDetection.h"

@implementation SGAudioCallDetection


- (instancetype)init {
    self = [super init];
    if (self) {
        self.callObserver = [[CXCallObserver alloc] init];
        [self.callObserver setDelegate:self queue:nil];
    }
    return self;
}

// Delegate method called when a call's status changes
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    // Check if the call is connected and not ended
    if (call.hasConnected && !call.hasEnded) {
        // If an audio call is ongoing, show an alert
        _isCallDetect = true;
    }else{
        _isCallDetect = false;
    }
    
}

- (void)checkForInitialCalls {
    // Check if there are any active calls when the app starts
    for (CXCall *call in self.callObserver.calls) {
        // You can check the call status and handle accordingly
        if (call.hasConnected && !call.hasEnded) {
            _isCallDetect = true;
        }
    }
}

- (BOOL)isAudioCallDetected{
    [self checkForInitialCalls];
    return _isCallDetect;
}

@end

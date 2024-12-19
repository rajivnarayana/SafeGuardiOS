//
//  SGScreenMirroring.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGScreenMirroring.h"

@implementation SGScreenMirroring

- (instancetype)init {
    self = [super init];
    if (self) {
        _isDetect = false;
    }
    return self;
}

-(void)screenRec{
    if (@available(iOS 11.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenCapturedDidChangeNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            if ([UIScreen mainScreen].isCaptured) {
                NSLog(@"Screen is being recorded or mirrored.");
                self->_isDetect = true;
            }
        }];
    }
}

-(BOOL)isScreenMirrored{
    [self screenRec];
    return _isDetect;
}
@end

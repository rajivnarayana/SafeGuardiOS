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
       
      //  [self screenRec];
    }
    return self;
}

- (BOOL)isScreenBeingCaptured {
    __block BOOL isCaptured = NO; // Block variable to hold the status

    [[NSNotificationCenter defaultCenter] addObserverForName:UIScreenCapturedDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        if ([UIScreen mainScreen].isCaptured) {
            NSLog(@"Screen is being recorded or mirrored.");
            isCaptured = YES; // Update the status
        } else {
            isCaptured = NO; // Reset the status
        }
    }];

    // Check the current status immediately
    if ([UIScreen mainScreen].isCaptured) {
        isCaptured = YES;
    }

    return isCaptured;
}


@end

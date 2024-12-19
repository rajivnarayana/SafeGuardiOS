//
//  SGScreenShotPrevention.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGScreenShotPrevention.h"

@implementation SGScreenShotPrevention
- (instancetype)init {
    self = [super init];
    if (self) {
        _isSSTaken = false;
    }
    return self;
}


-(void)preventScreenShot{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didTakeScreenshot:)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)didTakeScreenshot:(NSNotification *)notification {
    _isSSTaken = true;
    // Call your custom method or show an alert here
    // 1. Add Overlay for Screenshot Prevention Message
    [self showScreenshotOverlay];
    // [self showLockedScreenMessage];
    // 2. Show Alert for Screenshot Taken
    [self showScreenshotTakenAlert];
}


- (void)showScreenshotOverlay {
    // Get the main window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // Create overlay with custom text
    UIView *overlayView = [[UIView alloc] initWithFrame:window.bounds];
    overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];  // Dark transparent background
    overlayView.tag = 12345; // Set a tag to identify the overlay later
    
    // Create label for the message
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, window.bounds.size.height / 2 - 25, window.bounds.size.width, 50)];
    label.text = @"Screenshot Prevented";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:20];
    [overlayView addSubview:label];
    
    // Add the overlay to the window
    [window addSubview:overlayView];
    
    // 2. Remove the overlay after a brief period (1 second)
    [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        overlayView.alpha = 0;
    } completion:^(BOOL finished) {
        [overlayView removeFromSuperview];
    }];
}

- (void)showScreenshotTakenAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Screenshot Taken"
                                                                             message:@"You have taken a screenshot. Sensitive data was hidden for security purposes."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    // Present alert from the root view controller
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end

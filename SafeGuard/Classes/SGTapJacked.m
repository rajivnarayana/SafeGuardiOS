//
//  SGTapJacked.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGTapJacked.h"

@implementation SGTapJacked

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)validateTouches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Get the main application window
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    
    if (!mainWindow) {
        NSLog(@"No active window found.");
        return;
    }
    
    // Ensure there are touches to validate
    UITouch *touch = [touches anyObject];
    if (!touch) {
        NSLog(@"No touch detected.");
        return;
    }
    
    // Get the touch location relative to the main window
    CGPoint location = [touch locationInView:mainWindow];
    
    // Check if the touch is within the window bounds
    if (!CGRectContainsPoint(mainWindow.bounds, location)) {
        NSLog(@"Potential tap jacking attempt detected. Touch location: %@", NSStringFromCGPoint(location));
        _isTapJacked = YES;
    } else {
        _isTapJacked = NO;
    }
}

-(BOOL)isTapJackedDevice{
    return _isTapJacked;
}

@end

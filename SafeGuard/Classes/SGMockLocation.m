//
//  SGMockLocation.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGMockLocation.h"
#import "SGSecurityChecker.h"

@implementation SGMockLocation
- (instancetype)init {
    self = [super init];
    if (self) {
        _isLocationMockked = false;
        [self intilizelocations];
    }
    return self;
}


-(void)intilizelocations{
    // Initialize the CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Check for iOS 14+ accuracy settings
    if (@available(iOS 14.0, *)) {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    } else {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    
    
    
    // Check current authorization status
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // Request authorization only if not determined
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
               [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        // Start location updates immediately if already authorized
        [self.locationManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to get location: %@", error.localizedDescription);
}
// Authorization status changes
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        // Safe to start location updates
        [self.locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        // Handle denied/restricted cases
        NSLog(@"Location access denied. Show an alert to the user.");
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *newLocation = [locations lastObject];
        CLLocation *oldLocation = self.lastLocation;
        
        if (oldLocation) {
            CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
            if (distance > 1000) { // Detect large jumps, e.g., > 1000 meters
                NSLog(@"Possible mock location detected. Large jump in distance.");
                _isLocationMockked = YES;
                [[SGSecurityChecker sharedInstance] LocationALert];
            }
        }
        
        self.lastLocation = newLocation;
    }
}

- (BOOL)isMockLocation {
    if (_isLocationMockked) {
        return YES;
    }
    return NO;
}

-(void)stopMontiring{
    [self.locationManager stopUpdatingLocation];
}
@end

//
//  SGMockLocation.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGMockLocation : NSObject<CLLocationManagerDelegate>
@property bool isLocationMockked;
@property CLLocation *lastLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (BOOL)isMockLocation ;
@end

NS_ASSUME_NONNULL_END

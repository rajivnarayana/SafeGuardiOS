//
//  SGWifiSecure.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>
#import <Network/Network.h>
#import <SystemConfiguration/CaptiveNetwork.h>
NS_ASSUME_NONNULL_BEGIN

@interface SGWifiSecure : NSObject
@property bool isWIFiINSecure;
-(BOOL)isWifiSecure;
@end

NS_ASSUME_NONNULL_END

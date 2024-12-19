//
//  SGVPNConnection.h
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVPNConnection : NSObject
- (BOOL)isVPNConnected ;
@end

NS_ASSUME_NONNULL_END

//
//  SGTimeManipulation.m
//  SafeGuardiOS
//
//  Created by Khousic on 19/12/24.
//

#import "SGTimeManipulation.h"

@implementation SGTimeManipulation
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(BOOL)isTimeManipulation{
    __block  bool isTimeMockked = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        // Fetch current device time and compare with a remote NTP time
        NSURL *url = [NSURL URLWithString:@"https://worldtimeapi.org/api/timezone/Etc/UTC"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                NSError *jsonError;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (!jsonError) {
                    NSString *serverTimeStr = json[@"datetime"];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"];
                    NSDate *serverTime = [dateFormatter dateFromString:serverTimeStr];
                    NSDate *deviceTime = [NSDate date];
                    
                    NSTimeInterval difference = [deviceTime timeIntervalSinceDate:serverTime];
                    if (fabs(difference) > 60) { // 1 minute tolerance
                        NSLog(@"Device time might have been tampered with. Time difference: %f", difference);
                        isTimeMockked = YES;
                    }else{
                        isTimeMockked = NO;
                    }
                }
            }
        }];
        [task resume];
    });
    return  isTimeMockked;
    
}
@end

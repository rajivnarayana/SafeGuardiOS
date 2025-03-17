// SGTimeTamperingDetector.m
#import "SGTimeTamperingDetector.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

#define NTP_PORT 123
#define NTP_PACKET_SIZE 48
#define NTP_TIMESTAMP_DELTA 2208988800ull // Seconds between 1900 (NTP epoch) and 1970 (Unix epoch)

@interface SGTimeTamperingDetector ()

@property (nonatomic, strong, nullable) NSDate *lastKnownTime;
@property (nonatomic) NSTimeInterval systemUptime;
@property (nonatomic, strong) NSString *ntpServer;
@property (nonatomic) NSTimeInterval timeThreshold;
@property (nonatomic) dispatch_queue_t networkQueue;

@end

@implementation SGTimeTamperingDetector

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeThreshold = 60; // 1 minute threshold
        _systemUptime = NSProcessInfo.processInfo.systemUptime;
        _ntpServer = @"time.apple.com";
        _networkQueue = dispatch_queue_create("com.sg.timetampering.network", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSDate *)bootTime {
    return [NSDate dateWithTimeIntervalSinceNow:-self.systemUptime];
}

- (BOOL)checkForTimeTampering {
    // Check 1: Compare current time against last known time
    if (self.lastKnownTime) {
        NSDate *currentTime = [NSDate date];
        NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:self.lastKnownTime];
        
        // Detect backwards time movement or unrealistic jumps forward
        if (timeDifference < 0 || timeDifference > self.timeThreshold) {
            return YES; // Tampering detected
        }
    }
    
    // Check 2: Compare system uptime against wall clock
    NSTimeInterval currentUptime = NSProcessInfo.processInfo.systemUptime;
    NSTimeInterval uptimeDifference = currentUptime - self.systemUptime;
    NSTimeInterval wallClockDifference = [[NSDate date] timeIntervalSinceDate:self.bootTime];
    
    if (fabs(uptimeDifference - wallClockDifference) > self.timeThreshold) {
        return YES; // Tampering detected
    }
    
    // Update reference time
    self.lastKnownTime = [NSDate date];
    self.systemUptime = currentUptime;
    
    return NO;
}

- (void)verifyTimeWithNTPCompletion:(void (^)(BOOL))completion {
    dispatch_async(self.networkQueue, ^{
        // Create UDP socket
        int sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
        if (sockfd < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }
        
        // Set timeout
        struct timeval timeout;
        timeout.tv_sec = 5;
        timeout.tv_usec = 0;
        setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        
        // Resolve NTP server address
        struct hostent *server = gethostbyname([self.ntpServer UTF8String]);
        if (server == NULL) {
            close(sockfd);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }
        
        // Prepare server address
        struct sockaddr_in serverAddr;
        memset(&serverAddr, 0, sizeof(serverAddr));
        serverAddr.sin_family = AF_INET;
        memcpy(&serverAddr.sin_addr.s_addr, server->h_addr, server->h_length);
        serverAddr.sin_port = htons(NTP_PORT);
        
        // Prepare NTP packet
        uint8_t packet[NTP_PACKET_SIZE];
        memset(packet, 0, NTP_PACKET_SIZE);
        packet[0] = 0x1B; // NTP version 3, client mode
        
        // Send packet
        if (sendto(sockfd, packet, sizeof(packet), 0,
                   (struct sockaddr *)&serverAddr, sizeof(serverAddr)) < 0) {
            close(sockfd);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }
        
        // Receive response
        uint8_t response[NTP_PACKET_SIZE];
        socklen_t serverLength = sizeof(serverAddr);
        ssize_t n = recvfrom(sockfd, response, sizeof(response), 0,
                            (struct sockaddr *)&serverAddr, &serverLength);
        
        close(sockfd);
        
        if (n < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
            return;
        }

        if (n < NTP_PACKET_SIZE) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
            return;
        }
        
        // Extract timestamp
        uint32_t ntpSeconds;
        memcpy(&ntpSeconds, &response[40], sizeof(ntpSeconds));
        ntpSeconds = ntohl(ntpSeconds);
        NSTimeInterval ntpTime = ntpSeconds - NTP_TIMESTAMP_DELTA;
        
        NSDate *serverTime = [NSDate dateWithTimeIntervalSince1970:ntpTime];
        NSDate *localTime = [NSDate date];
        NSTimeInterval difference = fabs([serverTime timeIntervalSinceDate:localTime]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(difference <= self.timeThreshold);
        });
    });
}

@end

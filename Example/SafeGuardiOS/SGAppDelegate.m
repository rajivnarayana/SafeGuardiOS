//
//  SGAppDelegate.m
//  SafeGuardiOS
//
//  Created by Rajiv Singaseni on 12/18/2024.
//  Copyright (c) 2024 Rajiv Singaseni. All rights reserved.
//

#import "SGAppDelegate.h"
#import "SGSecurityChecker.h"

@implementation SGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    SGSecurityConfiguration *configuration = [[SGSecurityConfiguration alloc] initWithDefaultConfiguration];
    configuration.expectedBundleIdentifier = @"org.cocoapods.demo.SafeGuardiOS-Example";
    configuration.expectedSignature = @"7f37de47a4a62f8a5acc958f96a77af4b700c4f5afc530f7e2cb934d3c177af8";
    configuration.signatureErrorDebug = YES;
    [SGSecurityChecker sharedInstance].configuration = configuration;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   // cleanup
    [[SGSecurityChecker sharedInstance] cleanup];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[SGSecurityChecker sharedInstance] performAllSecurityChecks];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

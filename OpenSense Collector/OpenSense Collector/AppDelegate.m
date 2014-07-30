//
//  AppDelegate.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSense.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
#ifdef SHOW_ENCRYPTION_KEY
    OSLog(@"Encryption key: %@", [[OpenSense sharedInstance] encryptionKey]);
#endif
    
    expirationHandler = ^{
        [application endBackgroundTask:bgTask];
        
        bgTask = UIBackgroundTaskInvalid;
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:expirationHandler];
    };
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[OpenSense sharedInstance] isRunning])
    {
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:expirationHandler];
        
        // Start the worker task
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (true)
            {
                [NSThread sleepForTimeInterval:10.0f]; // Free up the CPU
            }
        });
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application endBackgroundTask:bgTask];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

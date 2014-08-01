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
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
#ifdef SHOW_ENCRYPTION_KEY
    OSLog(@"Encryption key: %@", [[OpenSense sharedInstance] encryptionKey]);
#endif
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}


- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    OSLog(@"application performFetchWithCompletionHandler entered");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"/log.txt"];
    NSFileHandle *f = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [f seekToEndOfFile];
    NSString *message = [NSString stringWithFormat:@"performFetch ran at time %f\n",[[NSDate date] timeIntervalSince1970]];
    [f writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [f closeFile];
    
    // only start the collector if it was running when the user exited
    if (openSenseRunningWhenEnteredBackground) {
        [[OpenSense sharedInstance] startCollector];
        [NSTimer scheduledTimerWithTimeInterval:20 target:[OpenSense sharedInstance] selector:@selector(stopCollectorAndUploadData) userInfo:nil repeats:NO];
    }
    completionHandler(UIBackgroundFetchResultNoData);
}

//- (void)applicationWillResignActive:(UIApplication *)application
//{
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//}
//

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    if ([[OpenSense sharedInstance] isRunning]){
        openSenseRunningWhenEnteredBackground = YES;
    } else {
        openSenseRunningWhenEnteredBackground = NO;
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application endBackgroundTask:bgTask];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (openSenseRunningWhenEnteredBackground){
        [[OpenSense sharedInstance] startCollector];
    } else {
        [[OpenSense sharedInstance] stopCollector];
    }
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // will give ~5 sec notice
    
    openSenseRunningWhenEnteredBackground = [[OpenSense sharedInstance] isRunning]
    [[OpenSense sharedInstance] stopCollector];
}

@end











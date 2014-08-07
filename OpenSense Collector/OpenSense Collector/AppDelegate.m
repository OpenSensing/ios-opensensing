//
//  AppDelegate.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSense.h"

@implementation AppDelegate {
     NSUserDefaults *defaults;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    #ifdef SHOW_ENCRYPTION_KEY
        OSLog(@"Encryption key: %@", [[OpenSense sharedInstance] encryptionKey]);
    #endif
    
    // configure app on first launch
    defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"OSHasLaunchedOnce"]) {
        [defaults setBool:YES forKey:@"OSHasLaunchedOnce"];
        [defaults setBool:NO  forKey:@"OSCollecting"];
        [defaults synchronize];
    }
    [defaults boolForKey:@"OSCollecting"];
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    OSLog(@"application performFetchWithCompletionHandler entered");
   
    // only start the collector if it was running when the user exited
    if ([defaults boolForKey:@"OSCollecting"]) {
        
        [[OpenSense sharedInstance] startCollector];
        [NSTimer scheduledTimerWithTimeInterval:15 target:[OpenSense sharedInstance] selector:@selector(stopCollectorAndUploadData) userInfo:nil repeats:NO];
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        NSDate *now = [NSDate date];
        localNotification.fireDate = now;
        localNotification.alertBody = @"performFetchWithCompletionHandler called. startCollector called";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    OSLog(@"applicationDidEnterBackground");
   
    
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
        [application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
        background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
        
        //System will be shutting down the app at any point in time now
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([[OpenSense sharedInstance] isRunning]){
            [defaults setBool:YES forKey:@"OSCollecting"];
            [[OpenSense sharedInstance] stopCollector];
        } else {
            [defaults setBool:NO forKey:@"OSCollecting"];
        }
        
        OSLog(@"\n\nRunning in the background!\n\n");
        
        [application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
        background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
    });
    
    
    
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    OSLog(@"application did become active");
    if ([defaults boolForKey:@"OSCollecting"]){
        [[OpenSense sharedInstance] startCollector];
    } else {
        [[OpenSense sharedInstance] stopCollector];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // will give ~5 sec notice
    OSLog(@"applicationWillTerminate");
    [defaults setBool:[[OpenSense sharedInstance] isRunning] forKey:@"OSCollecting"];
    [[OpenSense sharedInstance] stopCollector];
}

@end











//
//  AppDelegate.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIBackgroundTaskIdentifier bgTask;
    dispatch_block_t expirationHandler;
    BOOL openSenseRunningWhenEnteredBackground;
}

@property (strong, nonatomic) UIWindow *window;

@end

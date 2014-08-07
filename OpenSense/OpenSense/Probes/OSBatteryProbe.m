//
//  OSBatteryProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSBatteryProbe.h"

@implementation OSBatteryProbe

+ (NSString*)name
{
    return @"Battery";
}

+ (NSString*)identifier
{
    return @"battery";
}

+ (NSString*)description
{
    return @"Monitors the charge state and battery level of the device";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    // Only listen to updates if we are not saving data with an interval
    if ([self updateInterval] == kUpdateIntervalPush)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }
    
    [super startProbe];
}

- (void)stopProbe
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    
    // Only listen to updates if we are not saving data with an interval
    if ([self updateInterval] == kUpdateIntervalPush)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [super stopProbe];
}

- (void)batteryChanged:(NSNotification*)notification
{
    // Take new data snapshot
    [self saveData];
}

- (NSDictionary*)sendData
{
    NSNumber *batteryLevel = [NSNumber numberWithFloat:[[UIDevice currentDevice] batteryLevel] * 100.0f];
    
    NSString *batteryState;
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateFull:
            batteryState = @"full";
            break;
        
        case UIDeviceBatteryStateCharging:
            batteryState = @"charging";
            break;
            
        case UIDeviceBatteryStateUnplugged:
            batteryState = @"unplugged";
            break;
            
        default:
        case UIDeviceBatteryStateUnknown:
            batteryState = @"unknown";
            break;
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 batteryLevel, @"level",
                                 batteryState, @"state",
                                 nil];
    
    return data;
}

@end

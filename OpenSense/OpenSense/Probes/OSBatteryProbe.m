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
    return @"dk.dtu.imm.sensible.battery";
}

+ (NSString*)description
{
    return @"Monitors the charge state and battery level of the device";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return 5;
}

- (void)startProbe
{
    NSLog(@"Battery probe started");
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    [super startProbe];
}

- (void)stopProbe
{
    NSLog(@"Battery probe stopped");
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    
    [super stopProbe];
}

- (NSDictionary*)sendData
{
    NSNumber *batteryLevel = [NSNumber numberWithFloat:[[UIDevice currentDevice] batteryLevel]];
    
    NSString *batteryState;
    switch ([[UIDevice currentDevice] batteryState]) {
        case UIDeviceBatteryStateFull:
            batteryState = @"FULL";
            break;
        
        case UIDeviceBatteryStateCharging:
            batteryState = @"CHARGING";
            break;
            
        case UIDeviceBatteryStateUnplugged:
            batteryState = @"UNPLUGGED";
            break;
            
        default:
        case UIDeviceBatteryStateUnknown:
            batteryState = @"UNKNOWN";
            break;
    }
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 batteryLevel, @"BATTERY_LEVEL",
                                 batteryState, @"BATTERY_STATE",
                                 nil];
    
    return data;
}

@end

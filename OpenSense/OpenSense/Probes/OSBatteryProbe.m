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
    return -1;
}

- (void)startProbe
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
    [super startProbe];
}

- (void)stopProbe
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super stopProbe];
}

- (void)batteryChanged:(NSNotification*)notification
{
    // Take new data snapshot
    [self saveData];
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

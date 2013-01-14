//
//  OSProximityProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSProximityProbe.h"

@implementation OSProximityProbe

+ (NSString*)name
{
    return @"Proximity";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.proximity";
}

+ (NSString*)description
{
    return @"Monitors when the user has the device close to his/her face.";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalDisabled;
}

- (void)startProbe
{
    // Only listen to updates if we are not saving data with an interval
    if ([self updateInterval] == kUpdateIntervalDisabled)
    {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateChanged:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    
    [super startProbe];
}

- (void)stopProbe
{
    // Only listen to updates if we are not saving data with an interval
    if ([self updateInterval] == kUpdateIntervalDisabled)
    {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [super stopProbe];
}

- (void)proximityStateChanged:(NSNotification*)notification
{
    // Take new data snapshot
    [self saveData];
}

- (NSDictionary*)sendData
{
    NSNumber *proximityState = [NSNumber numberWithBool:[[UIDevice currentDevice] proximityState]];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 proximityState, @"PROXIMITY_STATE",
                                 nil];
    
    return data;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

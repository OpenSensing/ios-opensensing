//
//  OpenSense.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OpenSense.h"
#import "OSLocalStorage.h"
#import "OSPositioningProbe.h"
#import "OSMotionProbe.h"
#import "OSEnvironmentProbe.h"
#import "OSSocialProbe.h"
#import "OSDeviceInfoProbe.h"
#import "OSDeviceInteractionProbe.h"
#import "OSBatteryProbe.h"
#import "OSProximityProbe.h"

@implementation OpenSense

@synthesize isRunning;

+ (OpenSense*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)startCollector
{
    activeProbes = [[NSMutableArray alloc] init];
    for (Class class in [self availableProbes])
    {
        OSProbe *probe = [[class alloc] init];
        [activeProbes addObject:probe];
        [probe startProbe];
    }
    
    isRunning = YES;
}

- (void)stopCollector
{
    for (OSProbe *probe in activeProbes)
    {
        [probe stopProbe];
    }
    activeProbes = nil;
    
    isRunning = NO;
}

- (NSArray*)availableProbes
{
    return @[
        [OSPositioningProbe class],
        [OSMotionProbe class],
        [OSEnvironmentProbe class],
        [OSSocialProbe class],
        [OSDeviceInfoProbe class],
        [OSDeviceInteractionProbe class],
        [OSBatteryProbe class],
        [OSProximityProbe class],
    ];
}

- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier
{
    for (Class probe in [self availableProbes])
    {
        if ([[probe identifier] isEqualToString:probeIdentifier])
        {
            return [probe name];
        }
    }
    
    return nil;
}

- (NSArray*)localDataBatches
{
    return [[OSLocalStorage sharedInstance] fetchBatches];
}

- (NSArray*)localDataBatchesForProbe:(NSString*)probeIdentifier
{
    return [[OSLocalStorage sharedInstance] fetchBatchesForProbe:probeIdentifier];
}

@end

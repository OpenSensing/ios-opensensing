//
//  OpenSense.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OpenSense.h"
#import "OSPositioningProbe.h"
#import "OSMotionProbe.h"
#import "OSEnvironmentProbe.h"
#import "OSSocialProbe.h"
#import "OSDeviceInfoProbe.h"
#import "OSDeviceInteractionProbe.h"

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
    isRunning = YES;
}

- (void)stopCollector
{
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
        [OSDeviceInteractionProbe class]
    ];
}

@end

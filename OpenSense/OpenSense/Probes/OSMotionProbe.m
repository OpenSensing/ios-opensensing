//
//  OSMotionProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSMotionProbe.h"

#define kMotionUpdateInterval (double)1/50  // 50Hz
#define kMotionSampleFrequency (double) 900.0 // seconds
#define kMotionSampleDuration (double) 30.0   //seconds

@implementation OSMotionProbe

+ (NSString*)name
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSString*)identifier
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSString*)description
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    // Initialize motion manager and queue
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = kMotionUpdateInterval;
    operationQueue = [[NSOperationQueue alloc] init];
    
    [super startProbe];
}

- (void)stopProbe
{
    // Stop receving updates and release objects
    [motionManager stopAccelerometerUpdates];
    motionManager = nil;
    operationQueue = nil;
    
    [super stopProbe];
}

@end

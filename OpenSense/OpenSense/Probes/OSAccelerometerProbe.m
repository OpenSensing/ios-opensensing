//
//  OSAccelerometerProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSAccelerometerProbe.h"

@implementation OSAccelerometerProbe

+ (NSString*)name
{
    return @"Accelerometer";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.accelerometer";
}

+ (NSString*)description
{
    return @"Collects acceleration data from the built-in accelerometer";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return [super defaultUpdateInterval];
}

- (void)startProbe
{
    [super startProbe];
    NSLog(@"Accelerometer startProbe called");
    
    // call startSample every sampleFrequency seconds
    NSTimeInterval sampleFrequency = [self sampleFrequency];
    sampleFrequencyTimer = [NSTimer scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(startSample) userInfo:nil repeats:YES];
    
}

- (void)stopProbe
{ 
    [super stopProbe];
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
}



- (NSDictionary*)sendData
{
    if (!lastData)
        return nil;
    
    CMAccelerometerData *accData = (CMAccelerometerData*)lastData;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:accData.acceleration.x], @"x",
                                 [NSNumber numberWithDouble:accData.acceleration.y], @"y",
                                 [NSNumber numberWithDouble:accData.acceleration.z], @"z",
                                 nil];
    
    return data;
}

- (void) startSample
{
    NSLog(@"Accelerometer startSample Called");
    [motionManager startAccelerometerUpdatesToQueue:operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        lastData = accelerometerData;
        [self saveData];
    }];
    
//    after a period of time stop the motion Manager
    NSTimeInterval sampleDuration = [self sampleDuration];
    [NSTimer scheduledTimerWithTimeInterval:sampleDuration target:self selector:@selector(stopSample) userInfo:nil repeats:NO];
    
    
    
}

- (void) stopSample
{
    NSLog(@"Accelerometer stopSample Called");
    [motionManager stopAccelerometerUpdates];
}

@end

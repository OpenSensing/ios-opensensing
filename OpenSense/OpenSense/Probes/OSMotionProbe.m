//
//  OSMotionProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSMotionProbe.h"


#define kMotionUpdateInterval (double) .5  // originally 1/50 50Hz
#define kMotionSampleFrequency (double) 1800.0 // seconds between samples. This really should only matter if the app is kept on indefinitely
#define kMotionSampleDuration (double) 5.0   // probes record data for this many seconds

@implementation OSMotionProbe{
    CMMotionManager *motionManager;
    NSTimer *sampleFrequencyTimer;
    NSTimer *sampleDurationTimer;
}

+ (NSString*)name
{
    return @"Motion";
    return nil;
}

+ (NSString*)identifier
{
    return @"motion";
}

+ (NSString*)description
{
    return @"Collects gyroscope, acceleration, magnometer data from the device";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    if(kMotionSampleFrequency - kMotionSampleDuration < 0){
        [NSException raise:@"Your OSMotionProbe frequency/duration are incorrect" format:@"Check to make sure your greater tha is less than your kMotionSampleDuration"];
    }

    
    // Initialize motion manager and queue
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = kMotionUpdateInterval;
    operationQueue = [[NSOperationQueue alloc] init];
    
    // Start generating and sampling data

    [self startSample];  // Spawn new thread to avoid sampleFrequency delay
    NSTimeInterval sampleFrequency = [self sampleFrequency];
    sampleFrequencyTimer = [NSTimer scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(startSample) userInfo:nil repeats:YES];

    
    [super startProbe];
}

- (void)stopProbe
{
    // Invalidate and clear timers
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    if (sampleDurationTimer){
        [sampleDurationTimer invalidate];
        sampleDurationTimer = nil;
    }

    
    // Stop receving updates and release objects
    [motionManager stopDeviceMotionUpdates];
        
    motionManager = nil;
    operationQueue = nil;
    
    [super stopProbe];
}

- (NSDictionary *) sendData
{
    if (!lastData){
        return nil;
    }
    
    NSNumber *attitude_roll     = [NSNumber numberWithDouble:lastData.attitude.roll];
    NSNumber *attitude_pitch    = [NSNumber numberWithDouble:lastData.attitude.pitch];
    NSNumber *attitude_yaw      = [NSNumber numberWithDouble:lastData.attitude.yaw];
    
    NSNumber *rotationRate_x    = [NSNumber numberWithDouble:lastData.rotationRate.x];
    NSNumber *rotationRate_y    = [NSNumber numberWithDouble:lastData.rotationRate.y];
    NSNumber *rotationRate_z    = [NSNumber numberWithDouble:lastData.rotationRate.z];
    
    NSNumber *gravity_x         = [NSNumber numberWithDouble:lastData.gravity.x];
    NSNumber *gravity_y         = [NSNumber numberWithDouble:lastData.gravity.y];
    NSNumber *gravity_z         = [NSNumber numberWithDouble:lastData.gravity.z];
    
    NSNumber *userAcceleration_x= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    NSNumber *userAcceleration_y= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    NSNumber *userAcceleration_z= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    
    
    NSDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 attitude_roll, @"attitude_x",
                                 attitude_pitch, @"attitude_pitch",
                                 attitude_yaw, @"attitude_yaw",
                                 
                                 rotationRate_x, @"rotationRate_x",
                                 rotationRate_y, @"rotationRate_y",
                                 rotationRate_z, @"rotationRate_z",
                                 
                                 gravity_x, @"gravity_x",
                                 gravity_y, @"gravity_y",
                                 gravity_z, @"gravity_z",
                                 
                                 userAcceleration_x, @"userAcceleration_x",
                                 userAcceleration_y, @"userAcceleration_y",
                                 userAcceleration_z, @"userAcceleration_z",
                                 
                                 nil];
    
    return data;
}

# pragma mark - sample start/stop

- (void) startSample
{
    
    [motionManager startDeviceMotionUpdatesToQueue:operationQueue withHandler:^(CMDeviceMotion *motionData, NSError *error) {
        lastData = motionData;
        
        [self saveData];
    }];
    
    // after a period of time stop the motion Manager
    NSTimeInterval sampleDuration = [self sampleDuration];
    sampleDurationTimer = [NSTimer scheduledTimerWithTimeInterval:sampleDuration target:self selector:@selector(stopSample) userInfo:nil repeats:NO];
    
}

- (void) stopSample
{
    [motionManager stopDeviceMotionUpdates];
}

- (NSTimeInterval) sampleFrequency
{
    return kMotionSampleFrequency;
}

- (NSTimeInterval) sampleDuration
{
    return kMotionSampleDuration;
}


@end

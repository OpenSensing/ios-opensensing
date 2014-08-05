//
//  OSActivityManagerProbe.m
//  OpenSense
//
//  Created by Albert Carter on 8/1/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "OSActivityManagerProbe.h"

#define kActivitySampleFrequency (double) 5.0;
@implementation OSActivityManagerProbe

+ (NSString*)name
{
    return @"Activity manager";
}

+ (NSString *) identifier
{
    return @"dk.dtu.imm.sensible.activitymanager";
}

+ (NSTimeInterval) defaultUpdateInterval
{
    return 1;
}

- (void) startProbe
{
    // make sure that MotionActivity is supported.
    if ([CMMotionActivityManager isActivityAvailable]) {
    
        [self saveData];
        NSTimeInterval sampleFrequency = [self sampleFrequency];
        sampleFrequencyTimer = [NSTimer
                               scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(saveData) userInfo:nil repeats:YES];
        
        [super startProbe];
    } else {
        nil;
    };
}

- (void) stopProbe
{
    [super stopProbe];
}

- (void) saveData
{
    // override superclass, because save data is irrelevent if activity isn't avaialble in device
    if ([CMMotionActivityManager isActivityAvailable]){
    [super saveData];
    }
}

- (NSDictionary *) sendData
{
    // testing date stamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/yyyy hh:mm"];
    NSDate *now = [NSDate date];
    OSLog(@"Activity Monitor Sample Started at %@", [formatter stringFromDate:now]);
    
    // check activity
    CMMotionActivity *activity = [[CMMotionActivity init] alloc];
    NSString *activityString = [[NSString alloc] init];
    NSNumber *confidence = [NSNumber numberWithInteger:activity.confidence];
    
    if (activity.running) {
        activityString = @"running";
    } else if (activity.walking){
        activityString = @"walking";
    } else if (activity.automotive){
        activityString = @"automotive";
    } else if (activity.stationary){
        activityString = @"stationary";
    } else {
        activityString = @"unknown";
    };
    
    // when the activity started
    NSDate *startDate = activity.startDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startDateString = [dateFormatter stringFromDate:startDate];
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                activityString,@"activity",
                startDateString, @"activityStarted",
                confidence, @"confidence",
                nil];
    
    return data;
}


- (NSTimeInterval) sampleFrequency{
    return kActivitySampleFrequency;
}



@end

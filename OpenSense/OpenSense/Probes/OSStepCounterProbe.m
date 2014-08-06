//
//  OSStepCounter.m
//  OpenSense
//
//  Created by Albert Carter on 8/5/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <CoreMotion/CMStepCounter.h>
#import "OSStepCounterProbe.h"

#define kActivitySampleFrequency (double) 60.0;
@implementation OSStepCounterProbe{
    NSTimer *sampleFrequencyTimer;
}

- (id) init{
    self = [super init];
    
    if (self) {
        self.lastStepCountSample = [NSDate date];
        stepQueue = [[NSOperationQueue alloc] init];
        stepQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

+ (NSString *)name
{
    return @"Step counter";
}

+ (NSString *) identifier
{
    return @"stepcounter";
}

+ (NSTimeInterval) defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void) startProbe
{
    if ([CMStepCounter isStepCountingAvailable]){
        [super startProbe];
        [self saveData];
        NSTimeInterval sampleFrequency = [self sampleFrequency];
        sampleFrequencyTimer = [NSTimer
                                scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(saveData) userInfo:nil repeats:YES];
    } else{
        nil;
    }
}

- (void) stopProbe
{
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    [super stopProbe];
}

- (void) saveData
{
    if ([CMStepCounter isStepCountingAvailable]){
        [super saveData];
    }
}

- (NSDictionary *) sendData
{
    // testing date stamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/yyyy hh:mm:ss"];
    NSDate *now = [NSDate date];
    OSLog(@"Activity Monitor Sample Started at %@", [formatter stringFromDate:now]);

    CMStepCounter *stepCounter = [[CMStepCounter alloc] init];
    __block NSNumber *stepCount = [[NSNumber alloc] init];
    
    [stepCounter queryStepCountStartingFrom:self.lastStepCountSample to:[NSDate date] toQueue:stepQueue withHandler:^(NSInteger numberOfSteps, NSError *error) {
        if (error){
            OSLog(@"%@", [error localizedDescription]);
            stepCount = @-1;
        } else {
            stepCount = [NSNumber numberWithInteger:numberOfSteps];
        }
    }];
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.lastStepCountSample, @"lastStepCountDate",
                          now, @"currentStepCountDate",
                          stepCount, @"numSteps",
                          nil];
    
    return data;
}

- (NSTimeInterval) sampleFrequency {
    return kActivitySampleFrequency;
}

@end

//
//  OSStepCounter.m
//  OpenSense
//
//  Created by Albert Carter on 8/5/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <CoreMotion/CMStepCounter.h>
#import "OSStepCounter.h"

#define kActivitySampleFrequency (double) 60.0;
@implementation OSStepCounter

- (id) init{
    self = [super init];
    
    if (self) {
        self.lastStepCountSample = [[NSDate alloc] init];
    }
    
    return self;
}

+ (NSString *)name
{
    return @"Step counter";
}

+ (NSString *) identifier
{
    return @"dk.dtu.imm.sensible.stepcounter";
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
    
//    [stepCounter queryStepCountStartingFrom:self.lastStepCountSample to:[[NSDate alloc] init] toQueue:<#(NSOperationQueue *)#> withHandler:<#^(NSInteger numberOfSteps, NSError *error)handler#>]
    
}

- (NSTimeInterval) sampleFrequency {
    return kActivitySampleFrequency;
}

@end

//
//  OSActivityManagerProbe.m
//  OpenSense
//
//  Created by Albert Carter on 8/1/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "OSActivityManagerProbe.h"

@implementation OSActivityManagerProbe{
    NSTimer *sampleFrequencyTimer;
    double sampleFrequency;
    NSOperationQueue *activityQueue;
}

- (id) init{
    self = [super init];
    
    if (self){
        
        // register this as the first step count sample
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate date] forKey:@"lastActivitySample"];
        
        activityQueue = [[NSOperationQueue alloc] init];
        activityQueue.maxConcurrentOperationCount = 1;
        
        // get probe info from config.json
        NSDictionary *configDict = [[OSConfiguration currentConfig] activityConfig];
        sampleFrequency = [[configDict objectForKey:@"frequency"] doubleValue]; // seconds between when the probe is started
    }
    
    return self;
}

+ (NSString*)name
{
    return @"Activity manager";
}

+ (NSString *) identifier
{
    return @"activitymanager";
}

+ (NSTimeInterval) defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void) startProbe
{
    // ensure that MotionActivity is supported
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable]) {

        [super startProbe];
        [self saveData];
        sampleFrequencyTimer = [NSTimer
                               scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(saveData) userInfo:nil repeats:YES];
        
        
    } else {
        nil;
    };
}

- (void) stopProbe
{
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    
    [super stopProbe];
}
#pragma mark - frequency related methods

- (void) saveData
{
    // override superclass, because save data is irrelevent if activity isn't avaialble in device
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable]){
    [super saveData];
    }
}


- (NSDictionary *) sendData
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSampleDate = [defaults objectForKey:@"lastActivitySample"];
    NSDate *now = [NSDate date];
    
    CMMotionActivityManager *cm = [[CMMotionActivityManager alloc] init];
    CMStepCounter *sc = [[CMStepCounter alloc] init];
    
    // declare some variables accessible outside of the block
    __block NSDictionary *point = [NSDictionary alloc];
    __block NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    
    [cm queryActivityStartingFromDate:lastSampleDate toDate:now toQueue:activityQueue withHandler:^(NSArray *activities, NSError *error){
        
        // for each returned activity
        for(int i=0;i<[activities count]-1;i++) {
            CMMotionActivity *a = [activities objectAtIndex:i];
            
            NSDate *startDate = a.startDate;
            NSDate *endDate = [[activities objectAtIndex:i+1] startDate];
            
            NSString *activityString = @"unknown";
            if (a.running) activityString = @"running";
            else if (a.walking) activityString = @"walking";
            else if (a.automotive) activityString = @"automotive";
            else if (a.stationary) activityString = @"stationary";
            
            NSString *confidenceString = @"low";
            if (a.confidence == CMMotionActivityConfidenceMedium) confidenceString = @"medium";
            else if (a.confidence == CMMotionActivityConfidenceHigh) confidenceString = @"high";
        
            // find stepCounts for that activity
            [sc queryStepCountStartingFrom:startDate to:endDate toQueue:activityQueue withHandler:^(NSInteger numberOfSteps, NSError *error) {
                NSNumber *steps = [[NSNumber alloc] initWithInteger:numberOfSteps];
                point = [point initWithObjectsAndKeys:
                                       activityString, @"activity",
                                       confidenceString, @"confidence",
                                       steps, @"steps",
                                       startDate, @"startDate",
                                       endDate, @"endDate",
                                       nil];
                [arr addObject:point];
            }];
        
            [data setObject:arr forKey:@"activityLog"];
        }
    }];
    
    return data;
}



@end

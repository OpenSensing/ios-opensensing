//
//  OSProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"

@implementation OSProbe

@synthesize isStarted;

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
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return -1;
}

- (void)startProbe
{
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:[self updateInterval] target:self selector:@selector(updateTimerElapsed:) userInfo:nil repeats:YES];
}

- (void)stopProbe
{
    if (updateTimer)
    {
        [updateTimer invalidate];
    }
}

- (void)updateTimerElapsed:(id)sender
{
    NSDictionary *data = [self sendData];
    NSLog(@"%@", data);
    
    // TODO: Save to local storage
}

- (NSDictionary*)sendData
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

- (NSTimeInterval)updateInterval
{
    // TODO: Load from config as primary source
    NSTimeInterval interval = [[self class] defaultUpdateInterval];
    return interval;
}

@end

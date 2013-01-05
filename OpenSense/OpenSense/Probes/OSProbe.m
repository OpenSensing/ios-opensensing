//
//  OSProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"
#import "LocalStorage.h"

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
    NSLog(@"%@ started", [[self class] name]);
    
    NSTimeInterval timerUpdateInterval = [self updateInterval];
    
    if (timerUpdateInterval > 0)
    {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:timerUpdateInterval target:self selector:@selector(saveData) userInfo:nil repeats:YES];
    }
    else
    {
        updateTimer = nil; // The probe is pushing data instead
    }
}

- (void)stopProbe
{
    NSLog(@"%@ stopped", [[self class] name]);
    
    if (updateTimer)
    {
        [updateTimer invalidate];
    }
}

- (void)saveData
{
    // Receive data from the probe
    NSDictionary *data = [self sendData];
    
    // Store data in the local storage
    [[LocalStorage sharedInstance] saveBatch:data fromProbe:[[self class] identifier]];
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

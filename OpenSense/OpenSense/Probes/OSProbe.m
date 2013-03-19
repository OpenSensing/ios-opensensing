//
//  OSProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"
#import "OSLocalStorage.h"
#import "OSConfiguration.h"

@implementation OSProbe

@synthesize isStarted;

- (id)init
{
    if (self = [super init]) {
        NSString *instanceClassName = NSStringFromClass([self class]);
        NSAssert((![instanceClassName isEqualToString:@"OSProbe"]), @"This is an abstract class and should never be instantiated directly");
    }
    
    return self;
}

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
    NSTimeInterval timerUpdateInterval = [self updateInterval];
    
    OSLog(@"%@ started with %f update interval", [[self class] name], timerUpdateInterval);
    
    if (timerUpdateInterval != kUpdateIntervalDisabled)
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
    OSLog(@"%@ stopped", [[self class] name]);
    
    if (updateTimer)
    {
        [updateTimer invalidate];
        updateTimer = nil;
    }
}

- (void)saveData
{
    // Receive data from the probe
    NSDictionary *data = [self sendData];
    
    if (data)
    {
        // Store data in the local storage
        [[OSLocalStorage sharedInstance] saveBatch:data fromProbe:[[self class] identifier]];
    }
}

- (NSDictionary*)sendData
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

- (NSTimeInterval)updateInterval
{    
    // Get update interval from config
    NSTimeInterval configInterval = [[OSConfiguration currentConfig] updateIntervalForProbe:[[self class] identifier]];
    
    // If config did not provide an update interval, use the default probe interval instead
    if (configInterval < 0)
    {
        [[self class] defaultUpdateInterval];
    }
    
    return configInterval;
}

@end

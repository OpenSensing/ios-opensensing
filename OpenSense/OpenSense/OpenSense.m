//
//  OpenSense.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OpenSense.h"

@implementation OpenSense

@synthesize isRunning;

+ (OpenSense*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)startCollector
{
    isRunning = YES;
}

- (void)stopCollector
{
    isRunning = NO;
}

- (NSArray*)availableProbes
{
    NSMutableArray *probes = [[NSMutableArray alloc] init];
    NSArray *probeDescriptions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"probes" ofType:@"plist"]];
    
    for (NSDictionary *probeInfo in probeDescriptions)
    {
        OSProbe *probe = [[NSClassFromString([probeInfo objectForKey:@"Class"]) alloc] init];
        probe.name = [probeInfo objectForKey:@"Name"];
        probe.identifier = [probeInfo objectForKey:@"Identifier"];
        probe.description = [probeInfo objectForKey:@"Description"];
        
        [probes addObject:probe];
    }
    
    return probes;
}

@end

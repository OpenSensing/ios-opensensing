//
//  OSStepCounter.m
//  OpenSense
//
//  Created by Albert Carter on 8/5/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import "OSStepCounter.h"

#define kActivitySampleFrequency (double) 5.0;
@implementation OSStepCounter

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
    return 1;
}

- (void) startProbe
{
    
}

- (void) stopProbe
{
    
}

- (void) saveData
{
    
}

- (NSDictionary *) sendData
{
    
}

- (NSTimeInterval) sampleFrequency {
    return kActivitySampleFrequency;
}


@end

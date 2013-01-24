//
//  OSGyroProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSGyroProbe.h"

@implementation OSGyroProbe

+ (NSString*)name
{
    return @"Gyro";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.gyro";
}

+ (NSString*)description
{
    return @"Collects gyroscope data from the built-in gyro";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return [super defaultUpdateInterval];
}

- (void)startProbe
{
    [super startProbe];
    
    // Start receiving updates
    [motionManager startGyroUpdatesToQueue:operationQueue withHandler:^(CMGyroData *gyroData, NSError *error) {
        lastData = gyroData;
        [self saveData];
    }];
}

- (void)stopProbe
{
    [super stopProbe];
}

- (NSDictionary*)sendData
{
    if (!lastData)
        return nil;
    
    CMGyroData *gyroData = (CMGyroData*)lastData;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:gyroData.rotationRate.x], @"x",
                                 [NSNumber numberWithDouble:gyroData.rotationRate.y], @"y",
                                 [NSNumber numberWithDouble:gyroData.rotationRate.z], @"z",
                                 nil];
    
    return data;
}

@end

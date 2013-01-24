//
//  OSMagnetometerProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSMagnetometerProbe.h"

@implementation OSMagnetometerProbe

+ (NSString*)name
{
    return @"Magnetometer";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.magnetometer";
}

+ (NSString*)description
{
    return @"Collects compass data from the built-in magnetometer";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return [super defaultUpdateInterval];
}

- (void)startProbe
{
    [super startProbe];
    
    // Start receiving updates
    [motionManager startMagnetometerUpdatesToQueue:operationQueue withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
        lastData = magnetometerData;
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
    
    CMMagnetometerData *magData = (CMMagnetometerData*)lastData;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:magData.magneticField.x], @"x",
                                 [NSNumber numberWithDouble:magData.magneticField.y], @"y",
                                 [NSNumber numberWithDouble:magData.magneticField.z], @"z",
                                 nil];
    
    return data;
}

@end

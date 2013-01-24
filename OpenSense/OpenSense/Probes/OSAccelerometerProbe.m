//
//  OSAccelerometerProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSAccelerometerProbe.h"

@implementation OSAccelerometerProbe

+ (NSString*)name
{
    return @"Accelerometer";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.accelerometer";
}

+ (NSString*)description
{
    return @"Collects acceleration data from the built-in accelerometer";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return -1;
}

- (void)startProbe
{
    [super startProbe];
    
    // Start receiving updates
    [motionManager startAccelerometerUpdatesToQueue:operationQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        lastData = accelerometerData;
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
    
    CMAccelerometerData *accData = (CMAccelerometerData*)lastData;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:accData.acceleration.x], @"x",
                                 [NSNumber numberWithDouble:accData.acceleration.y], @"y",
                                 [NSNumber numberWithDouble:accData.acceleration.z], @"z",
                                 nil];
    
    return data;
}

@end

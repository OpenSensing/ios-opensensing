//
//  OSDeviceInteractionProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSDeviceInteractionProbe.h"

@implementation OSDeviceInteractionProbe

+ (NSString*)name
{
    return @"Device interaction";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.deviceinteraction";
}

+ (NSString*)description
{
    return @"";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return 10;
}

- (void)startProbe
{
    
}

- (void)stopProbe
{
    
}

- (NSDictionary*)sendData
{
    return [NSDictionary dictionary];
}

@end

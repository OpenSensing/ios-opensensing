//
//  OSEnvironmentProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSEnvironmentProbe.h"

@implementation OSEnvironmentProbe

+ (NSString*)name
{
    return @"Environment";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.environment";
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

//
//  OSPositioningProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSPositioningProbe.h"

@implementation OSPositioningProbe

+ (NSString*)name
{
    return @"Positioning";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.positioning";
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

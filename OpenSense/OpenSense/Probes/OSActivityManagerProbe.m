//
//  OSActivityManagerProbe.m
//  OpenSense
//
//  Created by Albert Carter on 8/1/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import "OSActivityManagerProbe.h"

@implementation OSActivityManagerProbe

+ (NSString*)name
{
    return @"Activity manager";
}

+ (NSString *) identifier
{
    return @"dk.dtu.imm.sensible.deviceinfo";
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

- (NSDictionary *) sendData
{
    
}

@end

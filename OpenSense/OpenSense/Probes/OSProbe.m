//
//  OSProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"

@implementation OSProbe

@synthesize delegate;

+ (NSString*)name
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return @"";
}

+ (NSString*)identifier
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return @"";
}

+ (NSString*)description
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return @"";
}

@end

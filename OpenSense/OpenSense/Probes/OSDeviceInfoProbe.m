//
//  OSDeviceInfoProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSDeviceInfoProbe.h"

@implementation OSDeviceInfoProbe

+ (NSString*)name
{
    return @"Device info";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.deviceinfo";
}

+ (NSString*)description
{
    return @"";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return 1;
}

- (void)startProbe
{
    
}

- (void)stopProbe
{
    
}

- (NSDictionary*)sendData
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *model = [currentDevice model];
    NSString *systemVersion = [currentDevice systemVersion];
    
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 model, @"device_model",
                                 systemVersion, @"system_version",
                                 language, @"language",
                                 locale, @"locale",
                                 country, @"country",
                                 nil];
    
    return data;
}

@end

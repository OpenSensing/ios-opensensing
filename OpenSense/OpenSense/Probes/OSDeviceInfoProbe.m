//
//  OSDeviceInfoProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSDeviceInfoProbe.h"

#define kDeviceSampleFrequency (double) 5.0; //how often a sample is taken
@implementation OSDeviceInfoProbe{
    NSTimer *sampleFrequencyTimer;
}

+ (NSString*)name
{
    return @"Device info";
}

+ (NSString*)identifier
{
    return @"deviceinfo";
}

+ (NSString*)description
{
    return @"device info";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    [super startProbe];
    [self saveData];
    
    NSTimeInterval sampleFrequency = [self sampleFrequency];
    sampleFrequencyTimer = [NSTimer
                            scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(saveData) userInfo:nil repeats:YES];}

- (void)stopProbe
{
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    
    [super stopProbe];
}

- (void) saveData
{
    [super saveData];
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
    
    float bright = [UIScreen mainScreen].brightness;
    NSNumber *brightness = [NSNumber numberWithFloat:bright];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 model, @"device_model",
                                 systemVersion, @"system_version",
                                 language, @"language",
                                 country, @"country",
                                 brightness, @"brightness",
                                nil];
    
    return data;
}

- (NSTimeInterval) sampleFrequency{
    return kDeviceSampleFrequency;
}

@end

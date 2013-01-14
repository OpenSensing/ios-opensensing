//
//  OSConfiguration.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/14/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSConfiguration.h"

#define kDefaultVersion                 0
#define kDefaultDataArchivePeriod       3 * 60 * 60 // 3 hours
#define kDefaultDataUploadPeriod        6 * 60 * 60 // 6 hours
#define kDefaultConfigUpdatePeriod      1 * 60 * 60 // 1 hour
#define kDefaultDataUploadOnWifiOnly    NO

@implementation OSConfiguration

- (id)init
{
    self = [super init];
    if (self)
    {
        [self loadConfig];
    }
    
    return self;
}

+ (OSConfiguration*)currentConfig
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)loadConfig
{
    // First, try to load config file from the documents directory
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"config.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Try to load local json config file instead
        filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data)
    {
        // Parse json as dictionary
        config = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
}

- (void)refreshConfig
{
    // Try to download json config file
    NSURL *url = [NSURL URLWithString:[self configUpdateUrl]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data)
    {
        // Save local copy to documents directory
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"config.json"];
        [data writeToFile:filePath atomically:YES];
        
        // Parse json as dictionary
        config = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
}

- (NSString*)name
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"name"];
}

- (NSNumber*)version
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"version"] ? [config objectForKey:@"version"] : [NSNumber numberWithInt:kDefaultVersion];
}

- (NSString*)configUpdateUrl
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"configUpdateUrl"];
}

- (NSNumber*)configUpdatePeriod
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"configUpdatePeriod"] ? [config objectForKey:@"configUpdatePeriod"] : [NSNumber numberWithLong:kDefaultConfigUpdatePeriod];
}

- (NSNumber*)dataArchivePeriod
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"dataArchivePeriod"] ? [config objectForKey:@"dataArchivePeriod"] : [NSNumber numberWithLong:kDefaultConfigUpdatePeriod];
}

- (NSString*)dataUploadUrl
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"dataUploadUrl"];
}

- (NSNumber*)dataUploadPeriod
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"dataUploadPeriod"] ? [config objectForKey:@"dataUploadPeriod"] : [NSNumber numberWithLong:kDefaultConfigUpdatePeriod];
}

- (NSTimeInterval)updateIntervalForProbe:(NSString*)probeId
{
    if (!config)
        return -1;
    
    // Get probe data from config
    NSArray *probeData = [[config objectForKey:@"dataRequests"] objectForKey:probeId];
    
    // Check if probe and DURATION key exists first
    if (!probeData || [probeData count] <= 0)
        return -1;
    
    NSDictionary *firstProbeData = [probeData objectAtIndex:0];
    
    if (![firstProbeData objectForKey:@"DURATION"])
        return -1;
    
    return [[firstProbeData objectForKey:@"DURATION"] doubleValue];
}

@end

//
//  OSConfiguration.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/14/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSConfiguration.h"
#import "OSProbe.h"
#import "AFNetworking.h"

#define kDefaultVersion                 0
#define kDefaultDataArchivePeriod       3 * 60 * 60 // 3 hours
#define kDefaultDataUploadPeriod        6 * 60 * 60 // 6 hours
#define kDefaultConfigUpdatePeriod      1 * 60 * 60 // 1 hour
#define kDefaultDataUploadOnWifiOnly    NO
#define kDefaultMaxDataFileSizeKb       2048 // 2mb

@implementation OSConfiguration

- (id)init
{
    self = [super init];
    if (self)
    {
        [self load];
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

- (void)load
{
    // First, try to load config file from the documents directory
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"config.json"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Try to load local json config file instead
        filePath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"json"];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        // Try to load local library json config file instead
        filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"config" ofType:@"json"];
    }
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data)
    {
        // Parse json as dictionary
        NSError *error = nil;
        config = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (!config) {
            OSLog(@"Could not parse config: %@", [error localizedDescription]);
            
            // Delete config.json in the documents directory if possible
            [[NSFileManager defaultManager] removeItemAtPath:[documentsPath stringByAppendingPathComponent:@"config.json"] error:nil];
        }
    }
}

- (void)refresh
{
    // Try to download json config file
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[OSConfiguration currentConfig].baseUrl];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"config.json"];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:@"/config" parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[OSConfiguration currentConfig] load]; // Reload the config file
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Ignore failure. Will be retried later anyways.
    }];
    
    [operation start];
}

- (NSNumber*)version
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"version"] ? [config objectForKey:@"version"] : [NSNumber numberWithInt:kDefaultVersion];
}

- (NSURL*)baseUrl
{
    if (!config)
        return nil;
    
    return [[NSURL alloc] initWithString:[config objectForKey:@"baseUrl"]];
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

- (NSNumber*)dataUploadPeriod
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"dataUploadPeriod"] ? [config objectForKey:@"dataUploadPeriod"] : [NSNumber numberWithLong:kDefaultConfigUpdatePeriod];
}

- (NSNumber*)maxDataFileSizeKb
{
    if (!config)
        return nil;
    
    return [config objectForKey:@"maxDataFileSizeKb"] ? [config objectForKey:@"maxDataFileSizeKb"] : [NSNumber numberWithLong:kDefaultMaxDataFileSizeKb];
}

- (NSTimeInterval)updateIntervalForProbe:(NSString*)probeId
{
    if (!config)
        return kUpdateIntervalUnknown;
    
    // Get probe data from config
    NSArray *probeData = [[config objectForKey:@"dataRequests"] objectForKey:probeId];
    
    // Check if probe and DURATION key exists first
    if (!probeData || [probeData count] <= 0)
        return kUpdateIntervalUnknown;
    
    NSDictionary *firstProbeData = [probeData objectAtIndex:0];
    
    if (![firstProbeData objectForKey:@"interval"])
        return kUpdateIntervalUnknown;
    
    return [[firstProbeData objectForKey:@"interval"] doubleValue];
}

- (NSArray*)enabledProbes
{
    if (!config)
        return [NSArray array];
    
    // Get probe data from config
    NSDictionary *probeData = [config objectForKey:@"dataRequests"];
    
    // Check if probe and DURATION key exists first
    if (!probeData)
        return [NSArray array];
    
    return [probeData allKeys];
}

- (NSDictionary*)motionConfig
{
    if (!config)
        return nil;
    
    NSDictionary *motion = [[config objectForKey:@"dataRequests"] objectForKey:@"motion"][0];
    
    NSNumber *frequency = [[NSNumber alloc] initWithDouble:[[motion objectForKey:@"frequency"] doubleValue]];
    NSNumber *duration = [[NSNumber alloc] initWithDouble:[[motion objectForKey:@"duration"] doubleValue]];
    NSNumber *updateInterval = [[NSNumber alloc] initWithDouble:[[motion objectForKey:@"updateInterval"] doubleValue]];
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:
                            frequency, @"frequency",
                            duration, @"duration",
                            updateInterval, @"updateInterval",
                            nil];
}

- (NSDictionary *) sampleFrequencyForProbe:(NSString *)probeId
{
    if (!config)
        return nil;
    
    NSDictionary *probe = [[config objectForKey:@"dataRequests"] objectForKey:probeId][0];
    NSNumber *frequency = [[NSNumber alloc] initWithDouble:[[probe objectForKey:@"frequency"] doubleValue]];
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            frequency, @"frequency",
            nil];
}

@end

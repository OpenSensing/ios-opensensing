//
//  OpenSense.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OpenSense.h"
#import "AFNetworking.h"
#import "UIDevice+IdentifierAddition.h"
#import "STKeychain.h"
#import "NSString+MD5Addition.h"
#import "OSLocalStorage.h"
#import "OSConfiguration.h"
#import "OSPositioningProbe.h"
#import "OSAccelerometerProbe.h"
#import "OSMagnetometerProbe.h"
#import "OSGyroProbe.h"
#import "OSDeviceInfoProbe.h"
#import "OSBatteryProbe.h"
#import "OSProximityProbe.h"

@implementation OpenSense

@synthesize isRunning;
@synthesize startTime;

+ (OpenSense*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        registrationInProgress = NO;
        
        NSError *error = nil;
        if (![STKeychain getPasswordForUsername:@"OpenSense" andServiceName:@"OpenSense" error:&error]) {
            [self registerDevice];
        }
    }
    
    return self;
}

- (void)registerDevice
{
    // Make sure that registration can not be called multiple times at once
    if (registrationInProgress) {
        return;
    }
    registrationInProgress = YES;
    
    // Make HTTP request to register the device
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[OSConfiguration currentConfig].baseUrl];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], @"device_id",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/register" parameters:params];

    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        // If a key was provided, store it in the keychain
        if ([JSON objectForKey:@"key"]) {
            
            NSError *error = nil;
            if (![STKeychain storeUsername:@"OpenSense" andPassword:[JSON objectForKey:@"key"] forServiceName:@"OpenSense" updateExisting:NO error:&error]) {
                OSLog(@"Could not store encryption key: %@", [error localizedDescription]);
            } else {            
                OSLog(@"Device registered with key: %@", [JSON objectForKey:@"key"]);
            }
        }
        
        registrationInProgress = NO;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Could not register device" message:@"The device could not be registered, please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        
        registrationInProgress = NO;
    }];
    [operation start];
}

- (BOOL)startCollector
{
    // Make sure that the collector process is not already running
    if (isRunning) {
        return NO;
    }
    
    // Make sure that the encryption key is available
    NSError *error = nil;
    if (![STKeychain getPasswordForUsername:@"OpenSense" andServiceName:@"OpenSense" error:&error]) {
        [self registerDevice];
        return NO;
    }
    
    // Update state information
    isRunning = YES;
    startTime = [NSDate date];
    
    // Start all probes
    activeProbes = [[NSMutableArray alloc] init];
    for (Class class in [self enabledProbes])
    {
        OSProbe *probe = [[class alloc] init];
        [activeProbes addObject:probe];
        [probe startProbe];
    }
    
    // Start timers
    uploadTimer = [NSTimer scheduledTimerWithTimeInterval:[[[OSConfiguration currentConfig] dataUploadPeriod] doubleValue] target:self selector:@selector(uploadData:) userInfo:nil repeats:YES];
    
    configTimer = [NSTimer scheduledTimerWithTimeInterval:[[[OSConfiguration currentConfig] configUpdatePeriod] doubleValue] target:self selector:@selector(refreshConfig:) userInfo:nil repeats:YES];
    
    // For debugging
    //[self uploadData:nil];
    
    return YES;
}

- (void)stopCollector
{
    // Only stop collector process if it is already running
    if (!isRunning) {
        return;
    }
    
    for (OSProbe *probe in activeProbes)
    {
        [probe stopProbe];
    }
    activeProbes = nil;
    
    isRunning = NO;
    
    // Stop timers
    [uploadTimer invalidate];
    uploadTimer = nil;
    
    [configTimer invalidate];
    configTimer = nil;
}

- (NSArray*)availableProbes
{
    return @[
        [OSPositioningProbe class],
        [OSAccelerometerProbe class],
        [OSMagnetometerProbe class],
        [OSGyroProbe class],
        [OSDeviceInfoProbe class],
        [OSBatteryProbe class],
        [OSProximityProbe class],
    ];
}

- (NSArray*)enabledProbes
{
    NSArray *configEnabledProbes = [[OSConfiguration currentConfig] enabledProbes];
    NSMutableArray *enabledProbesMutableList = [[NSMutableArray alloc] init];
    
    for (Class probe in [self availableProbes])
    {
        if ([configEnabledProbes containsObject:[probe identifier]])
        {
            [enabledProbesMutableList addObject:probe];
        }
    }
    
    NSArray *enabledProbesList = [[NSArray alloc] initWithArray:enabledProbesMutableList];
    return enabledProbesList;
}

- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier
{
    for (Class probe in [self availableProbes])
    {
        if ([[probe identifier] isEqualToString:probeIdentifier])
        {
            return [probe name];
        }
    }
    
    return nil;
}

- (void)localDataBatches:(void (^)(NSArray *batches))success
{
    [[OSLocalStorage sharedInstance] fetchBatches:success];
}

- (void)localDataBatchesForProbe:(NSString*)probeIdentifier success:(void (^)(NSArray *batches))success
{
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:probeIdentifier skipCurrent:NO parseJSON:YES success:success];
}

- (NSString*)encryptionKey
{
    return [STKeychain getPasswordForUsername:@"OpenSense" andServiceName:@"OpenSense" error:nil];
}


- (void)uploadData:(id)sender
{
    // Fetch probe data, but if openSense is running, skip the currently used probe file to avoid conflicts. See Thesis p. 37
    BOOL * skipCurrent = [OpenSense sharedInstance].isRunning;
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:nil skipCurrent:skipCurrent parseJSON:NO success:^(NSArray *batches) {
        
        OSLog(@"Constructing JSON document with %lu batches", (unsigned long)[batches count]);
        
        // Construct JSON document by comma-separating indvidual data batches
        NSString *jsonFile = [[NSString alloc] init];
        for (NSData *lineData in batches) {
            NSString *lineStr = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
            
            if (lineStr) {
                jsonFile = [jsonFile stringByAppendingFormat:@"%@,", lineStr];
            }
        }
        
        // We don't need to upload anything if no valid data was found
        if ([jsonFile length] <= 0) {
            return;
        }
        
        // Remove the last comma
        jsonFile = [jsonFile substringToIndex:[jsonFile length] - 1];
        
        // ...and add array brackets
        jsonFile = [NSString stringWithFormat:@"[%@]", jsonFile];
        
//        OSLog(@"Json File to be sent:\n%@", jsonFile);
        
        // Create hash of document for integrity checking
        NSString *jsonFileHash = [jsonFile stringFromMD5];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[OSConfiguration currentConfig].baseUrl];
        
        NSDictionary *params = @{
            @"file_hash": jsonFileHash,
            @"device_id": [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],
            @"data": jsonFile
        };
        
        OSLog(@"Parameters: %@", params);
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/upload" parameters:params];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            if ([JSON objectForKey:@"status"] && [[JSON objectForKey:@"status"] isEqualToString:@"ok"]) {
                OSLog(@"Data succesfully uploaded!");
                
                // Determine file path
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"data"];
                
                // Find files in data directory
                NSArray *probeDataFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
                for (NSString *file in probeDataFiles) {
                    if ([file hasPrefix:@"probedata"] && ![file isEqualToString:@"probedata"]) {
                        [[NSFileManager defaultManager] removeItemAtPath:file error:nil]; // Delete file
                    }
                }
            } else {
                OSLog(@"Could not upload collected data");
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            OSLog(@"Could not upload collected data");
        }];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            OSLog(@"Uploading.. %lld / %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        
        [operation start];
    }];
}

- (void)refreshConfig:(id)sender
{
    [[OSConfiguration currentConfig] refresh];
}

@end

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
#import "OSLocalStorage.h"
#import "OSConfiguration.h"
#import "OSPositioningProbe.h"
#import "OSAccelerometerProbe.h"
#import "OSEnvironmentProbe.h"
#import "OSSocialProbe.h"
#import "OSDeviceInfoProbe.h"
#import "OSDeviceInteractionProbe.h"
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
                            [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier], @"uuid",
                            nil];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/register" parameters:params];

    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        // If a key was provided, store it in the keychain
        if ([JSON objectForKey:@"key"]) {
            
            NSError *error = nil;
            if (![STKeychain storeUsername:@"OpenSense" andPassword:[JSON objectForKey:@"key"] forServiceName:@"OpenSense" updateExisting:NO error:&error]) {
                NSLog(@"Could not store encryption key: %@", [error localizedDescription]);
            } else {            
                NSLog(@"Device registered with key: %@", [JSON objectForKey:@"key"]);
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
    NSError *error = nil;
    if (![STKeychain getPasswordForUsername:@"OpenSense" andServiceName:@"OpenSense" error:&error]) {
        [self registerDevice];
        return NO;
    }
    
    activeProbes = [[NSMutableArray alloc] init];
    for (Class class in [self enabledProbes])
    {
        OSProbe *probe = [[class alloc] init];
        [activeProbes addObject:probe];
        [probe startProbe];
    }
    
    isRunning = YES;
    startTime = [NSDate date];
    
    return YES;
}

- (void)stopCollector
{
    for (OSProbe *probe in activeProbes)
    {
        [probe stopProbe];
    }
    activeProbes = nil;
    
    isRunning = NO;
}

- (NSArray*)availableProbes
{
    return @[
        [OSPositioningProbe class],
        [OSAccelerometerProbe class],
        [OSEnvironmentProbe class],
        [OSSocialProbe class],
        [OSDeviceInfoProbe class],
        [OSDeviceInteractionProbe class],
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
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:probeIdentifier success:success];
}

- (NSString*)encryptionKey
{
    return [STKeychain getPasswordForUsername:@"OpenSense" andServiceName:@"OpenSense" error:nil];
}

@end

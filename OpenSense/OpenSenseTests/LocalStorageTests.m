//
//  LocalStorageTests.m
//  OpenSenseTests
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "LocalStorageTests.h"
#import "OSLocalStorage.h"

@implementation LocalStorageTests

- (void)setUp
{
    [super setUp];
    
    // Define Documents directory
    documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)resetDataDirectory
{
    // Delete Documents directory if it exists
    [[[NSFileManager alloc] init] removeItemAtPath:documentsPath error:nil];
    
    // Create a new, empty Documents directory
    [[[NSFileManager alloc] init] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)testFetchAll
{
    [self resetDataDirectory];
    
    // Define data batch set
    NSDictionary *batchData = @{
        @"someData": @"someValue"
    };
    
    // Save a single data batch
    [[OSLocalStorage sharedInstance] saveBatch:batchData fromProbe:@"testprobe"];
    
    // Verify file system
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:@"data"]], @"Data directory exists");
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:@"data/probedata"]], @"probedata file exists");
    
    // Initialize semaphore so we can wait for a response
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // Fetch all stored batches
    [[OSLocalStorage sharedInstance] fetchBatches:^(NSArray *batches) {
        STAssertTrue(([batches count] == 1), @"Exactly one batch exists");
        
        // Get data batch
        NSDictionary *dataBatch = [batches objectAtIndex:0];
        
        // Parse datetime property
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *creationDate = [dateFormatter dateFromString:[dataBatch objectForKey:@"datetime"]];
        STAssertTrue([creationDate timeIntervalSinceNow] < 60.0, @"Datetime property correctly set"); // Was created within 60 seconds?
        
        STAssertEqualObjects([dataBatch objectForKey:@"probe"], @"testprobe", @"Probe property correctly set");
        STAssertEqualObjects([dataBatch objectForKey:@"someData"], @"someValue", @"Data property correctly set");
        
        // Unlock semaphore
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Wait for a response before finishing up
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

- (void)testFetchSingle
{
    [self resetDataDirectory];
    
    // Define data batch set
    NSDictionary *batchData = @{
        @"singleData": @"singleValue"
    };
    
    // Save a single data batch
    [[OSLocalStorage sharedInstance] saveBatch:batchData fromProbe:@"othertestprobe"];
    
    // Verify file system
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:@"data"]], @"Data directory exists");
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByAppendingPathComponent:@"data/probedata"]], @"probedata file exists");
    
    // Initialize semaphore so we can wait for a response
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // Try non-existing probe
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:@"nonExistingProbe" skipCurrent:NO parseJSON:YES success:^(NSArray *batches) {
        STAssertTrue(([batches count] == 0), @"No batch results for non-existing probe");
        
        // Unlock semaphore
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Wait for a response before continuing
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
    
    // Try specific, existing probe
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:@"othertestprobe" skipCurrent:NO parseJSON:YES success:^(NSArray *batches) {
        STAssertTrue(([batches count] == 1), @"Exactly one batch exists");
        
        // Get data batch
        NSDictionary *dataBatch = [batches objectAtIndex:0];
        
        // Parse datetime property
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        
        NSDate *creationDate = [dateFormatter dateFromString:[dataBatch objectForKey:@"datetime"]];
        STAssertTrue([creationDate timeIntervalSinceNow] < 60.0, @"Datetime property correctly set"); // Was created within 60 seconds?
        
        STAssertEqualObjects([dataBatch objectForKey:@"probe"], @"othertestprobe", @"Probe property correctly set");
        STAssertEqualObjects([dataBatch objectForKey:@"singleData"], @"singleValue", @"Data property correctly set");
        
        // Unlock semaphore
        dispatch_semaphore_signal(semaphore);
    }];
    
    // Wait for a response before finishing up
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}

@end

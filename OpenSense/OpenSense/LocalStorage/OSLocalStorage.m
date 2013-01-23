//
//  OSLocalStorage.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSLocalStorage.h"
#import "OpenSense.h"
#import "OSConfiguration.h"
#import "NSData+AESCrypt.h"

@implementation OSLocalStorage

+ (OSLocalStorage*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)saveBatch:(NSDictionary*)batchDataDict fromProbe:(NSString*)probeIdentifier
{
    // Append timestamp and probe name to dictionary
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithDictionary:batchDataDict];
    [jsonDict setObject:probeIdentifier forKey:@"probe"];
    [jsonDict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"time"];
    
    // Convert to JSON data
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!jsonData) {
        NSLog(@"Could not serialize JSON data: %@", [error localizedDescription]);
        return ;
    }
    
    // Encrypt data
    NSData *encryptedJsonData = [jsonData AES256EncryptWithKey:[OpenSense sharedInstance].encryptionKey];
    NSString *encryptedJsonDataStr = [encryptedJsonData base64Encoding];
    
    // Rotate data file ifneedbe
    [self logrotate];
    
    // Append data to file    
    if (![self appendToProbeDataFile:encryptedJsonDataStr]) {
        NSLog(@"Could not save data from %@", probeIdentifier);
    } else {
        NSLog(@"Saved data from %@", probeIdentifier);
    }
    
    // Post "batch saved" notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSenseBatchSavedNotification object:jsonDict];
}

- (void)logrotate
{
    // Create data dir ifneedbe
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"data"];
    NSString *currentFile = [dataPath stringByAppendingPathComponent:@"probedata"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
        NSError *error = nil;
        
        // Create data directory and probedata file
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Could not create data directory: %@", [error localizedDescription]);
        } else {
            [[NSFileManager defaultManager] createFileAtPath:currentFile contents:nil attributes:nil]; // Create blank probedata file
        }
    }
    
    // Check size of current probedata file
    long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:currentFile error:nil][NSFileSize] longValue];
    long maxFileSize = ([[OSConfiguration currentConfig].maxDataFileSizeKb longValue] * 1024L);
    
    if (fileSize > maxFileSize) { // If file is to big
        NSLog(@"Rotating log file");
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh-mm-ss"];
        
        NSString *newFileName = [NSString stringWithFormat:@"probedata.%@", [dateFormatter stringFromDate:[NSDate date]]];
        NSString *newFile = [dataPath stringByAppendingPathComponent:newFileName];
        
        // Rename current probedata file to probedate.CURRENT_DATETIME
        NSError *error = nil;
        if (![[NSFileManager defaultManager] moveItemAtPath:currentFile toPath:newFile error:&error]) {
            NSLog(@"Could not rename file %@ to %@ - %@", currentFile, newFileName, [error localizedDescription]);
        } else {
            [[NSFileManager defaultManager] createFileAtPath:currentFile contents:nil attributes:nil]; // Create a new probedata file
        }
    }
}

- (BOOL)appendToProbeDataFile:(NSString*)line
{
    // Determine file path
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"data"];
    NSString *currentFile = [dataPath stringByAppendingPathComponent:@"probedata"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:currentFile];
    if (!fileHandle) {
        return NO;
    }
    
    // Add line break
    line = [line stringByAppendingString:@"\n"];
    
    // Convert to NSData object
    NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
    
    // Write to the end of the file
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle closeFile];
    
    return YES;
}

- (void)fetchBatches:(void (^)(NSArray *batches))success
{
    
}

- (void)fetchBatchesForProbe:(NSString*)probeIdentifier success:(void (^)(NSArray *batches))success
{
    
}

@end

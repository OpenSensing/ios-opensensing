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

- (id)init
{
    self = [super init];
    
    if (self) {
        probeFileQueue = dispatch_queue_create("dk.dtu.imm.sensible.filequeue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)saveBatch:(NSDictionary*)batchDataDict fromProbe:(NSString*)probeIdentifier
{
    // Append timestamp and probe name to dictionary
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] initWithDictionary:batchDataDict];
    [jsonDict setObject:probeIdentifier forKey:@"probe"];
    [jsonDict setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"datetime"];
    
    // Convert to JSON data
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:kNilOptions error:&error];
    if (!jsonData) {
        OSLog(@"Could not serialize JSON data: %@", [error localizedDescription]);
        return ;
    }
    
    // Encrypt data
    NSData *encryptedJsonData = [jsonData AES256EncryptWithKey:[OpenSense sharedInstance].encryptionKey];
    NSString *encryptedJsonDataStr = [encryptedJsonData base64Encoding];
    
    // Rotate probe data file ifneedbe
    [self logrotate];
    
    // Append data to file    
    [self appendToProbeDataFile:encryptedJsonDataStr];
    
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
            OSLog(@"Could not create data directory: %@", [error localizedDescription]);
        } else {
            [[NSFileManager defaultManager] createFileAtPath:currentFile contents:nil attributes:nil]; // Create blank probedata file
        }
    }
    
    // Check size of current probedata file
    long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:currentFile error:nil][NSFileSize] longValue];
    long maxFileSize = ([[OSConfiguration currentConfig].maxDataFileSizeKb longValue] * 1024L);
    
    if (fileSize > maxFileSize) { // If file is to big
        OSLog(@"Rotating log file");
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'hh-mm-ss"];
        
        NSString *newFileName = [NSString stringWithFormat:@"probedata.%@", [dateFormatter stringFromDate:[NSDate date]]];
        NSString *newFile = [dataPath stringByAppendingPathComponent:newFileName];
        
        // Rename current probedata file to probedate.CURRENT_DATETIME
        NSError *error = nil;
        if (![[NSFileManager defaultManager] moveItemAtPath:currentFile toPath:newFile error:&error]) {
            OSLog(@"Could not rename file %@ to %@ - %@", currentFile, newFileName, [error localizedDescription]);
        } else {
            [[NSFileManager defaultManager] createFileAtPath:currentFile contents:nil attributes:nil]; // Create a new probedata file
        }
    }
}

- (void)appendToProbeDataFile:(NSString*)content
{
    dispatch_async(probeFileQueue, ^{
        NSString *line = [content copy];
        
        // Determine file path
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"data"];
        NSString *currentFile = [dataPath stringByAppendingPathComponent:@"probedata"];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:currentFile];
        if (!fileHandle) {
            return;
        }
        
        // Add line break
        line = [line stringByAppendingString:@"\n\n"];
        
        // Convert to NSData object
        NSData *data = [line dataUsingEncoding:NSUTF8StringEncoding];
        
        // Write to the end of the file
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    });
}

- (void)fetchBatches:(void (^)(NSArray *batches))success
{
    [self fetchBatchesForProbe:nil skipCurrent:NO parseJSON:YES success:success];
}

- (void)fetchBatchesForProbe:(NSString*)probeIdentifier skipCurrent:(BOOL)skipCurrent parseJSON:(BOOL)parseJSON success:(void (^)(NSArray *batches))success
{
    // If a probe identifier is specified, we have to parse JSON
    if (probeIdentifier != nil) {
        parseJSON = YES;
    }
    
    dispatch_async(probeFileQueue, ^{
        NSMutableArray *allBatches = [[NSMutableArray alloc] init];
        
        // Determine file path
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dataPath = [documentsPath stringByAppendingPathComponent:@"data"];
        
        // Find files in data directory
        NSArray *probeDataFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
        for (NSString *file in probeDataFiles) {
            if ([file hasPrefix:@"probedata"]) { // If file is probedata file
                
                // If told to skip current and this is the current probedata file, skip processing it
                if (skipCurrent && [file isEqualToString:@"probedata"]) {
                    continue;
                }
                
                // Determine full path of the file
                NSString *filePath = [dataPath stringByAppendingPathComponent:file];
                
                // Read file and split into lines
                NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                
                for (NSString *line in lines) {
                    if ([line length] <= 0) { // Skip blank lines
                        continue;
                    }
                    
                    // Create data object and decrypt it
                    NSData *encryptedData = [[NSData alloc] initWithBase64EncodedString:line];
                    NSData *decryptedData = [encryptedData AES256DecryptWithKey:[OpenSense sharedInstance].encryptionKey];
                    
                    // Parse JSON if needed
                    if (parseJSON) {
                        NSError *error = nil;
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:decryptedData options:kNilOptions error:&error];
                        
                        if (!json) {
                            OSLog(@"Could not parse %@ error: %@", file, [error localizedDescription]);
                        } else {
                            // If probeidentifier is nil, just add it - else, only add it if probeIdentifier matches
                            if (!probeIdentifier || [[json objectForKey:@"probe"] isEqualToString:probeIdentifier]) {
                                [allBatches addObject:json];
                            }
                        }
                    } else {
                        // Just add the NSData object to our final array
                        [allBatches addObject:decryptedData];
                    }
                }
            }
        }
        
        // Execute on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *batches = [[NSArray alloc] initWithArray:allBatches];
            success(batches);
        });
    });
}

@end

//
//  OpenSense.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSProbe.h"
#import "OSPositioningProbe.h"

#define kOpenSenseBatchSavedNotification @"kOpenSenseBatchSavedNotification"

@interface OpenSense : NSObject {
    NSMutableArray *activeProbes;
    BOOL registrationInProgress;
}

@property (assign, readonly) BOOL isRunning;
@property (strong
           , readonly) NSDate *startTime;

+ (OpenSense*)sharedInstance;
- (BOOL)startCollector;
- (void)stopCollector;
- (NSArray*)availableProbes;
- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier;
- (void)localDataBatches:(void (^)(NSArray *batches))success;
- (void)localDataBatchesForProbe:(NSString*)probeIdentifier success:(void (^)(NSArray *batches))success;
- (NSString*)encryptionKey;

@end

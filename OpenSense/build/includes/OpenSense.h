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
}

@property (assign, readonly) BOOL isRunning;

+ (OpenSense*)sharedInstance;
- (void)startCollector;
- (void)stopCollector;
- (NSArray*)availableProbes;
- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier;
- (NSArray*)localDataBatches;
- (NSArray*)localDataBatchesForProbe:(NSString*)probeIdentifier;

@end

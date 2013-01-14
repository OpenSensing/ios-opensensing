//
//  OSLocalStorage.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSLocalStorage.h"
#import "OpenSense.h"
#import "ZIMOrmSdk.h"
#import "Batch.h"

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
    Batch *batch = [[Batch alloc] init];
    batch.created = [NSDate date];
    batch.probeIdentifier = probeIdentifier;
    [batch save];
    
    for (NSString *key in batchDataDict) {
        BatchData *batchData = [[BatchData alloc] init];
        batchData.batchId = batch.pk;
        batchData.key = key;
        batchData.value = [batchDataDict valueForKey:key];
        [batchData save];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSenseBatchSavedNotification object:batch];
}

- (NSArray*)fetchBatches
{
    ZIMOrmSelectStatement *select = [[ZIMOrmSelectStatement alloc] initWithModel: [Batch class]];
    [select orderBy:@"created" descending:NO]; // Newest first
    return [select query];
}

- (NSArray*)fetchBatchesForProbe:(NSString*)probeIdentifier
{
    ZIMOrmSelectStatement *select = [[ZIMOrmSelectStatement alloc] initWithModel: [Batch class]];
    [select where:@"probeIdentifier" operator:ZIMSqlOperatorEqualTo value:probeIdentifier]; // Only batches from the specific probe
    [select orderBy:@"created" descending:NO]; // Newest first
    return [select query];
}

@end

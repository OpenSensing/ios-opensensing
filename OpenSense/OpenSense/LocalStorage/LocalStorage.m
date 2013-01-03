//
//  LocalStorage.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "LocalStorage.h"
#import "Batch.h"

@implementation LocalStorage

+ (LocalStorage*)sharedInstance
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
}

@end

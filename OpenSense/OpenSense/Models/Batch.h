//
//  Batch.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "ZIMOrmModel.h"
#import "BatchData.h"

@interface Batch : ZIMOrmModel {
    @private
    NSNumber *_pk;
    NSDate *_created;
    NSString *_probeIdentifier;
}

@property (nonatomic, strong) NSNumber *pk;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *probeIdentifier;

- (NSArray*)batchData;
- (NSDictionary*)batchDataDict;

@end

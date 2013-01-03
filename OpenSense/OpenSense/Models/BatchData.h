//
//  BatchData.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "ZIMOrmModel.h"

@interface BatchData : ZIMOrmModel {
    @private
    NSNumber *_pk;
    NSNumber *_batchId;
    NSString *_key;
    NSString *_value;
}

@property (nonatomic, strong) NSNumber *pk;
@property (nonatomic, strong) NSNumber *batchId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

@end

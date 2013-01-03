//
//  BatchData.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "BatchData.h"

@implementation BatchData

@synthesize pk = _pk;
@synthesize batchId = _batchId;
@synthesize key = _key;
@synthesize value = _value;

- (id) init {
	if ((self = [super init])) {
		_saved = nil;
	}
	return self;
}

+ (NSString *) dataSource {
	return @"opensense";
}

+ (NSString *) table {
	return @"batch_data";
}

+ (NSArray *) primaryKey {
	return [NSArray arrayWithObjects: @"pk", nil];
}

+ (BOOL) isAutoIncremented {
	return YES;
}

@end
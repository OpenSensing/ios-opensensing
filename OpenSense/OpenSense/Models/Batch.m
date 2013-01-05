//
//  Batch.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "Batch.h"

@implementation Batch

@synthesize pk = _pk;
@synthesize created = _created;
@synthesize probeIdentifier = _probeIdentifier;

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
	return @"batches";
}

+ (NSArray *) primaryKey {
	return [NSArray arrayWithObjects: @"pk", nil];
}

+ (BOOL) isAutoIncremented {
	return YES;
}

- (NSArray*)batchData {
    return [self hasMany:[BatchData class] foreignKey:[NSArray arrayWithObject:@"batchId"]];
}

@end
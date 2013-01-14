//
//  OSLocalStorage.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSLocalStorage : NSObject

+ (OSLocalStorage*)sharedInstance;
- (void)saveBatch:(NSDictionary*)batch fromProbe:(NSString*)probeIdentifier;
- (NSArray*)fetchBatches;
- (NSArray*)fetchBatchesForProbe:(NSString*)probeIdentifier;

@end

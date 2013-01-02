//
//  OpenSense.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSProbe.h"

@interface OpenSense : NSObject

@property (assign, readonly) BOOL isRunning;

+ (OpenSense*)sharedInstance;
- (void)startCollector;
- (void)stopCollector;
- (NSArray*)availableProbes;

@end

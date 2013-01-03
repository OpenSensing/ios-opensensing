//
//  LocalStorage.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalStorage : NSObject

+ (LocalStorage*)sharedInstance;
- (void)saveBatch:(NSDictionary*)batch fromProbe:(NSString*)probeIdentifier;

@end

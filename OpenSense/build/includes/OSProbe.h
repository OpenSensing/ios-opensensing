//
//  OSProbe.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSProbe : NSObject {
    NSTimer *updateTimer;
    NSTimeInterval updateInterval;
}

@property (assign, readonly) BOOL isStarted;

+ (NSString*)name;
+ (NSString*)identifier;
+ (NSString*)description;
+ (NSTimeInterval)defaultUpdateInterval;

- (void)startProbe;
- (void)stopProbe;
- (void)saveData;
- (NSDictionary*)sendData;
- (NSTimeInterval)updateInterval;

@end

//
//  OSConfiguration.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/14/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSConfiguration : NSObject {
    NSDictionary *config;
}

+ (OSConfiguration*)currentConfig;
- (void)loadConfig;
- (void)refreshConfig;
- (NSNumber*)version;
- (NSURL*)baseUrl;
- (NSNumber*)configUpdatePeriod;
- (NSNumber*)dataArchivePeriod;
- (NSNumber*)dataUploadPeriod;
- (NSNumber*)maxDataFileSizeKb;
- (NSTimeInterval)updateIntervalForProbe:(NSString*)probeId;

@end

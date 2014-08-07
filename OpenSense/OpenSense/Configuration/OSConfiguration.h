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
- (void)load;
- (void)refresh;
- (NSNumber*)version;
- (NSURL*)baseUrl;
- (NSNumber*)configUpdatePeriod;
- (NSNumber*)dataArchivePeriod;
- (NSNumber*)dataUploadPeriod;
- (NSNumber*)maxDataFileSizeKb;
- (NSTimeInterval)updateIntervalForProbe:(NSString*)probeId;
- (NSArray*)enabledProbes;
- (NSDictionary *)motionConfig;
- (NSDictionary *)activityConfig;

@end

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
- (NSString*)name;
- (NSNumber*)version;
- (NSString*)configUpdateUrl;
- (NSNumber*)configUpdatePeriod;
- (NSNumber*)dataArchivePeriod;
- (NSString*)dataUploadUrl;
- (NSNumber*)dataUploadPeriod;
- (NSTimeInterval)updateIntervalForProbe:(NSString*)probeId;

@end

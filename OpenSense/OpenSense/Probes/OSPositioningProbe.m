//
//  OSPositioningProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSPositioningProbe.h"

@implementation OSPositioningProbe

+ (NSString*)name
{
    return @"Positioning";
}

+ (NSString*)identifier
{
    return @"dk.dtu.imm.sensible.positioning";
}

+ (NSString*)description
{
    return @"";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return -1;
}

- (void)startProbe
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopProbe
{
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager = nil;
}

- (NSDictionary*)sendData
{
    if (!lastLocation)
        return nil;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:lastLocation.coordinate.latitude], @"lat",
                                 [NSNumber numberWithDouble:lastLocation.coordinate.longitude], @"lon",
                                 [NSNumber numberWithDouble:lastLocation.altitude], @"altitude",
                                 [NSNumber numberWithDouble:lastLocation.speed], @"speed", // m/s
                                 [NSNumber numberWithDouble:lastLocation.horizontalAccuracy], @"horizontal_accuracy",
                                 [NSNumber numberWithDouble:lastLocation.verticalAccuracy], @"vertical_accuracy",
                                 [NSNumber numberWithDouble:lastLocation.course], @"course", // 0 - 359.9 degrees
                                 nil];
    
    return data;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] <= 0)
        return;
    
    // Save location and tell probe to store it
    lastLocation = [locations objectAtIndex:0];
    [self saveData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Could not monitor location: %@", [error localizedDescription]);
}


@end

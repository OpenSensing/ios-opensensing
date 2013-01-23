//
//  OSPositioningProbe.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OSProbe.h"

@interface OSPositioningProbe : OSProbe<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *lastLocation;
}

@end

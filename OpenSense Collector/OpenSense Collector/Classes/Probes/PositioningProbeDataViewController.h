//
//  PositioningProbeDataViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoadingView.h"

@interface PositioningProbeDataViewController : UIViewController<MKMapViewDelegate> {
    MKMapView *mapView;
    NSArray *collectedData;
    LoadingView *loadingView;
    MKPolyline *polyline;
}

@end

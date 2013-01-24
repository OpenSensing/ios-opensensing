//
//  PositioningProbeDataViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "PositioningProbeDataViewController.h"
#import "OpenSense.h"

#define kDistanceMargin 1000 // 1km

@interface PositioningProbeDataViewController ()

@end

@implementation PositioningProbeDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
        mapView.showsUserLocation = YES;
        mapView.delegate = self;
        [self.view addSubview:mapView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Show loading view
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:loadingView];
    
    // Load data
    [[OpenSense sharedInstance] localDataBatchesForProbe:@"dk.dtu.imm.sensible.positioning" success:^(NSArray *batches) {
        collectedData = batches;
        
        [self showData];
        
        // Remove loading view
        [loadingView removeFromSuperview];
        loadingView = nil;
    }];
}

- (void)showData
{
    // Store all coordinates in a simple array
    CLLocationCoordinate2D coordinates[[collectedData count]];
    
    MKMapPoint annotationPoint = MKMapPointForCoordinate(mapView.userLocation.coordinate);
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    
    // For each position collected
    int i = 0;
    for (NSDictionary *entry in collectedData) {
        // Create coordinate
        CLLocationCoordinate2D annotationCoord = CLLocationCoordinate2DMake([[entry objectForKey:@"lat"] doubleValue], [[entry objectForKey:@"lon"] doubleValue]);
        
        // Add coordinate to array
        coordinates[i] = annotationCoord;
        
        // Create annotation
        MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
        annotationPoint.coordinate = annotationCoord;
        annotationPoint.title = [entry objectForKey:@"datetime"];
        annotationPoint.subtitle = [NSString stringWithFormat:@"Accuracy: %.2f, Speed: %.2f", [[entry objectForKey:@"horizontal_accuracy"] doubleValue], [[entry objectForKey:@"speed"] doubleValue]];
        [mapView addAnnotation:annotationPoint];
        
        // Include point in zoom region
        MKMapPoint localAnnotationPoint = MKMapPointForCoordinate(annotationCoord);
        MKMapRect pointRect = MKMapRectMake(localAnnotationPoint.x, localAnnotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
        i++;
    }
    
    // Enlargen region so map is not clamped around pins
    zoomRect = MKMapRectMake(MKMapRectGetMinX(zoomRect) - kDistanceMargin, MKMapRectGetMinY(zoomRect) - kDistanceMargin, MKMapRectGetWidth(zoomRect) + (kDistanceMargin * 2), MKMapRectGetHeight(zoomRect) + (kDistanceMargin * 2));
    
    // Zoom map to the calculated region
    [mapView setVisibleMapRect:zoomRect animated:YES];
    
    // Create polyline between pins
    polyline = [MKPolyline polylineWithCoordinates:coordinates count:[collectedData count]];
    
    [mapView addOverlay:polyline];
    [mapView setNeedsDisplay];
}

- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor greenColor];
    polylineView.lineWidth = 5.0;
    
    return polylineView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

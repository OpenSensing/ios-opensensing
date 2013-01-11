//
//  BatteryProbeDataViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BatteryProbeDataViewController : UIViewController<CPTPlotDataSource> {
    CPTGraphHostingView *hostView;
    NSArray *plotData;
}

@end

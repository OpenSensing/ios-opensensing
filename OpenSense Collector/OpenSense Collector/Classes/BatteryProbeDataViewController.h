//
//  ProbeDataPlotViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface ProbeDataPlotViewController : UIViewController<CPTPlotDataSource> {
    CPTGraphHostingView *hostView;
    NSArray *plotData;
}

@property (nonatomic, strong) NSString *probeIdentifer;

@end

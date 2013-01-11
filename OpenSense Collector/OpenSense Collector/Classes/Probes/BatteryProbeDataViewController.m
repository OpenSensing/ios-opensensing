//
//  BatteryProbeDataViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "BatteryProbeDataViewController.h"
#import "OpenSense.h"
#import "Batch.h"

#define kFullPlot @"FULL"
#define kChargingPlot @"CHARGING"
#define kUnpluggedPlot @"UNPLUGGED"
#define kUnknownPlot @"UNKNOWN"

@interface BatteryProbeDataViewController ()

@end

@implementation BatteryProbeDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load data from local storage
    plotData = [[OpenSense sharedInstance] localDataBatchesForProbe:@"dk.dtu.imm.sensible.battery"];
    
    [self initPlot];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initPlot];
}

- (void)initPlot
{
    [self configureHost];
    [self configureGraph];
    [self configurePlot:kFullPlot color:[CPTColor blueColor]];
    [self configurePlot:kChargingPlot color:[CPTColor yellowColor]];
    [self configurePlot:kUnpluggedPlot color:[CPTColor redColor]];
    [self configurePlot:kUnknownPlot color:[CPTColor grayColor]];
    [self configureAxes];
}

- (void)configureHost
{
    hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    //hostView.allowPinchScaling = YES;
    [self.view addSubview:hostView];
}

- (void)configureGraph
{
    // Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTSlateTheme]];
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.paddingLeft = 0.0;
    graph.paddingTop = 0.0;
    graph.paddingRight = 0.0;
    graph.paddingBottom = 0.0;
    graph.plotAreaFrame.paddingTop	= 15.0;
	graph.plotAreaFrame.paddingRight = 10.0;
	graph.plotAreaFrame.paddingBottom = 75.0;
	graph.plotAreaFrame.paddingLeft = 40.0;
    hostView.hostedGraph = graph;
    
    // Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
}

- (void)configurePlot:(NSString*)identifier color:(CPTColor*)levelColor
{
    // Get graph and plot space
    CPTGraph *graph = hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // Create the plot(s)
    CPTScatterPlot *levelPlot = [[CPTScatterPlot alloc] init];
    levelPlot.dataSource = self;
    levelPlot.identifier = identifier;
    [graph addPlot:levelPlot toPlotSpace:plotSpace];
    
    // Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:levelPlot, nil]];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0)
                                                    length:CPTDecimalFromUnsignedInteger(20)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0)
                                                    length:CPTDecimalFromUnsignedInteger(100)];
    // Create styles and symbols
    CPTMutableLineStyle *levelLineStyle = [levelPlot.dataLineStyle mutableCopy];
    levelLineStyle.lineWidth = 2.5;
    levelLineStyle.lineColor = levelColor;
    levelPlot.dataLineStyle = levelLineStyle;
    
    CPTMutableLineStyle *levelSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    levelSymbolLineStyle.lineColor = levelColor;
    
    CPTPlotSymbol *levelSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    levelSymbol.fill = [CPTFill fillWithColor:levelColor];
    levelSymbol.lineStyle = levelSymbolLineStyle;
    levelSymbol.size = CGSizeMake(6.0f, 6.0f);
    levelPlot.plotSymbol = levelSymbol;
}

- (void)configureAxes
{
    // Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    
    // Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
    
    // Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = plotData.count;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    for (Batch *batch in plotData)
    {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSDateFormatter localizedStringFromDate:batch.created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle] textStyle:x.labelTextStyle];
        CGFloat location = i;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        label.rotation = -(M_PI / 4);
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
        i++;
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    // Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Battery level";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 20;
    NSInteger minorIncrement = 5;
    CGFloat yMax = 100.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i%%", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

#pragma mark -
#pragma mark Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{    
    switch (fieldEnum)
    {
        case CPTScatterPlotFieldX:
            if (index < plotData.count) {
                return [NSNumber numberWithUnsignedInteger:index];
            }
            break;
            
        case CPTScatterPlotFieldY:
        {
            if (![(NSString*)plot.identifier isEqualToString:kUnpluggedPlot])
                return nil;
            
            Batch *batch = [plotData objectAtIndex:index];
            NSDictionary *batchDataDict = [batch batchDataDict];
            
            Batch *previousBatch = nil;
            NSDictionary *previousBatchDataDict = nil;
            if (index > 0) {
                previousBatch = [plotData objectAtIndex:index - 1];
                previousBatchDataDict = [previousBatch batchDataDict];
            }
            
            // If battery state has changed and this plot is the same as the previous one
            if (previousBatch && ![[batchDataDict objectForKey:@"BATTERY_STATE"] isEqualToString:[previousBatchDataDict objectForKey:@"BATTERY_STATE"]])
            {
                NSLog(@"Ping!\n");
                
                if ([(NSString*)plot.identifier isEqualToString:kUnpluggedPlot])
                {
                    return [NSNumber numberWithDouble:[[batchDataDict objectForKey:@"BATTERY_LEVEL"] doubleValue] * 100.0f];
                }
            }
            
            NSLog(@"%d: %f %@ (%d)", index, [[batchDataDict objectForKey:@"BATTERY_LEVEL"] doubleValue], [batchDataDict objectForKey:@"BATTERY_STATE"], (![[previousBatchDataDict objectForKey:@"BATTERY_STATE"] isEqualToString:(NSString*)plot.identifier]) ? 1 : 0);
            
            if (![[batchDataDict objectForKey:@"BATTERY_STATE"] isEqualToString:(NSString*)plot.identifier])
            {
                return nil;
            }
            
            return [NSNumber numberWithDouble:[[batchDataDict objectForKey:@"BATTERY_LEVEL"] doubleValue] * 100.0f];
            
            break;
        }
    }
    
    return [NSDecimalNumber zero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

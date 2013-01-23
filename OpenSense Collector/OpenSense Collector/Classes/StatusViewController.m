//
//  StatusViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "StatusViewController.h"
#import "OpenSense.h"
@interface StatusViewController ()

@end

@implementation StatusViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCollecting:(id)sender
{
    if ([OpenSense sharedInstance].isRunning)
    {
        [[OpenSense sharedInstance] stopCollector];
        [self.runningView setHidden:YES];
        [self.pausedView setHidden:NO];
    }
    else
    {
        if ([[OpenSense sharedInstance] startCollector]) {
            [self.runningView setHidden:NO];
            [self.pausedView setHidden:YES];
        }
    }
}

@end

//
//  TabBarViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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

- (BOOL)shouldAutorotate;
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    /*UINavigationController *selectedNavigationController = (UINavigationController*)[self selectedViewController];
    
    if ([[selectedNavigationController topViewController] respondsToSelector:@selector(supportedInterfaceOrientations)])
    {
        return [[selectedNavigationController topViewController] supportedInterfaceOrientations];
    }*/
    
    return UIInterfaceOrientationMaskPortrait; // Return to default supported orientation
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

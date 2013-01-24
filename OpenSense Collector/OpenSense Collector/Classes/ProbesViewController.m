//
//  ProbesViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "ProbesViewController.h"
#import "BatteryProbeDataViewController.h"
#import "OpenSense.h"

@interface ProbesViewController ()

@end

@implementation ProbesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-texture"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = backgroundImageView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get available probes from OpenSense
    probes = [[OpenSense sharedInstance] availableProbes];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return probes ? [probes count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[probes objectAtIndex:[indexPath row]] name];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *dataViewController = nil;
    
    NSString *probeName = [[probes objectAtIndex:[indexPath row]] name];
    NSString *className = [NSString stringWithFormat:@"%@ProbeDataViewController", probeName];
    Class dataViewControllerClass = NSClassFromString(className);
    
    if (dataViewControllerClass)
    {
        dataViewController = [[dataViewControllerClass alloc] init];
    }
    
    if (dataViewController)
    {
        [self.navigationController pushViewController:dataViewController animated:YES];
    }
}

@end

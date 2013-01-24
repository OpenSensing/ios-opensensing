//
//  CollectedDataViewController.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "CollectedDataViewController.h"
#import "CollectedDataBatchViewController.h"
#import "BatchCell.h"
#import "OpenSense.h"

@interface CollectedDataViewController ()

@end

@implementation CollectedDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-texture"]];
    [backgroundImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = backgroundImageView;
    
    // Show loading view
    loadingView = [[LoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:loadingView];
    
    // Load data
    batches = nil;
    [[OpenSense sharedInstance] localDataBatches:^(NSArray *fetchedBatches) {
        batches = [[NSMutableArray alloc] initWithArray:fetchedBatches];
        [self.tableView reloadData];
        
        // Remove loading view
        [loadingView removeFromSuperview];
        loadingView = nil;
    }];
    
    // Initialize dateformatter
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batchesUpdated:) name:kOpenSenseBatchSavedNotification object:nil];
}

- (void)batchesUpdated:(NSNotification*)notification
{
    NSDictionary *batch = [notification object];
    [batches insertObject:batch atIndex:0];
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
    return batches ? [batches count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BatchCell";
    BatchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Get batch
    NSDictionary *batch = [batches objectAtIndex:[indexPath row]];
    
    // Format date
    NSDate *datetime = [dateFormatter dateFromString:[batch objectForKey:@"datetime"]];
    cell.labelDateTime.text = [NSDateFormatter localizedStringFromDate:datetime dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    
    NSString *probeName = [[OpenSense sharedInstance] probeNameFromIdentifier:[batch objectForKey:@"probe"]];
    cell.labelProbe.text = probeName ? probeName : @"Unknown";
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BatchDataSegue"])
    {
        // Get batch data and probe name
        NSDictionary *batch = [batches objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        NSString *probeName = [[OpenSense sharedInstance] probeNameFromIdentifier:[batch objectForKey:@"probe"]];
        
        // Get viewcontroller and set batch and title
        CollectedDataBatchViewController *CollectedDataBatchViewController = [segue destinationViewController];
        [CollectedDataBatchViewController setBatch:batch];
        [CollectedDataBatchViewController setTitle:probeName];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

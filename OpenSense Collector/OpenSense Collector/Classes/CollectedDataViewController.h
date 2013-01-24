//
//  CollectedDataViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@interface CollectedDataViewController : UITableViewController {
    NSMutableArray *batches;
    NSDateFormatter *dateFormatter;
    LoadingView *loadingView;
}

@end

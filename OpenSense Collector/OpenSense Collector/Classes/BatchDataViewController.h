//
//  BatchDataViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Batch.h"

@interface BatchDataViewController : UITableViewController {
    NSArray *batchDataItems;
}

@property (nonatomic, strong) Batch *batch;

@end

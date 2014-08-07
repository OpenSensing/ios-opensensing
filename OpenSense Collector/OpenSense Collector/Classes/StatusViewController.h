//
//  StatusViewController.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusViewController : UIViewController {
    NSTimer *elapsedTimer;
    long entriesCount;
}

@property (weak, nonatomic) IBOutlet UIView *pausedView;
@property (weak, nonatomic) IBOutlet UIView *runningView;
@property (weak, nonatomic) IBOutlet UILabel *labelStorage;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

- (IBAction)toggleCollecting:(id)sender;
- (IBAction)toggleUpload:(id)sender;

@end

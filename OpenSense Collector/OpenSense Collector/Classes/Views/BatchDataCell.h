//
//  BatchDataCell.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/4/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BatchDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelKey;
@property (weak, nonatomic) IBOutlet UILabel *labelValue;

@end

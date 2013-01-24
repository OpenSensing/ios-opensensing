//
//  LoadingView.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)];
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, activityIndicatorView.center.y + 20.0, frame.size.width, 40.0)];
        [loadingLabel setBackgroundColor:[UIColor clearColor]];
        [loadingLabel setTextColor:[UIColor whiteColor]];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        [loadingLabel setText:@"Decrypting data"];
        [self addSubview:loadingLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

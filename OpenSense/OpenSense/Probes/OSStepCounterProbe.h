//
//  OSStepCounter.h
//  OpenSense
//
//  Created by Albert Carter on 8/5/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"

@interface OSStepCounterProbe : OSProbe{
    
    NSOperationQueue *stepQueue;
}

@property (strong, nonatomic) NSDate *lastStepCountSample;

@end

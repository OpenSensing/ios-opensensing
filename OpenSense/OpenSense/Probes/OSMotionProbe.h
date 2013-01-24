//
//  OSMotionProbe.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"
#import <CoreMotion/CoreMotion.h>

@interface OSMotionProbe : OSProbe {
    CMMotionManager *motionManager;
    NSOperationQueue *operationQueue;
    CMLogItem *lastData;
}

@end

//
//  OSMotionProbe.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"
#import "OSConfiguration.h"
#import <CoreMotion/CoreMotion.h>

@interface OSMotionProbe : OSProbe {
    NSOperationQueue *operationQueue;
    CMDeviceMotion *lastData;

}

// turn on processor and start sampling data.
// startProbe will turn these on and off on a timer.
-(void) startSample;
-(void) stopSample;


@end

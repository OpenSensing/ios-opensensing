//
//  OSActivityManagerProbe.h
//  OpenSense
//
//  Created by Albert Carter on 8/1/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import "OSProbe.h"

@interface OSActivityManagerProbe : OSProbe{
    NSOperationQueue *activityQueue;
}

@end

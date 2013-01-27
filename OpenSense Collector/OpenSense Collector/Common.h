//
//  Common.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/27/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#ifndef OpenSense_Collector_Common_h
#define OpenSense_Collector_Common_h

#ifdef DEBUG
#define OSLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define OSLog(...) do { } while (0)
#endif

#endif

//
//  SleepMonitor.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/21/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "SleepPoint.h"
#import "DreamCatcherDBHelper.h"
#import <CoreFoundation/CoreFoundation.h>

@interface SleepMonitor : NSObject {
    CMAcceleration gravity;
    double maxNetForce;
    int wait;
    NSTimer *timer;
}


@property (strong, nonatomic) CMMotionManager *motionManager;

@property NSMutableArray *data;
//@property NSTimer *timer;


- (void)start;
- (void)stop;

- (id)init;

@end


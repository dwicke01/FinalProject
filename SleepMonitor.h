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
    
}


@property (strong, nonatomic) CMMotionManager *motionManager;

@property NSMutableArray *data;
@property NSMutableArray *gravity;
@property NSDate *dateStarted;
@property NSTimer *timer;

@property int wait;
@property double maxNetForce;

- (void)start;
- (void)stop;

- (id)init;

@end


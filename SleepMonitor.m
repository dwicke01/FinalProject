//
//  SleepMonitor.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/21/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "SleepMonitor.h"

@implementation SleepMonitor



- (id)init
{
    self = [super init];
    if (self) {
        gravity.x = gravity.y = gravity.z = 0;
        self.motionManager = [[CMMotionManager alloc]init];
        self.motionManager.accelerometerUpdateInterval = .05;
        wait = 0;
        maxNetForce = 0;
        self.data = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)start
{
    wait = 0;
    [self.data removeAllObjects];
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
        ^{
                if (wait < 5) {
                    if (wait == 4) {
                        wait++;
                        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
                        gravity.x = self.motionManager.accelerometerData.acceleration.x;
                        gravity.y = self.motionManager.accelerometerData.acceleration.y;
                        gravity.z = self.motionManager.accelerometerData.acceleration.z;

                    }
                    wait++;
                    return;
                }

            
                const double x = self.motionManager.accelerometerData.acceleration.x - gravity.x;
                const double y = self.motionManager.accelerometerData.acceleration.y - gravity.y;
                const double z = self.motionManager.accelerometerData.acceleration.z - gravity.z;

                const double accelCurrent = sqrt(x * x + y * y + z * z);
                
            
                const double absAccel = fabs(accelCurrent);

                if (absAccel > maxNetForce)
                    maxNetForce = absAccel;
            }
        );
     }
     ];
}



- (void)processTimer
{
    //NSString *dateString = [NSString stringWithFormat:@"%f", [self.dateStarted timeIntervalSince1970]];
    //float x = [dateString doubleValue];
    //NSTimeInterval x = [self.dateStarted timeIntervalSince1970] + (NSTimeInterval)[self.data count];
    NSTimeInterval x = [[NSDate date] timeIntervalSince1970];
    //x++;
    //x = x + [[self data] count];
    double y = MIN(1.0f, maxNetForce);
    
    NSLog(@"The current timestamp is: %f", x);
    NSLog(@"self.data.count is %lu", (unsigned long)[self.data count]);
    
    SleepPoint *p = [[SleepPoint alloc] init :x :y];
    
    [self.data addObject:p];
}

- (SleepDataWrapper*)createSleepDataWrapper
{
    SleepDataWrapper *wrapper = [[SleepDataWrapper alloc] init:[(SleepPoint*)[self.data objectAtIndex:0] x] :[[NSDate date]timeIntervalSince1970] :self.data];
    return wrapper;
}

- (void)stop
{
    [self.motionManager stopAccelerometerUpdates];
    [timer invalidate];
    timer = nil;
    SleepDataWrapper *wrapper = [self createSleepDataWrapper];
    DreamCatcherDBHelper *helper = [DreamCatcherDBHelper getSharedInstance];
    [helper insertData :wrapper];
    [self.data removeAllObjects];
}


- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    [self.motionManager stopAccelerometerUpdates];
}
@end

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
        self.dateStarted = [[NSDate alloc] init];
        self.motionManager.accelerometerUpdateInterval = .05;
        self.wait = 0;
        self.maxNetForce = 0.0f;
        self.data = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)start
{
    self.dateStarted =[NSDate date];
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
        ^{
                if (self.wait < 5) {
                    if (self.wait == 4) {
                        self.wait++;
                        
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
                        gravity.x = self.motionManager.accelerometerData.acceleration.x;
                        gravity.y = self.motionManager.accelerometerData.acceleration.y;
                        gravity.z = self.motionManager.accelerometerData.acceleration.z;

                    }
                    self.wait++;
                    return;
                }
                
                float alpha = .8f;

                gravity.x = alpha*gravity.x + (1-alpha)*self.motionManager.accelerometerData.acceleration.x;
                gravity.y = alpha*gravity.y + (1-alpha)*self.motionManager.accelerometerData.acceleration.y;
                gravity.z = alpha*gravity.z + (1-alpha)*self.motionManager.accelerometerData.acceleration.z;
                
                const double x = (float)self.motionManager.accelerometerData.acceleration.x - gravity.x;
                const double y = (float)self.motionManager.accelerometerData.acceleration.y - gravity.y;
                const double z = (float)self.motionManager.accelerometerData.acceleration.z - gravity.z;

                const double accelCurrent = sqrt(x * x + y * y + z * z);
                
                NSLog(@"The current acceleration is %f", accelCurrent);
                
                const double absAccel = abs(accelCurrent);
                //self.maxNetForce = absAccel > self.maxNetForce ? absAccel : self.maxNetForce;
                if (absAccel > self.maxNetForce)
                    self.maxNetForce = absAccel;
                NSLog(@"The cmmotionmanager thread says the force is %f", self.maxNetForce);
            }
        );
     }
     ];
}



- (void)processTimer
{
    float now = [[NSDate date] timeIntervalSince1970];
    float x = now;
    float y = MIN(1.0f, self.maxNetForce);
    
    NSLog(@"The current force is: %f", y);
    
    SleepPoint *p = [[SleepPoint alloc] init :x :y];
    
    [self.data addObject:p];
}

- (SleepDataWrapper*)createSleepDataWrapper
{
    SleepDataWrapper *wrapper = [[SleepDataWrapper alloc] init:[self.dateStarted timeIntervalSince1970] :[[NSDate date]timeIntervalSince1970] :self.data];
    return wrapper;
}

- (void)stop
{
    [self.motionManager stopAccelerometerUpdates];
    [self.timer invalidate];
    SleepDataWrapper *wrapper = [self createSleepDataWrapper];
    DreamCatcherDBHelper *helper = [DreamCatcherDBHelper getSharedInstance];
    [helper insertData :wrapper];
}


- (void)dealloc
{
    [self.timer invalidate];
    [self.motionManager stopAccelerometerUpdates];
}
@end

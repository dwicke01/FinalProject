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
        self.gravity = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:0], [NSNumber numberWithFloat:0], nil];
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
            @synchronized(self.gravity){
                if (self.wait < 5) {
                    if (self.wait == 4) {
                        self.wait++;
                        
                        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(processTimer) userInfo:nil repeats:YES];
                        [self.gravity replaceObjectAtIndex:0 withObject: [[NSNumber alloc] initWithFloat: (float)self.motionManager.accelerometerData.acceleration.x]];
                        [self.gravity replaceObjectAtIndex:1 withObject: [[NSNumber alloc] initWithFloat: (float)self.motionManager.accelerometerData.acceleration.y]];
                        [self.gravity replaceObjectAtIndex:2 withObject: [[NSNumber alloc] initWithFloat: (float)self.motionManager.accelerometerData.acceleration.z]];
                    }
                    self.wait++;
                    return;
                }
                
                float alpha = .8f;
                
                [self.gravity replaceObjectAtIndex:0 withObject: [[NSNumber alloc] initWithFloat: alpha * [[self.gravity objectAtIndex:0] floatValue] + (1 - alpha) *(float)self.motionManager.accelerometerData.acceleration.x]];
                [self.gravity replaceObjectAtIndex:1 withObject: [[NSNumber alloc] initWithFloat: alpha * [[self.gravity objectAtIndex:1] floatValue] + (1 - alpha) *(float)self.motionManager.accelerometerData.acceleration.y]];
                [self.gravity replaceObjectAtIndex:2 withObject: [[NSNumber alloc] initWithFloat: alpha * [[self.gravity objectAtIndex:2] floatValue] + (1 - alpha) *(float)self.motionManager.accelerometerData.acceleration.z]];
                
                const double x = (float)self.motionManager.accelerometerData.acceleration.x - [[self.gravity objectAtIndex :0] floatValue] ;
                const double y = (float)self.motionManager.accelerometerData.acceleration.y - [[self.gravity objectAtIndex :1] floatValue];
                const double z = (float)self.motionManager.accelerometerData.acceleration.z - [[self.gravity objectAtIndex :2] floatValue];

                const double accelCurrent = sqrt(x * x + y * y + z * z);
                
                NSLog(@"The current acceleration is %f", accelCurrent);
                
                const double absAccel = abs(accelCurrent);
                //self.maxNetForce = absAccel > self.maxNetForce ? absAccel : self.maxNetForce;
                if (absAccel > self.maxNetForce)
                    self.maxNetForce = absAccel;
            }

            
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
    SleepDataWrapper *wrapper = [self createSleepDataWrapper];
    DreamCatcherDBHelper *helper = [DreamCatcherDBHelper getSharedInstance];
    [helper insertData :wrapper];
}


- (void)dealloc
{
    [self.motionManager stopAccelerometerUpdates];
}
@end

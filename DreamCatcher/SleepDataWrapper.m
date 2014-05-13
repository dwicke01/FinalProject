//
//  SleepSession.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "SleepSession.h"

@implementation SleepSession

- (id)init :(long)startTimestamp :(long)endTimestamp :(double)min :(float)calibrationLevel :(int)rating :(long)duration :(int)spikes :(long)fellAsleep :(NSString*)note
{
    self.startTimestamp = startTimestamp;
    self.endTimestamp = endTimestamp;
    self.min = min;
    self.calibrationLevel = calibrationLevel;
    self.rating = rating;
    self.duration = duration;
    self.spikes = spikes;
    self.fellAsleepTimestamp = fellAsleep;
    self.note = note;
    return self;
}

@end

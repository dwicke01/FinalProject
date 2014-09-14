//
//  SleepSession.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "SleepDataWrapper.h"

@implementation SleepDataWrapper 

- (id)init :(long)startTimestamp :(long)endTimestamp :(NSMutableArray*) data
{
    self.startTimestamp = startTimestamp;
    self.endTimestamp = [[NSDate date]timeIntervalSince1970];
    self.data = data;
    self.timezone = [NSTimeZone localTimeZone];
    return self;
}



@end

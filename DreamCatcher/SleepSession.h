//
//  SleepSession.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SleepSession : NSObject

@property float calibrationLevel;

@property long endTimestamp;
@property long Id;
@property NSString *note;
@property NSTimeZone *timezone;
@property double min;
@property int rating;
@property int spikes;
@property long duration;
@property long fellAsleepTimestamp;
@property long startTimestamp;
@property int startJulianDay;

@property long createdOn;
@property long updatedOn;

- (id)init :(long)startTimestamp :(long)endTimestamp :(double)min :(float)calibrationLevel :(int)rating :(long)duration :(int)spikes :(long)fellAsleep :(NSString*)note;

- (long)getStartTimeOfDay;


@end

//
//  SleepSession.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SleepPoint.h"

@interface SleepDataWrapper : NSObject

@property double endTimestamp;
@property NSMutableArray *data;
@property NSTimeZone *timezone;
@property double startTimestamp;


- (id)init :(double)startTimestamp :(double)endTimestamp :(NSMutableArray*) data;




@end

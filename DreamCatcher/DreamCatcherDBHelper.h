//
//  DreamCatcherDBHelper.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SleepPoint.h"
#import "SleepDataWrapper.h"

@interface DreamCatcherDBHelper : NSObject
{
    NSString *databasePath;
}/*
+(DreamCatcherDBHelper*)getSharedInstance;
-(BOOL)createDB;
-(void)insertData:(NSString*)startDay :(NSMutableArray *)data;
*/
+(DreamCatcherDBHelper*)getSharedInstance;
-(BOOL)createDB;
-(void)insertData:(SleepDataWrapper*)wrapper;
-(int)getNumPages;
-(int)findPage: (int)page;
-(NSMutableArray*)getData :(int)page;


//-(NSMutableArray*)getData;

@end

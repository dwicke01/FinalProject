//
//  DreamCatcherDBHelper.h
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DreamCatcherDBHelper : NSObject
{
    NSString *databasePath;
}
+(DreamCatcherDBHelper*)getSharedInstance;
-(BOOL)createDB;

@end

//
//  DreamCatcherDBHelper.m
//  DreamCatcher
//
//  Created by Daniel Wickes on 4/14/14.
//  Copyright (c) 2014 Daniel Wickes. All rights reserved.
//

#import "DreamCatcherDBHelper.h"
static DreamCatcherDBHelper *sharedInstance = nil;
static sqlite3 *database = nil;

@implementation DreamCatcherDBHelper


+(DreamCatcherDBHelper*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}


-(BOOL)createDB{
    
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"DreamCatcher.sqlite"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists Sleep_Data_Wrapper (Id integer primary key autoincrement, Timezone text not null, Start_Timestamp timestamp, End_Timestamp timestamp)";
            const char *sql_stmt2 = "create table if not exists data (Id integer, Data_X timestamp, Data_Y double, constraint Id foreign key (Id) references  Sleep_Data_Wrapper (Id) on delete cascade on update cascade)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK || sqlite3_exec(database, sql_stmt2, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create tables");
            }
            sqlite3_close(database);
            void *v;
            char* errmsg;
            const char *pragmaFK = [@"PRAGMA foreign_keys = ON" UTF8String];
            if (sqlite3_exec(database, pragmaFK, 0, v, &errmsg) != SQLITE_OK)
            {
                NSLog(@"failed to set the foreign_key pragma");
            }
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    else
    {
        const char *dbpath = [databasePath UTF8String];
        sqlite3_open(dbpath, &database);
    }
    return isSuccess;
}

-(int)getNumPages
{
    sqlite3_stmt *statement;
    int i = 0;

    if ([self createDB])
    {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT count(Id) FROM Sleep_Data_Wrapper"];
        
        const char *session_select_stmt = [selectSQL UTF8String];
        
        int x = sqlite3_prepare_v2(database, session_select_stmt, -1, &statement, NULL);
        
        
        if (x == SQLITE_OK)
        {
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                i = sqlite3_column_int(statement, 0);
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return i;
}

-(BOOL)findNextPage:(int)page{
    sqlite3_stmt *statement;

    int adjustment = 0;
    NSString *selectSQL = [NSString stringWithFormat:@"SELECT Id FROM Sleep_Data_Wrapper WHERE Id>%d", page+1];
    const char *data_select_stmt = [selectSQL UTF8String];
    int x = sqlite3_prepare_v2(database, data_select_stmt, -1, &statement, NULL);
    if (x == SQLITE_OK)
    {
        sqlite3_step(statement);
        int query = sqlite3_column_int(statement, 0);
        adjustment = query - page - 1;
    }
    sqlite3_finalize(statement);
    
    if (adjustment != 0)
    {
        NSString *updateSQL = [NSString stringWithFormat:@"UPDATE Sleep_Data_Wrapper SET Id = Id-%d WHERE Id>%d", adjustment, page+1];
        const char *update_stmt = [updateSQL UTF8String];
        int x = sqlite3_prepare_v2(database, update_stmt, 1, &statement, NULL);
        if (x == SQLITE_OK)
        {
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            return YES;
        }
        NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
        sqlite3_finalize(statement);
    }
    return NO;
}


-(NSMutableArray*)getData :(int)page{
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    sqlite3_stmt *statement;
    
    if ([self createDB])
    {
        NSString *selectSQL = [NSString stringWithFormat:@"SELECT Data_Y, Data_X FROM Data WHERE Id=%d", page+1];
        const char *data_select_stmt = [selectSQL UTF8String];
        int x = sqlite3_prepare_v2(database, data_select_stmt, -1, &statement, NULL);
        if (x == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(statement, 1)]];
                [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(statement, 0)]];
            }
        }
        if ([data count]==0)
        {
            sqlite3_finalize(statement);
            if ([self findNextPage:page])
            {
                sqlite3_close(database);
                data = [self getData:page];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return data;
}

-(void)insertData:(SleepDataWrapper*)wrapper;
{
    sqlite3_stmt *statement;
    
    if ([self createDB])
    {
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO Sleep_Data_Wrapper (Timezone, Start_Timestamp, End_Timestamp ) VALUES (\"%@\", \"%ld\", \"%ld\")", [[wrapper timezone] name], [wrapper startTimestamp], [wrapper endTimestamp]];
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Wrapper added");
        } else {
            NSLog(@"Wrapper error");
        }
        int rowId = sqlite3_last_insert_rowid(database);
        
        sqlite3_finalize(statement);
        
        for (SleepPoint *sp in [wrapper data])
        {
            NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO data (Id, Data_X, Data_Y) VALUES (\"%d\", \"%f\", \"%f\")", rowId, [sp x], [sp y]];
            
            const char *insert_stmt = [insertSQL UTF8String];
            
            sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                
                NSLog(@"Point added, \nx = %f \ny = %f", [sp x], [sp y]);
            } else {
                NSLog(@"Data error");
                NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
}

@end


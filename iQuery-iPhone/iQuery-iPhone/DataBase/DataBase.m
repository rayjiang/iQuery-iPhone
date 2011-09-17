//
//  DataAccess.m
//  qTrain
//
//  Created by ray on 11-9-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"
#import "TrainScheduleItem.h"

#define kDataBase		 @"Train - 110804.sqlite"
#define kDataBaseName    @"Train - 110804"
#define kDataBaseExt     @"sqlite"

#define TRAIN_ID        0
#define TRAIN_TYPE      1
#define TRAIN_S_NO      2
#define TRAIN_STATION   3
#define TRAIN_DAY       4
#define TRAIN_A_TIME    5
#define TRAIN_D_TIME    6
#define TRAIN_DISTANCE  7
#define TRAIN_P1        8
#define TRAIN_p2        9
#define TRAIN_P3        10
#define TRAIN_P4        11


static DataBase *sharedDataBase = nil;

@implementation DataBase

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		scheduleDB = NULL;
    }
    
    return self;
}

+ (DataBase*)sharedDataBase
{
    @synchronized(self) {
        if (sharedDataBase == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedDataBase;
}
 
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedDataBase == nil) {
            sharedDataBase = [super allocWithZone:zone];
            return sharedDataBase;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}
 
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
 
- (id)retain
{
    return self;
}
 
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
 
- (void)release
{
    //do nothing
}
 
- (id)autorelease
{
    return self;
}

- (void)dealloc {
    [self close];
    [super dealloc];
}

- (void) close
{
	if(scheduleDB) {
		sqlite3_close(scheduleDB);
		scheduleDB = NULL;
	}	
}

- (BOOL) setup
{
	if (scheduleDB) {
		return YES;
	}
	
	NSLog(@"%@", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
	NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *realPath = [documentPath stringByAppendingPathComponent:kDataBase];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:realPath]) {
		NSError *error;
		NSString *sourcePath = [[NSBundle mainBundle] pathForResource:kDataBaseName ofType:kDataBaseExt];
		if (![fileManager copyItemAtPath:sourcePath toPath:realPath error:&error]) {
			NSLog(@"%@", [error localizedDescription]);
			return NO;
		}
	}
	
	NSLog(@"复制sqlite到路径：%@成功。", realPath);
	
	// Open database
	if (sqlite3_open([realPath UTF8String], &scheduleDB) != SQLITE_OK) {
        sqlite3_close(scheduleDB);
		scheduleDB = NULL;
        NSAssert(0, @"Failed to open database");
    }
	
	return YES;
}

- (NSArray *) queryScheduleByFromToStation:(NSString *)fromStation toStation:(NSString *)toStation
{
	NSMutableArray *scheduleInfo = [[[NSMutableArray alloc] init] autorelease];
	
	if(scheduleDB == NULL)
		return scheduleInfo;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
					
	NSString * sqlFromStation = [[NSString alloc] initWithFormat:@"select * from Train where Station like \"%%%@%%\"", fromStation];
	sqlite3_stmt *statementFromStation;
    if (sqlite3_prepare_v2(scheduleDB, [sqlFromStation UTF8String], -1, &statementFromStation, nil) == SQLITE_OK) {
		while (sqlite3_step(statementFromStation) == SQLITE_ROW) {
			char *id = (char *)sqlite3_column_text(statementFromStation, TRAIN_ID);
			char *type = (char *)sqlite3_column_text(statementFromStation, TRAIN_TYPE);
            int sNo = sqlite3_column_int(statementFromStation, TRAIN_S_NO);
			NSString * sqlToStation = [[NSString alloc] initWithFormat:@"select * from Train where ID = \"%s\" and Station like \"%%%@%%\" and S_No > %d", id, toStation, sNo];
			sqlite3_stmt *statementToStation;
			if (sqlite3_prepare_v2(scheduleDB, [sqlToStation UTF8String], -1, &statementToStation, nil) == SQLITE_OK) {
				while (sqlite3_step(statementToStation) == SQLITE_ROW) {			
					NSString *sId = [[NSString alloc] initWithUTF8String:id];
					NSString *sType = [[NSString alloc] initWithUTF8String:type];
                    NSString *sFromStation = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementFromStation, TRAIN_STATION)];
                    NSString *sToStation = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementToStation, TRAIN_STATION)];
					NSString *dTime = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementFromStation, TRAIN_D_TIME)];
					NSString *aTime = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementToStation, TRAIN_A_TIME)];
					
					TrainScheduleItem *item = [[TrainScheduleItem alloc] init];
					item.trainId = sId;
					item.type = sType;
					item.fromStation = sFromStation;
					item.toStation = sToStation;
					item.departureTime = [df dateFromString:dTime];
					item.arriveTime = [df dateFromString:aTime];
                    item.durationDays = sqlite3_column_int(statementToStation, TRAIN_DAY) - sqlite3_column_int(statementFromStation, TRAIN_DAY);
					item.price = sqlite3_column_int(statementToStation, TRAIN_P1) - sqlite3_column_int(statementFromStation, TRAIN_P1);
					[scheduleInfo addObject:item];
					[item release];
					
                    [aTime release];
					[dTime release];
                    [sToStation release];
                    [sFromStation release];
                    [sType release];
					[sId release];			
				}
				sqlite3_finalize(statementToStation);
			}
			[sqlToStation release];
		}
		sqlite3_finalize(statementFromStation);
	}
	
	[sqlFromStation release];
	[df release];
	return scheduleInfo;
}

- (NSArray *) queryScheduleById:(NSString *)trainId
{
	NSMutableArray *scheduleInfo = [[[NSMutableArray alloc] init] autorelease];
	
	if(scheduleDB == NULL)
		return scheduleInfo;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
	NSString * sqlById = [[NSString alloc] initWithFormat:@"select * from Train where ID = \"%@\"", trainId];
	sqlite3_stmt *statementById;
    if (sqlite3_prepare_v2(scheduleDB, [sqlById UTF8String], -1, &statementById, nil) == SQLITE_OK) {
		while (sqlite3_step(statementById) == SQLITE_ROW) {
            int sNo = sqlite3_column_int(statementById, TRAIN_S_NO);
            int days = sqlite3_column_int(statementById, TRAIN_DAY);
            int distance = sqlite3_column_int(statementById, TRAIN_DISTANCE);
            int price = sqlite3_column_int(statementById, TRAIN_P1);
            char *pArriveTime = (char *)sqlite3_column_text(statementById, TRAIN_A_TIME);
            char *pDepartureTime = (char *)sqlite3_column_text(statementById, TRAIN_D_TIME);
            
			NSString *sId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementById, TRAIN_ID)];
			NSString *sType = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementById, TRAIN_TYPE)];
            NSString *sStation = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementById, TRAIN_STATION)];
            
            TrainItem *item = [[TrainItem alloc] init];
            item.trainId = sId;
            item.type = sType;
            item.sNo = sNo;
            item.station = sStation;
                        
            if(pArriveTime != NULL) {
                NSString *aTime = [[NSString alloc] initWithUTF8String:pArriveTime];
                item.arriveTime = [df dateFromString:aTime];
                [aTime release];
            }
            else
                item.arriveTime = nil;
            
            if(pDepartureTime != NULL) {
                NSString *dTime = [[NSString alloc] initWithUTF8String:pDepartureTime];
                item.departureTime = [df dateFromString:dTime];
                [dTime release];
            }
            else
                item.departureTime = nil;
            
            item.days = days;
            item.distance = distance;
            item.price = price;
            
            [scheduleInfo addObject:item];
            [item release];
            
            [sStation release];
            [sType release];
            [sId release];			
		}
		sqlite3_finalize(statementById);
	}
	
	[sqlById release];
	[df release];
	return scheduleInfo;
}

- (NSArray *) queryScheduleByContainedId:(NSString *)trainId
{
	NSMutableArray *scheduleInfo = [[[NSMutableArray alloc] init] autorelease];
	
	if(scheduleDB == NULL)
		return scheduleInfo;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString * sqlById = [[NSString alloc] initWithFormat:@"select * from Train where ID like \"%%%@%%\"", trainId];
	sqlite3_stmt *statementById;
    if (sqlite3_prepare_v2(scheduleDB, [sqlById UTF8String], -1, &statementById, nil) == SQLITE_OK) {
        TrainItem *beginItem = nil;
        TrainItem *endItem = nil;
        while (sqlite3_step(statementById) == SQLITE_ROW) {
            char *pArriveTime = (char *)sqlite3_column_text(statementById, TRAIN_A_TIME);
            char *pDepartureTime = (char *)sqlite3_column_text(statementById, TRAIN_D_TIME);
            
            if(pArriveTime == NULL) {
                beginItem = [self getTrainItem:statementById dateFormat:df];
            }
            else if(pDepartureTime == NULL) {
                endItem = [self getTrainItem:statementById dateFormat:df];
                if([endItem.trainId isEqualToString:beginItem.trainId]) {
                    // Generate train schedule info
                    TrainScheduleItem *item = [[TrainScheduleItem alloc] init];
                    
					item.trainId = endItem.trainId;
					item.type = endItem.type;
					item.fromStation = beginItem.station;
					item.toStation = endItem.station;
					item.departureTime = beginItem.departureTime;
					item.arriveTime = endItem.arriveTime;
                    item.durationDays = endItem.days - beginItem.days;
					item.price = endItem.price - beginItem.price;
                    
					[scheduleInfo addObject:item];
					[item release];
                }
            }
        }
        sqlite3_finalize(statementById);
    }
	
	[sqlById release];
	[df release];
	return scheduleInfo;
}

- (NSArray *) queryScheduleByStation:(NSString *)station
{
    NSMutableArray *scheduleInfo = [[[NSMutableArray alloc] init] autorelease];
	
	if(scheduleDB == NULL)
		return scheduleInfo;
	
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    
    NSString * sqlByStation = [[NSString alloc] initWithFormat:@"select * from Train where Station like \"%%%@%%\"", station];
	sqlite3_stmt *statementByStation;
    if (sqlite3_prepare_v2(scheduleDB, [sqlByStation UTF8String], -1, &statementByStation, nil) == SQLITE_OK) {
        NSString *sPreviousId = nil;
        while (sqlite3_step(statementByStation) == SQLITE_ROW) {
            NSString *sId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statementByStation, TRAIN_ID)];
            if([sId isEqualToString:sPreviousId])
                continue;
            
            // Oh, you got it 
            NSString * sqlById = [[NSString alloc] initWithFormat:@"select * from Train where ID = \"%@\"", sId];
            sqlite3_stmt *statementById;
            if (sqlite3_prepare_v2(scheduleDB, [sqlById UTF8String], -1, &statementById, nil) == SQLITE_OK) {
                TrainItem *beginItem = nil;
                TrainItem *endItem = nil;
                while (sqlite3_step(statementById) == SQLITE_ROW) {
                    char *pArriveTime = (char *)sqlite3_column_text(statementById, TRAIN_A_TIME);
                    char *pDepartureTime = (char *)sqlite3_column_text(statementById, TRAIN_D_TIME);
                    
                    if(pArriveTime == NULL) {
                        beginItem = [self getTrainItem:statementById dateFormat:df];
                    }
                    else if(pDepartureTime == NULL) {
                        endItem = [self getTrainItem:statementById dateFormat:df];
                        if([endItem.trainId isEqualToString:beginItem.trainId]) {
                            // Generate train schedule info
                            TrainScheduleItem *item = [[TrainScheduleItem alloc] init];
                            
                            item.trainId = endItem.trainId;
                            item.type = endItem.type;
                            item.fromStation = beginItem.station;
                            item.toStation = endItem.station;
                            item.departureTime = beginItem.departureTime;
                            item.arriveTime = endItem.arriveTime;
                            item.durationDays = endItem.days - beginItem.days;
                            item.price = endItem.price - beginItem.price;
                            
                            [scheduleInfo addObject:item];
                            [item release];
                        }
                    }
                }
                sqlite3_finalize(statementById);
            }
            [sqlById release];
        }
        sqlite3_finalize(statementByStation);
    }
    
    [sqlByStation release];
    [df release];
	return scheduleInfo;
}

- (id) getTrainItem:(sqlite3_stmt *)statement dateFormat:(NSDateFormatter *)df
{
    int sNo = sqlite3_column_int(statement, TRAIN_S_NO);
    int days = sqlite3_column_int(statement, TRAIN_DAY);
    int distance = sqlite3_column_int(statement, TRAIN_DISTANCE);
    int price = sqlite3_column_int(statement, TRAIN_P1);
    char *pArriveTime = (char *)sqlite3_column_text(statement, TRAIN_A_TIME);
    char *pDepartureTime = (char *)sqlite3_column_text(statement, TRAIN_D_TIME);
    
    NSString *sId = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, TRAIN_ID)];
    NSString *sType = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, TRAIN_TYPE)];
    NSString *sStation = [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text(statement, TRAIN_STATION)];
    
    TrainItem *item = [[[TrainItem alloc] init] autorelease];
    item.trainId = sId;
    item.type = sType;
    item.sNo = sNo;
    item.station = sStation;
    
    if(pArriveTime != NULL) {
        NSString *aTime = [[NSString alloc] initWithUTF8String:pArriveTime];
        item.arriveTime = [df dateFromString:aTime];
        [aTime release];
    }
    else
        item.arriveTime = nil;
    
    if(pDepartureTime != NULL) {
        NSString *dTime = [[NSString alloc] initWithUTF8String:pDepartureTime];
        item.departureTime = [df dateFromString:dTime];
        [dTime release];
    }
    else
        item.departureTime = nil;
    
    item.days = days;
    item.distance = distance;
    item.price = price;
    
    [sStation release];
    [sType release];
    [sId release];	
    
    return item;
}

@end

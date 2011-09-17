//
//  DataAccess.h
//  qTrain
//
//  Created by ray on 11-9-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataBase : NSObject {
    sqlite3 *scheduleDB;
}

+ (DataBase *) sharedDataBase;

- (BOOL) setup;
- (void) close;

- (NSArray *) queryScheduleByFromToStation:(NSString *)fromStation toStation:(NSString *)toStation;
- (NSArray *) queryScheduleById:(NSString *)trainId;
- (NSArray *) queryScheduleByContainedId:(NSString *)trainId;
- (NSArray *) queryScheduleByStation:(NSString *)station;

- (id) getTrainItem:(sqlite3_stmt *)statement dateFormat:(NSDateFormatter *)df;

@end

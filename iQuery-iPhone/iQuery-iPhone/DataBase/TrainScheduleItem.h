//
//  TrainScheduleItem.h
//  qTrain
//
//  Created by ray on 11-9-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainScheduleItem : NSObject{
    NSString *trainId;
	NSString *type;
	NSString *fromStation;
	BOOL	 isOrigin;
	NSString *toStation;
	NSDate   *departureTime;
	NSDate   *arriveTime;
    int      durationDays;
	int		 price;
}

@property (nonatomic, retain) NSString *trainId;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *fromStation;
@property (nonatomic)         BOOL     isOrigin;
@property (nonatomic, retain) NSString *toStation;
@property (nonatomic, retain) NSDate   *departureTime;
@property (nonatomic, retain) NSDate   *arriveTime;
@property (nonatomic)         int      durationDays;
@property (nonatomic)         int      price;

@end

////////////////////////////////////////////////////////

@interface TrainItem : NSObject{
    NSString *trainId;
	NSString *type;
    int      sNo;
	NSString *station;
	NSDate   *departureTime;
	NSDate   *arriveTime;
    int      days;
    int      distance;
	int		 price;
}

@property (nonatomic, retain) NSString *trainId;
@property (nonatomic, retain) NSString *type;
@property (nonatomic)         int      sNo;
@property (nonatomic, retain) NSString *station;
@property (nonatomic, retain) NSDate   *arriveTime;
@property (nonatomic, retain) NSDate   *departureTime;
@property (nonatomic)         int      days;
@property (nonatomic)         int      distance;
@property (nonatomic)         int      price;

@end
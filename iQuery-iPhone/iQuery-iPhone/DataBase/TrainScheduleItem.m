//
//  TrainScheduleItem.m
//  qTrain
//
//  Created by ray on 11-9-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TrainScheduleItem.h"

@implementation TrainScheduleItem

@synthesize trainId;
@synthesize type;
@synthesize fromStation;
@synthesize isOrigin;
@synthesize toStation;
@synthesize departureTime;
@synthesize arriveTime;
@synthesize durationDays;
@synthesize price;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.	
    }
    
    return self;
}

- (void)dealloc {
    [trainId release];    
	[type release];
	[fromStation release];
	[toStation release];
	[departureTime release];
	[arriveTime release];

    [super dealloc];
}

@end

///////////////////////////////

@implementation TrainItem

@synthesize trainId;
@synthesize type;
@synthesize sNo;
@synthesize station;
@synthesize arriveTime;
@synthesize departureTime;
@synthesize days;
@synthesize distance;
@synthesize price;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.	
    }
    
    return self;
}

- (void)dealloc {
    [trainId release];    
	[type release];
	[station release];
    [arriveTime release];
	[departureTime release];
    
    [super dealloc];
}

@end

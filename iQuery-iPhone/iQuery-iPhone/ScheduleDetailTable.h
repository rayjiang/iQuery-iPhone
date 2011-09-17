//
//  ScheduleDetailTable.h
//  qTrain
//
//  Created by ray on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleDetailTable : UITableViewController {
    NSArray *scheduleInfo;
}

@property (nonatomic, retain) NSArray *scheduleInfo;

- (NSString *) GetDayString:(int)days;

@end

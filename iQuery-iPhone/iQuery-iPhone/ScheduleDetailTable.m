//
//  ScheduleDetailTable.m
//  qTrain
//
//  Created by ray on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScheduleDetailTable.h"
#import "TrainScheduleItem.h"


@implementation ScheduleDetailTable

@synthesize scheduleInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scheduleInfo = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [scheduleInfo count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 26.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"ScheduleDetailTableHeader" owner:self options:nil] lastObject];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleDetailCellIdentify";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ScheduleDetailCell" owner:self options:nil];
        if([nib count] > 0)
            cell = [nib objectAtIndex:0];
    }
    
    TrainItem *item = [self.scheduleInfo objectAtIndex:[indexPath row]];
    
    // No.
    UILabel *sNoLabel = (UILabel *)[cell viewWithTag:101];
    sNoLabel.text = [NSString stringWithFormat:@"%d", item.sNo];
    
    // Station
    UILabel *stationLabel = (UILabel *)[cell viewWithTag:102];
    stationLabel.text = item.station;
    
    // Arrive and departure time
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    UILabel *arriveTimeLabel = (UILabel *)[cell viewWithTag:103];
    arriveTimeLabel.text = [timeFormatter stringFromDate:item.arriveTime];
    if([arriveTimeLabel.text length] > 0)
        arriveTimeLabel.text = [NSString stringWithFormat:@"%@%@", [self GetDayString:item.days], arriveTimeLabel.text];
    
    UILabel *departureTimeLabel = (UILabel *)[cell viewWithTag:104];
    departureTimeLabel.text = [timeFormatter stringFromDate:item.departureTime];
    
    [timeFormatter release];
    
    // Distance
    UILabel *distanceLabel = (UILabel *)[cell viewWithTag:105];
    distanceLabel.text = [NSString stringWithFormat:@"%d", item.distance];
    
    return cell;
}

- (NSString *) GetDayString:(int)days
{
    NSString * ret = nil;
    
    switch (days) {
        case 1:
            ret = @"当日";
            break;
        case 2:
            ret = @"次日";
            break;
        case 3:
            ret = @"三日";
            break;
        case 4:
            ret = @"四日";
            break;
        case 5:
            ret = @"五日";
            break;
        case 6:
            ret = @"六日";
            break;
        case 7:
            ret = @"七日";
            break;
        case 8:
            ret = @"八日";
            break;
        case 9:
            ret = @"九日";
            break;
        case 10:
            ret = @"十日";
            break;
        default:
            ret = [NSString stringWithFormat:@"%@日", days];
            break;
    }
    return ret;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end

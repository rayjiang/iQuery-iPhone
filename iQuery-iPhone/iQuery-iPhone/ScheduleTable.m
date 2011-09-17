//
//  ScheduleTable.m
//  qTrain
//
//  Created by ray on 11-9-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScheduleTable.h"
#import "TrainScheduleItem.h"
#import "ScheduleDetailTable.h"
#import "DataBase.h"

@implementation ScheduleTable

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 54.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"ScheduleTableHeader" owner:self options:nil] lastObject];
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.scheduleInfo count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleTableCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ScheduleTableCell" owner:self options:nil];
        if([nib count] > 0)
            cell = [nib objectAtIndex:0];
    }
    
    TrainScheduleItem *item = [self.scheduleInfo objectAtIndex:[indexPath row]];
    
    // Train id
    UILabel *idLabel = (UILabel *)[cell viewWithTag:101];
    idLabel.text = item.trainId;
    
    // Train type
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:102];
    typeLabel.text = item.type;
    
    // From station
    UILabel *fromStationLabel = (UILabel *)[cell viewWithTag:103];
    fromStationLabel.text = item.fromStation;
    
    // To station
    UILabel *toStationLabel = (UILabel *)[cell viewWithTag:104];
    toStationLabel.text = item.toStation;
    
    // Prepare departure and arrive time
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH:mm";
    
    UILabel *departureTimeLabel = (UILabel *)[cell viewWithTag:105];
    departureTimeLabel.text = [timeFormatter stringFromDate:item.departureTime];
    
    UILabel *arriveTimeLabel = (UILabel *)[cell viewWithTag:106];
    arriveTimeLabel.text = [timeFormatter stringFromDate:item.arriveTime];
    
    [timeFormatter release];
    
    // Prepare duration time
    NSTimeInterval interval = [item.arriveTime timeIntervalSinceDate:item.departureTime];
    double seconds = (interval + 24*60*60*item.durationDays);
    int hours = ((int)seconds) / (60*60);
    int minutes = ((int)seconds) % (60*60) / 60;
    NSString *durationTime = [[NSString alloc] initWithFormat:@"%d小时%d分", hours, minutes];
    
    UILabel *timeIntervalLabel = (UILabel *)[cell viewWithTag:107];
    timeIntervalLabel.text = durationTime;
    [durationTime release];
    
    // Price
    NSString *sPrice = [[NSString alloc] initWithFormat:@"¥%d", item.price];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:108];
    priceLabel.text = sPrice;
    [sPrice release];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ScheduleDetailTable *scheduleDetailTable = [[[ScheduleDetailTable alloc] initWithNibName:@"ScheduleDetailTable" bundle:nil] autorelease];
    
    // query
    TrainScheduleItem *item = [self.scheduleInfo objectAtIndex:[indexPath row]];
	scheduleDetailTable.scheduleInfo = [[DataBase sharedDataBase] queryScheduleById:item.trainId];
    
    // Modify title
    if([scheduleDetailTable.scheduleInfo count] > 0) {
        NSString *fromStation  = [[scheduleDetailTable.scheduleInfo objectAtIndex:0] station];
        NSString *toStation  = [[scheduleDetailTable.scheduleInfo lastObject] station];
        scheduleDetailTable.title = [NSString stringWithFormat:@"%@ %@ - %@", item.trainId, fromStation, toStation]; 
    } 
	
    [self.navigationController pushViewController:scheduleDetailTable animated:YES];
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

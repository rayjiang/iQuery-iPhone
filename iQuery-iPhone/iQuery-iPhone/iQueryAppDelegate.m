//
//  iQueryAppDelegate.m
//  iQuery
//
//  Created by ray on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "iQueryAppDelegate.h"
#import "DataBase/DataBase.h"
#import "DataBase/TrainScheduleItem.h"
#import "ScheduleTable.h"

@implementation iQueryAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize ssQueryNavController = _ssQueryNavController;
@synthesize trainIdQueryNavController = _trainIdQueryNavController;
@synthesize stationQueryNavController = _stationQueryNavController;
@synthesize configQueryNavController = _configQueryNavController;
@synthesize trainIdSearchBar = _trainIdSearchBar;
@synthesize stationSearchBar = _stationSearchBar;
@synthesize beginStationSearchbar = _beginStationSearchbar;
@synthesize endStationSearchBar = _endStationSearchBar;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Setup database
	[[DataBase sharedDataBase] setup];
    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    // close database
	[[DataBase sharedDataBase] close];
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [_ssQueryNavController release];
    [_trainIdQueryNavController release];
    [_stationQueryNavController release];
    [_configQueryNavController release];
    [_trainIdSearchBar release];
    [_stationSearchBar release];
    [_beginStationSearchbar release];
    [_endStationSearchBar release];
    [super dealloc];
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(self.ssQueryNavController != viewController)
        [self.ssQueryNavController popToRootViewControllerAnimated:NO];
    
    if(self.trainIdQueryNavController != viewController)
        [self.trainIdQueryNavController popToRootViewControllerAnimated:NO];
    
    if(self.stationQueryNavController != viewController)
        [self.stationQueryNavController popToRootViewControllerAnimated:NO];
    
    CATransition* animation = [CATransition animation]; 
    [animation setDuration:0.5f]; 
    [animation setType:@"cube"]; 
    [animation setSubtype:kCATransitionFromRight]; 
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]]; 
    [[self.tabBarController.view layer]addAnimation:animation forKey:@"switchView"]; 
}


// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}

// called when keyboard search button pressed 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                      
{  
    [searchBar resignFirstResponder]; 
    
    // query
    if(searchBar == self.trainIdSearchBar) {
        ScheduleTable *scheduleTable = [[[ScheduleTable alloc] initWithNibName:@"ScheduleTable" bundle:nil] autorelease];
        scheduleTable.title = [searchBar text];
        scheduleTable.scheduleInfo = [[DataBase sharedDataBase] queryScheduleByContainedId:[searchBar text]];
        [self.trainIdQueryNavController pushViewController:scheduleTable animated:YES];
    }
    else if(searchBar == self.stationSearchBar) {
        ScheduleTable *scheduleTable = [[[ScheduleTable alloc] initWithNibName:@"ScheduleTable" bundle:nil] autorelease];
        scheduleTable.title = [searchBar text];
        scheduleTable.scheduleInfo = [[DataBase sharedDataBase] queryScheduleByStation:[searchBar text]];
        [self.stationQueryNavController pushViewController:scheduleTable animated:YES];
    }
    else if(searchBar == self.beginStationSearchbar) {
        if(![self doFromToStationQuery])
            [self.endStationSearchBar becomeFirstResponder];
    }
    else if(searchBar == self.endStationSearchBar) {
        if(![self doFromToStationQuery])
            [self.beginStationSearchbar becomeFirstResponder];
    }
}  

//cancel button clicked...  
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{  
    [searchBar resignFirstResponder];
}

- (IBAction)switchStations:(id)sender {
    NSString *beginStation = self.beginStationSearchbar.text;
    self.beginStationSearchbar.text = self.endStationSearchBar.text;
    self.endStationSearchBar.text = beginStation;
    
    [self doFromToStationQuery];
}

- (IBAction)backgroundClick:(id)sender {
    // Close keyboard
    [self.beginStationSearchbar resignFirstResponder];
    [self.endStationSearchBar resignFirstResponder];
    [self.trainIdSearchBar resignFirstResponder];
    [self.stationSearchBar resignFirstResponder];
}

- (Boolean) doFromToStationQuery
{
    if([self.beginStationSearchbar.text length] > 0 && [self.endStationSearchBar.text length] > 0) {
        ScheduleTable *scheduleTable = [[[ScheduleTable alloc] initWithNibName:@"ScheduleTable" bundle:nil] autorelease];
        scheduleTable.title = [NSString stringWithFormat:@"%@ - %@", self.beginStationSearchbar.text, self.endStationSearchBar.text];
        scheduleTable.scheduleInfo = [[DataBase sharedDataBase] queryScheduleByFromToStation:self.beginStationSearchbar.text toStation:self.endStationSearchBar.text];
        [self.ssQueryNavController pushViewController:scheduleTable animated:YES];
        return YES;
    }
    return NO;
}

@end

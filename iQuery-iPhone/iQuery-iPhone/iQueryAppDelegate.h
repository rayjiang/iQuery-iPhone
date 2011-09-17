//
//  iQueryAppDelegate.h
//  iQuery
//
//  Created by ray on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iQueryAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UISearchBarDelegate> {
    UINavigationController *_ssQueryNavController;
    UINavigationController *_trainIdQueryNavController;
    UINavigationController *_stationQueryNavController;
    UINavigationController *_configQueryNavController;
    UISearchBar *_trainIdSearchBar;
    UISearchBar *_stationSearchBar;
}


@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) IBOutlet UINavigationController *ssQueryNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *trainIdQueryNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *stationQueryNavController;
@property (nonatomic, retain) IBOutlet UINavigationController *configQueryNavController;
@property (nonatomic, retain) IBOutlet UISearchBar *trainIdSearchBar;
@property (nonatomic, retain) IBOutlet UISearchBar *stationSearchBar;

@end

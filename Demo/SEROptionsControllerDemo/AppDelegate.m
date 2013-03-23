//
//  AppDelegate.m
//  SEROptionsControllerDemo
//
//  Created by Stanley Rost on 23.03.13.
//  Copyright (c) 2013 Stanley Rost. All rights reserved.
//

#import "AppDelegate.h"
#import "SEROptionsControllerDemoViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
  
    UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:[SEROptionsControllerDemoViewController new]];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.window.rootViewController = navigationController;
    return YES;
}

@end

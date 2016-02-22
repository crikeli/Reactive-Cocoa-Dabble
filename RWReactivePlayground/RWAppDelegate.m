//
//  RWAppDelegate.m
//  Reactive Cocoa Example
//
//  Created by Kelin Christi on 21/02/2016.
//  Copyright (c) 2016 Kelz. All rights reserved.
//

#import "RWAppDelegate.h"

@implementation RWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // style the navigation bar
  UIColor* navColor = [UIColor colorWithRed:0.175f green:0.458f blue:0.831f alpha:1.0f];
  [[UINavigationBar appearance] setBarTintColor:navColor];
  [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
  
  // make the status bar white
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
  
  
  return YES;
}

@end

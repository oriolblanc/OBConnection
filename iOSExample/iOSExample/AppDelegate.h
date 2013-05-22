//
//  AppDelegate.h
//  iOSExample
//
//  Created by Oriol Blanc on 09/09/12.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OBConnection/OBConnection.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end

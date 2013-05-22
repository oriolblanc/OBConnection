//
//  SIAppDelegate.m
//  MacOSXExample
//
//  Created by Giuseppe Basile on 22/05/13.
//  Copyright (c) 2013 Archy. All rights reserved.
//

#import "SIAppDelegate.h"
#import "ViewController.h"
#import <OBConnection/OBConnection.h>

@implementation SIAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [OBConnection registerWithBaseUrl:[NSURL URLWithString:@"http://httpbin.org"]
                 responseHandlerBlock:^BOOL(NSDictionary *JSON, NSDictionary *headerFields) {
                     
                     // If you need check headers.
                     return YES;
                 }];
    
    NSViewController *vc = [[ViewController alloc] init];
    [self.window.contentView addSubview: vc.view];
}

@end

//
//  ViewController.m
//  iOSExample
//
//  Created by Oriol Blanc on 09/09/12.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
    - (IBAction)getIPButtonPressed:(id)sender;
    @property (retain, nonatomic) IBOutlet UILabel *ipLabel;
@end

@implementation ViewController

- (IBAction)getIPButtonPressed:(id)sender
{
    self.ipLabel.text = @"";
    
    OBRequest *getIPRequest = [OBRequest requestWithType:OBRequestMethodTypeMethodGET resource:@"ip" parameters:nil files:nil isPublic:YES];
    
    [OBConnection makeRequest:getIPRequest success:^(id data, BOOL cached) {
        self.ipLabel.text = [data objectForKey:@"origin"];
    } error:^(id data, NSError *error) {
        self.ipLabel.text = @"error";
    }];
}

- (void)dealloc {
    [_ipLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setIpLabel:nil];
    [super viewDidUnload];
}

@end

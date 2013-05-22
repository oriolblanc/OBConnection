//
//  ViewController.m
//  MacOSXExample
//
//  Created by Giuseppe Basile on 22/05/13.
//  Copyright (c) 2013 Archy. All rights reserved.
//

#import "ViewController.h"
#import <OBConnection/OBConnection.h>

@interface ViewController ()
@property (assign) IBOutlet NSTextField *ipLabel;
- (IBAction)getIPButtonPressed:(id)sender;
- (IBAction)putImageButtonPressed:(id)sender;
@property (assign) IBOutlet NSTextView *putImageLogLabel;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init
{
    if ((self = [super initWithNibName:@"ViewController" bundle:nil])) {
        // additional view controller initialization
    }
    
    return self;
}
- (IBAction)getIPButtonPressed:(id)sender
{
    self.ipLabel.stringValue = @"";
    
    OBRequest *getIPRequest = [OBRequest requestWithType:OBRequestMethodTypeMethodGET resource:@"ip" parameters:nil files:nil isPublic:YES];
    
    [OBConnection makeRequest:getIPRequest success:^(id data, BOOL cached) {
        self.ipLabel.stringValue = [data objectForKey:@"origin"];
    } error:^(id data, NSError *error) {
        self.ipLabel.stringValue = @"error";
    }];
}

- (IBAction)putImageButtonPressed:(id)sender
{
    self.putImageLogLabel.string = @"";
    
    OBRequestParameters *fileParam = [[OBRequestParameters alloc] init];
    NSString *iconPath = [[NSBundle mainBundle]
                           pathForResource:@"image" ofType:@"png"];
    NSImage *inputImage = [[NSImage alloc] initWithContentsOfFile:iconPath];
    [fileParam setValue:inputImage forKey:@"image"];
    
    OBRequest *getIPRequest = [OBRequest requestWithType:OBRequestMethodTypeMultiForm resource:@"post" parameters:nil files:fileParam isPublic:YES];
    
    [OBConnection makeRequest:getIPRequest success:^(id data, BOOL cached) {
        NSData *imageData = [[data objectForKey:@"files"] objectForKey:@"image"];
        self.putImageLogLabel.string = [imageData description];
    } error:^(id data, NSError *error) {
        self.putImageLogLabel.string = @"error";
    }];

}
@end

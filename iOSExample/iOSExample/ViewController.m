//
//  ViewController.m
//  iOSExample
//
//  Created by Oriol Blanc on 09/09/12.
//  Copyright (c) 2012 Oriol Blanc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
    - (IBAction)uploadButtonPressed:(id)sender;
@end

@implementation ViewController

- (IBAction)uploadButtonPressed:(id)sender
{
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    [self presentModalViewController:picker animated:YES];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage * image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [picker dismissModalViewControllerAnimated:YES];
    
}


@end

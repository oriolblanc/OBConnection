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
    - (void)uploadImage:(UIImage *)imageToUpload;
@end

@implementation ViewController

- (IBAction)uploadButtonPressed:(id)sender
{
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    [self presentModalViewController:picker animated:YES];
}

- (void)uploadImage:(UIImage *)imageToUpload
{
    OBRequestParameters *parameters = [OBRequestParameters emptyRequestParameters];
    [parameters setValue:@"8a7539e238429a6b0138429b3b0a0001" forKey:@"userId"];
    
    OBRequestParameters *files = [OBRequestParameters emptyRequestParameters];
    [files setValue:imageToUpload forKey:@"avatar"];
    
    OBRequest *uploadImageRequest = [OBRequest requestWithType:OBRequestMethodTypeMultiForm resource:@"post.php?dir=example" parameters:parameters files:files isPublic:YES];
    
    [OBConnection makeRequest:uploadImageRequest success:^(id data, BOOL cached) {
        NSLog(@"success");
    } error:^(id data, NSError *error) {
        NSLog(@"error");
    }];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    // Access the uncropped image from info dictionary
    UIImage * image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self uploadImage:image];
}


@end

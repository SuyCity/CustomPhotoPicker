//
//  YCViewController.m
//  YCPhotoPicker
//
//  Created by Suycity on 01/26/2016.
//  Copyright (c) 2016 Suycity. All rights reserved.
//

#import "YCViewController.h"
#import <YCPhotoPicker/YCPhotoPicker.h>
@interface YCViewController ()

@end

@implementation YCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)selectPhotoPickerEvent:(id)sender{
    [YCPhotoPickerController openPhotoPickerRootViewController:self maxOption:3 result:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/19.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "ViewController.h"
#import "YCPhotoPicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)clickBtnEvent:(id)sender{
    [YCPhotoPickerController openPhotoPickerRootViewController:self maxOption:3 result:^(NSArray *infos) {
        NSLog(@"--> %@",infos);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

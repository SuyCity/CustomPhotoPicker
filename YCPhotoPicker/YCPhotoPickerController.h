//
//  YCPhotoPickerController.h
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCPhotoPickerController : UIViewController
@property (nonatomic, assign) NSUInteger maxOption;
@property (nonatomic, copy) void(^didSelectedPhotosBlock)(NSArray *photos);

- (void)dismissViewController;

+ (void)openPhotoPickerRootViewController:(UIViewController *)rootController maxOption:(NSUInteger)maxOption result:(void(^)(NSArray *result))resultBlock;
@end

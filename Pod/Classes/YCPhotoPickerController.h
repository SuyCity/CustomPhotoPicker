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

/**
 *  触发Block的取消视图
 */
- (void)dismissViewController;
/**
 *  取消视图
 */
- (void)dismiss;

/**
 *  将相册组件推到视图上显示
 *
 *  @param rootController UIViewController
 *  @param maxOption      可选上限
 *  @param resultBlock    结果
 */
+ (void)openPhotoPickerRootViewController:(UIViewController *)rootController maxOption:(NSUInteger)maxOption result:(void(^)(NSArray *result))resultBlock;
/**
 *  将相册组件推到视图上显示
 *
 *  @param rootController UIViewController
 *  @param maxOption      可选上限
 *  @param selectedOption 已选数组，
 *  @param resultBlock    结果
 */
+ (void)openPhotoPickerRootViewController:(UIViewController *)rootController maxOption:(NSUInteger)maxOption selectedOption:(NSArray<NSDictionary *> *)selectedOption result:(void(^)(NSArray *result))resultBlock;
@end

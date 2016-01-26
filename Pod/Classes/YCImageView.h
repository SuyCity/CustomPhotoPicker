//
//  YCImageView.h
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface YCImageView : UIImageView

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isTapAddAsset;

- (void)updateSelected;
- (void)setImage:(UIImage *)image withTapBlock:(void(^)(ALAsset *asset))tapBlock;
- (void)setImage:(UIImage *)image asset:(ALAsset *)asset withTapBlock:(void(^)(ALAsset *asset))tapBlock;
@end

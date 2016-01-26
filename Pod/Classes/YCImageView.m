//
//  YCImageView.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCImageView.h"
#import "YCPhotoPickerManager.h"

@interface YCImageView ()
@property (nonatomic, strong) UIButton *checkMarkBtn;
@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, copy) void(^didTapBlock)(ALAsset *asset);
@end

@implementation YCImageView

- (void)tapEvent:(id)sender{
    if (self.didTapBlock) {
        self.didTapBlock(self.asset);
    }
    if (self.isTapAddAsset && self.checkMarkBtn) {
        [self checkMarkEvent:self.checkMarkBtn];
    }
}
- (void)checkMarkEvent:(UIButton *)sender{
    if (!sender.selected) {
        if ([[YCPhotoPickerManager sharedManager] addAssets:self.asset]) {
            sender.selected = !sender.selected;
        };
    }
    else{
        [[YCPhotoPickerManager sharedManager] removeAssets:self.asset];
        sender.selected = !sender.selected;
    }
    self.isSelected = sender.selected;
}
- (void)setImage:(UIImage *)image withTapBlock:(void(^)(ALAsset *asset))tapBlock{
    [self setImage:image asset:self.asset withTapBlock:tapBlock];
}
- (void)setImage:(UIImage *)image asset:(ALAsset *)asset withTapBlock:(void(^)(ALAsset *asset))tapBlock{
    [self setImage:image];
    self.asset = asset;
    
    BOOL isTapGes = NO;
    for (UIGestureRecognizer *gesture in [self gestureRecognizers]) {
        if (gesture.view == self && [gesture respondsToSelector:@selector(tapEvent:)]) {
            isTapGes = YES;
        }
    }
    if (!isTapGes) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [tap addTarget:self action:@selector(tapEvent:)];
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
    }
    self.didTapBlock = tapBlock;
    
    if ([[asset valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypeVideo]){
        [self assetPropertyVideo:asset];
        [self.checkMarkBtn setHidden:YES];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20]];
    }else if([[asset valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]){
        if (!self.checkMarkBtn && self.asset) {
            self.checkMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            
            [self.checkMarkBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"YCPhotoPicker.bundle/BRNImagePickerSheet-checkmark@2x" ofType:@"png"]]
                               forState:UIControlStateNormal];
            [self.checkMarkBtn setImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"YCPhotoPicker.bundle/BRNImagePickerSheet-selected@2x" ofType:@"png"]]
                               forState:UIControlStateSelected];
            [self.checkMarkBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.checkMarkBtn addTarget:self action:@selector(checkMarkEvent:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:self.checkMarkBtn];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkMarkBtn attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:-10]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.checkMarkBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:10]];
            CGSize size = self.checkMarkBtn.imageView.image.size;
            
            [self.checkMarkBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.checkMarkBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.width]];
            
            [self.checkMarkBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.checkMarkBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:size.height]];
        }
        [self.checkMarkBtn setHidden:NO];
        [self.videoView setHidden:YES];
        [self updateSelected];
    }
}
- (void)updateSelected{
    self.checkMarkBtn.selected = [[YCPhotoPickerManager sharedManager] isEqualAssets:self.asset];
}
- (void)assetPropertyVideo:(ALAsset *)asset{
    
    if (!self.videoView) {
        self.videoView = [[UIView alloc] init];
        [self.videoView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.videoView];
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"YCPhotoPicker.bundle/AV_Video_Highlight@2x" ofType:@"png"]]];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.videoView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTag:10];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextAlignment:NSTextAlignmentRight];
        [self.videoView addSubview:label];
        
        /**
         *   imageView
         */
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeLeading multiplier:1 constant:5]];
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:16]];
        
        [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        /**
         *  label
         */
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeTrailing multiplier:1 constant:-5]];
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.videoView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        
        [self.videoView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    }
    
    UILabel *label = [self.videoView viewWithTag:10];
    [label setText:[self getTimeWith:[[asset valueForProperty:ALAssetPropertyDuration] intValue]]];
    [self.videoView setHidden:NO];
}
- (NSString *)getTimeWith:(NSInteger)secCount;
{
    NSString *tmphh = [NSString stringWithFormat:@"%.2ld",(long)secCount/3600];
    NSString *tmpmm = [NSString stringWithFormat:@"%.2ld",(long)(secCount/60)%60];
    NSString *tmpss = [NSString stringWithFormat:@"%.2ld",(long)secCount%60];
    if (secCount/3600>0) {
        return  [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
    }else if ((secCount/60)%60>0) {
        return  [NSString stringWithFormat:@"%@:%@",tmpmm,tmpss];
    }else if (secCount%60>0) {
        return  [NSString stringWithFormat:@"%@:%@",tmpmm,tmpss];
    }
    return  [NSString stringWithFormat:@"%@:%@:%@",tmphh,tmpmm,tmpss];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

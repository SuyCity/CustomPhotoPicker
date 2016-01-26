//
//  YCPhotoPickerManager.h
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/19.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

#define YC_PHOTO_PICKER_UPDATE @"__YC_PHOTO_PICKER_UPDATE"

typedef const NSString *ALAssetPropertyURL;

@interface YCPhotoPickerManager : NSObject

@property (nonatomic, assign) NSUInteger maxOption;
@property (nonatomic, readonly, strong) NSDictionary *groups;
@property (nonatomic, strong) UIViewController *parentViewController;

+ (instancetype)sharedManager;

- (void)setGroupsWithAll:(void(^)(NSDictionary *,NSError *))resultBlock;
- (void)setAssetWithUrl:(NSString *)url result:(void(^)(ALAsset *,NSError *))result;

- (void)getResultBlock:(void(^)(NSArray *))resultBlock;

- (BOOL)addAssetsURL:(NSString *)url;
- (BOOL)addAssets:(ALAsset *)asset;
- (void)removeAssets:(ALAsset *)asset;
- (void)removeAssetsAll;
- (NSArray *)getSelectedAsstes;
- (BOOL)isEqualAssets:(ALAsset *)asset;
@end

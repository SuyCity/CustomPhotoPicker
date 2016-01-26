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
#define YC_PHOTO_PICKER_MaxOption_Error @"__YC_PHOTO_PICKER_MaxOption_Error"

extern NSString *const YCAssetPropertyURL;
extern NSString *const YCAssetPropertyType;
extern NSString *const YCAssetPropertyDuration;
extern NSString *const YCAssetPropertyLocation;
extern NSString *const YCAssetPropertyImage;
extern NSString *const YCAssetPropertyUIT;

@interface YCPhotoPickerManager : NSObject

@property (nonatomic, assign) NSUInteger maxOption;
@property (nonatomic, readonly, strong) NSDictionary *groups;
@property (nonatomic, strong) UIViewController *parentViewController;

+ (instancetype)sharedManager;

- (void)setGroupsWithAll:(void(^)(NSDictionary *,NSError *))resultBlock;
/**
 *  根据在相册的URL获取到Image信息
 *
 *  @param url    资源URL
 *  @param result Block
 */
- (void)setAssetWithUrl:(NSString *)url result:(void(^)(ALAsset *,NSError *))result;
/**
 *  获取到已选的相册信息
 */
- (void)getResultBlock:(void(^)(NSArray *))resultBlock;

- (BOOL)addAssetsURL:(NSString *)url;
- (BOOL)addAssets:(ALAsset *)asset;
- (void)removeAssets:(ALAsset *)asset;
- (void)removeAssetsAll;
- (NSArray *)getSelectedAsstes;
- (BOOL)isEqualAssets:(ALAsset *)asset;
@end

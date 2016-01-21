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

@interface YCPhotoPickerManager : NSObject

@property (nonatomic, assign) NSUInteger maxOption;
@property (nonatomic, readonly, strong) NSDictionary *groups;

+ (instancetype)sharedManager;

- (void)setGroupsWithAll:(void(^)(NSDictionary *,NSError *))resultBlock;
- (void)setAssetWithUrl:(NSString *)url result:(void(^)(ALAsset *,NSError *))result;


- (BOOL)addAssets:(ALAsset *)asset;
- (void)removeAssets:(ALAsset *)asset;
- (NSArray *)getSelectedAsstes;
- (BOOL)isEqualAssets:(ALAsset *)asset;
@end

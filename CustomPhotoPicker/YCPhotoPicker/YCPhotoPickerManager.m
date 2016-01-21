//
//  YCPhotoPickerManager.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/19.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCPhotoPickerManager.h"

@interface YCPhotoPickerManager ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@end
@implementation YCPhotoPickerManager

+ (instancetype)sharedManager
{
    static YCPhotoPickerManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YCPhotoPickerManager alloc] init];
    });
    
    return instance;
}
- (instancetype)init{
    if (self = [super init]) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)setGroupsWithAll:(void(^)(NSDictionary *,NSError *))resultBlock{
    if ([self getErrorDescription:[ALAssetsLibrary authorizationStatus]]) {
        NSMutableDictionary *groups = [NSMutableDictionary dictionary];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if(group){
                [groups setObject:group forKey:[group valueForProperty:ALAssetsGroupPropertyPersistentID]];
            }else{
                if(resultBlock)
                    resultBlock(groups,nil);
                _groups = [NSDictionary dictionaryWithDictionary:groups];
            }
        } failureBlock:^(NSError *error) {
            if(resultBlock) resultBlock(groups,nil);
        }];
    }
}
- (void)setAssetWithUrl:(NSString *)url result:(void(^)(ALAsset *,NSError *))result{
    [self.assetsLibrary assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *asset) {
        if(result) result (asset ,nil);
    } failureBlock:^(NSError *error) {
        if(result) result (nil ,error);
    }];
}

- (BOOL)getErrorDescription:(ALAuthorizationStatus)status
{
    NSString *errorMsg = nil;
    if (status == ALAuthorizationStatusNotDetermined) {
        errorMsg = @"Error: User has not responded to the permissions alert.\n";
    }
    if (status == ALAuthorizationStatusDenied) {
        errorMsg = @"Error: User has denied this app permissions to access device Assets.\n";
    }
    if (status == ALAuthorizationStatusRestricted) {
        errorMsg = @"Error: User is restricted from using Assets services by a usage policy.\n";
    }
    if(errorMsg)NSLog(@"--> %@",errorMsg);
    return status == ALAuthorizationStatusNotDetermined || status
     == ALAuthorizationStatusAuthorized;
}

#pragma mark - 
- (BOOL)addAssets:(ALAsset *)asset{
    if (!self.selectedAssets) {
        self.selectedAssets = [NSMutableArray array];
    }
    if (self.maxOption < [self.selectedAssets count] || self.maxOption == 0) {
        [self.selectedAssets addObject:[[[asset defaultRepresentation] url] absoluteString]];
        return YES;
    }
    return NO;
}
- (void)removeAssets:(ALAsset *)asset{
    [self.selectedAssets removeObject:[[[asset defaultRepresentation] url] absoluteString]];
}
- (NSArray *)getSelectedAsstes{
    return self.selectedAssets;
}
- (BOOL)isEqualAssets:(ALAsset *)asset{
    return self.selectedAssets && [self.selectedAssets indexOfObject:[[[asset defaultRepresentation] url] absoluteString]] != NSNotFound;
}
@end

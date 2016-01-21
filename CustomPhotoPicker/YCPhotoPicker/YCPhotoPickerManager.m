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
#pragma mark - Sender Photo
- (void)dissmissViewController:(void(^)(NSArray *))resultBlock{
    __block NSMutableArray *imageArray  = [NSMutableArray array];
    [[self getSelectedAsstes] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            [self.assetsLibrary assetForURL:[NSURL URLWithString:obj] resultBlock:^(ALAsset *result) {
                NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                NSString *type = [result valueForProperty:ALAssetPropertyType] ;
                NSString *location = [result valueForProperty:ALAssetPropertyLocation];
                NSString *duration = [result valueForProperty:ALAssetPropertyDuration];
                ALAssetRepresentation* representation = [result defaultRepresentation];
                NSString* uit = [representation filename];
                NSString *url = [[[result defaultRepresentation]url]description];
                UIImage *image=[UIImage imageWithCGImage:result.aspectRatioThumbnail];
                [dict setValue:image forKey:@"image"];
                [dict setValue:location forKey:@"location"];
                [dict setValue:duration forKey:@"duration"];
                [dict setValue:type forKey:@"type"];
                [dict setValue:url forKey:@"url"];
                [dict setValue:uit forKey:@"uit"];
                [imageArray addObject:dict];
            } failureBlock:^(NSError *error) {
                
            }];
        }
        else{
            if(resultBlock) resultBlock(imageArray);
        }
    }];
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Assets
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

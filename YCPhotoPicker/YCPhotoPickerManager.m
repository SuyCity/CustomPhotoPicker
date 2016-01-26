//
//  YCPhotoPickerManager.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/19.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCPhotoPickerManager.h"

NSString *const YCAssetPropertyURL = @"__YCAssetPropertyURL";
NSString *const YCAssetPropertyType = @"__YCAssetPropertyType";
NSString *const YCAssetPropertyDuration = @"__YCAssetPropertyDuration";
NSString *const YCAssetPropertyLocation = @"__YCAssetPropertyLocation";
NSString *const YCAssetPropertyImage = @"__YCAssetPropertyImage";
NSString *const YCAssetPropertyUIT = @"__YCAssetPropertyUIT";

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
- (void)getResultBlock:(void(^)(NSArray *))resultBlock{
    __block NSMutableArray *imageArray  = [NSMutableArray array];
    NSArray *selectedAsstes = [self getSelectedAsstes];
    [selectedAsstes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                [dict setValue:image forKey:YCAssetPropertyImage];
                [dict setValue:location forKey:YCAssetPropertyLocation];
                [dict setValue:duration forKey:YCAssetPropertyDuration];
                [dict setValue:type forKey:YCAssetPropertyType];
                [dict setValue:url forKey:YCAssetPropertyURL];
                [dict setValue:uit forKey:YCAssetPropertyUIT];
                [imageArray addObject:dict];
                
                if ([selectedAsstes count] - 1 == idx) {
                    if(resultBlock) resultBlock(imageArray);
                }
                
            } failureBlock:^(NSError *error) {
                if ([selectedAsstes count] - 1 == idx) {
                    if(resultBlock) resultBlock(imageArray);
                }
            }];
        }
    }];
}
#pragma mark - Assets
- (BOOL)addAssetsURL:(NSString *)url{
    if (!self.selectedAssets) {
        self.selectedAssets = [NSMutableArray array];
    }
    int count = (int)[self.selectedAssets count];
    if ( count < self.maxOption || !self.maxOption) {
        [self.selectedAssets addObject:url];
        [[NSNotificationCenter defaultCenter] postNotificationName:YC_PHOTO_PICKER_UPDATE object:nil];
        return YES;
    }
    else{
        NSLog(@"%@",[NSString stringWithFormat:@"You can select %d photos",self.maxOption]);
    }
    return NO;
}
- (BOOL)addAssets:(ALAsset *)asset{
    return [self addAssetsURL:[[[asset defaultRepresentation] url] absoluteString]];
}
- (void)removeAssets:(ALAsset *)asset{
    if ([self isEqualAssets:asset]) {
        [self.selectedAssets removeObject:[[[asset defaultRepresentation] url] absoluteString]];
        [[NSNotificationCenter defaultCenter] postNotificationName:YC_PHOTO_PICKER_UPDATE object:nil];
    }
}
- (void)removeAssetsAll{
    [self.selectedAssets removeAllObjects];
}
- (NSArray *)getSelectedAsstes{
    return self.selectedAssets;
}
- (BOOL)isEqualAssets:(ALAsset *)asset{
    return self.selectedAssets && [self.selectedAssets indexOfObject:[[[asset defaultRepresentation] url] absoluteString]] != NSNotFound;
}
@end

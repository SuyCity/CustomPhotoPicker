//
//  YCPhotoPickerController.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCPhotoPickerController.h"
#import "YCPhotoPickerManager.h"
#import "YCImageView.h"
#import "YCAlbumController.h"

#define DEFINE_TABLEVIEW_HEADER_HEIGHT 150

@interface YCPhotoPickerController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *tableHeaderView;
@property (nonatomic, strong) UIView *orangeColorView;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) NSArray *headerImages;
@end

@implementation YCPhotoPickerController
@synthesize maxOption = _maxOption;

#pragma mark - +
+ (void)openPhotoPickerRootViewController:(UIViewController *)rootController maxOption:(NSUInteger)maxOption result:(void(^)(NSArray *result))resultBlock{
    YCPhotoPickerController *photoPicker = [[YCPhotoPickerController alloc] init];
    photoPicker.maxOption = maxOption;
    photoPicker.didSelectedPhotosBlock = resultBlock;
    [rootController presentViewController:photoPicker animated:YES completion:nil];
}
#pragma mark - Set/Get
- (void)setMaxOption:(NSUInteger)maxOption{
    if (_maxOption != maxOption) {
        _maxOption = maxOption;
        [[YCPhotoPickerManager sharedManager] setMaxOption:maxOption];
    }
}
#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    [YCPhotoPickerManager sharedManager];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIView *orangeColorView = [[UIView alloc] init];
    [orangeColorView setBackgroundColor:[UIColor clearColor]];
    [orangeColorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(dismissViewController)];
    
    [orangeColorView addGestureRecognizer:tap];
    [self.view addSubview:orangeColorView];
    
    self.orangeColorView = orangeColorView;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.orangeColorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.orangeColorView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.orangeColorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];//[YCPhotoPickerController opaqueColorWithRGBBytes:0xe5e5e5];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setScrollEnabled:NO];
    
    if([tableView respondsToSelector:@selector(setSeparatorInset:)]){
        tableView.separatorInset = UIEdgeInsetsZero;
    }
    if([tableView respondsToSelector:@selector(setLayoutMargins:)]){
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.orangeColorView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44 * 3 + 150]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop  multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    self.tableHeaderView = [[UIScrollView alloc] initWithFrame:(CGRect){0,0,DEFINE_TABLEVIEW_HEADER_HEIGHT,CGRectGetHeight(self.view.frame)}];
    [self.tableHeaderView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = _tableHeaderView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[YCPhotoPickerManager sharedManager] setGroupsWithAll:^(NSDictionary *infos, NSError *error) {
            ALAssetsGroup *group = nil;
            for (NSString *key in infos) {
                if ([[infos[key] valueForProperty:ALAssetsGroupPropertyType] isEqual:@(ALAssetsGroupSavedPhotos)]) {
                    group = infos[key];
                }
            }
            if (group) {
                NSMutableArray *headerImages = [NSMutableArray array];
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if(result)[headerImages addObject:result];
                    if ([headerImages count] >= 20 || !result) {
                        *stop = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.headerImages = headerImages;
                            [self addImagesToScrollView];
                        });
                    }
                }];
            }
        }];
    });
    // Do any additional setup after loading the view.
}
#pragma mark - 
- (void)addImagesToScrollView{
    
    UIView *conentView = [[UIView alloc] init];
    [conentView setBackgroundColor:[UIColor clearColor]];
    [conentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tableHeaderView addSubview:conentView];
    
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:conentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.tableHeaderView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:conentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableHeaderView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:conentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableHeaderView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:conentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.tableHeaderView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    UIView *lastView = conentView;
    CGFloat height = DEFINE_TABLEVIEW_HEADER_HEIGHT;
    for (ALAsset *asset in self.headerImages) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        CGSize size = [representation dimensions];
        UIImage *image =[UIImage imageWithCGImage:asset.thumbnail];
        
        YCImageView *imageView = [[YCImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setImage:image asset:asset withTapBlock:nil];
        [imageView setIsTapAddAsset:YES];
        [conentView addSubview:imageView];
        
        [conentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:lastView attribute:(lastView == conentView ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing) multiplier:1 constant:(lastView == conentView ? 0 : 5)]];
        
        [conentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:conentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        
        [conentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:conentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height]];
        
        [imageView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:size.width/size.height constant:0]];
        lastView = imageView;
    }
    [conentView addConstraint:[NSLayoutConstraint constraintWithItem:lastView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:conentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    UIView *header = self.tableHeaderView;
    
    [conentView setNeedsUpdateConstraints];
    [conentView updateConstraintsIfNeeded];
    
    CGFloat width = [conentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].width;
    CGRect frame = conentView.frame;
    
    frame.size.height = height;
    frame.size.width = width;
    header.frame = frame;
    self.tableView.tableHeaderView = header;
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section ? 10 : 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    int count = (int)[[[YCPhotoPickerManager sharedManager] getSelectedAsstes] count];
    NSString *title = @"拍照";
    if (count) {
        title = [NSString stringWithFormat:@"发送%d张",count];
    }
    cell.textLabel.text = @[title,@"相册",@"取消"][indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if ([[[YCPhotoPickerManager sharedManager] getSelectedAsstes] count]){
            
        }
        else{

        }
    }else if (indexPath.row == 1){
        YCAlbumController *album = [[YCAlbumController alloc] init];
        album.title = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:album];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else{
        [self dismissViewController];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 
- (void)tackPhoto{
    if (self.imagePickerController) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController = picker;
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}
#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSDictionary *param = @{@"image" : [self fixOrientation:image]};
    
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        if(weakSelf.didSelectedPhotosBlock)weakSelf.didSelectedPhotosBlock(@[param]);
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Event
- (void)dismissViewController{
    [[YCPhotoPickerManager sharedManager] getResultBlock:^(NSArray *infos) {
        if(self.didSelectedPhotosBlock)self.didSelectedPhotosBlock(infos);
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
+ (UIColor*)opaqueColorWithRGBBytes:(NSUInteger)hexConstant
{
    CGFloat red = ((hexConstant >> 16) & 0xFF) / 255.0;
    CGFloat green = ((hexConstant >> 8) & 0xFF) / 255.0;
    CGFloat blue = (hexConstant & 0xFF) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
/**
 *  解决拍照后图片旋屏的问题 2015/12/15 Suycity
 */
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

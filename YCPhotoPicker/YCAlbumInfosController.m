//
//  YCAlbumInfosController.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCAlbumInfosController.h"
#import "YCImageView.h"
#import "YCPhotoPickerManager.h"
#import "YCPhotoPickerController.h"


@interface YCAlbumInfosController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbnails;
@property (nonatomic, assign) BOOL isReloadData;
@end

@implementation YCAlbumInfosController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *flowLayout =  [UICollectionViewFlowLayout new];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.collectionView = collectionView;
    [self.view addSubview:self.collectionView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom  multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    UIBarButtonItem *rightBtn=[[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnEvent:)];
    self.navigationItem.rightBarButtonItem=rightBtn;
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.isReloadData = YES;
    [self.collectionView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.groups numberOfAssets] - 1 inSection:0];
    [self.collectionView performBatchUpdates:^{
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    } completion:^(BOOL finished) {
        [self.collectionView selectItemAtIndexPath:indexPath animated:NO
                                    scrollPosition:UICollectionViewScrollPositionBottom];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isReloadData = NO;
}
#pragma mark - Event
- (void)rightBtnEvent:(id)sender{
    [(YCPhotoPickerController *)[[YCPhotoPickerManager sharedManager] parentViewController] dismissViewController];
}
#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.isReloadData ? [self.groups numberOfAssets] : 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return (CGSize){
        (CGRectGetWidth(collectionView.frame) - 3 * 5)/4,
        (CGRectGetWidth(collectionView.frame) - 3 * 5)/4
    };
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    NSString *nibName = @"UICollectionViewCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:nibName forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    __block YCImageView *imageView = [[cell.contentView subviews] firstObject];
    if (!imageView) {
        imageView = [[YCImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [cell.contentView addSubview:imageView];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY  multiplier:1 constant:0]];
        
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    }
    @autoreleasepool {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.groups enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] options:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    @autoreleasepool {
                        imageView.image = nil;
                    }
                    UIImage *image =[UIImage imageWithCGImage:[result thumbnail]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageView setImage:image asset:result withTapBlock:nil];
                    });
                }
            }];
        });
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//
//  YCAlbumController.m
//  CustomPhotoPicker
//
//  Created by Suycity on 16/1/20.
//  Copyright © 2016年 Suycity. All rights reserved.
//

#import "YCAlbumController.h"
#import "YCPhotoPickerManager.h"
#import "YCAlbumInfosController.h"

@interface YCAlbumController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation YCAlbumController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *bar = [UINavigationBar appearance];
    //设置显示的颜色
    bar.barTintColor = [UIColor whiteColor];
    UIBarButtonItem *rightBii=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnEvent:)];
    self.navigationItem.rightBarButtonItem=rightBii;
    
    // Do any additional setup after loading the view.
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];//[YCPhotoPickerController opaqueColorWithRGBBytes:0xe5e5e5];
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setScrollEnabled:NO];
    
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom  multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
}
#pragma mark - Event
- (void)rightBtnEvent:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[YCPhotoPickerManager sharedManager] groups] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    id dict = [[YCPhotoPickerManager sharedManager] groups];
    
    ALAssetsGroup *group = [dict allObjects][indexPath.row];
    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
    NSString *groupName = [NSString stringWithFormat:@"%@ (%d)",name,(int)[group numberOfAssets]];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:groupName];
    [attributed addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName : [UIColor blackColor]}
                        range:(NSRange){
                            0,name.length
                        }];
    [attributed addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16],
                                NSForegroundColorAttributeName : [UIColor grayColor]}
                        range:(NSRange){
                            name.length,[groupName length] - name.length
                        }];
    
    cell.textLabel.attributedText = attributed;
    cell.imageView.image = [UIImage imageWithCGImage:group.posterImage];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id dict = [[YCPhotoPickerManager sharedManager] groups];
    ALAssetsGroup *group = [dict allObjects][indexPath.row];
    if ([group numberOfAssets]){
        NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
        @autoreleasepool {
            YCAlbumInfosController *albumInfos = [[YCAlbumInfosController alloc] init];
            albumInfos.title = name;
            albumInfos.groups = group;
            [self.navigationController pushViewController:albumInfos animated:NO];
        }
    }
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

//
//  ChatListController.m
//  SpotGoods
//
//  Created by shscce on 15/8/14.
//  Copyright (c) 2015年 shscce. All rights reserved.
//

#import "ChatListController.h"
#import "XMNChatController.h"

#import "ChatListCell.h"

#import "Masonry.h"

#import "UIImageView+XMWebImage.h"


@interface ChatListController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *networkStateView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (copy, nonatomic, readonly) NSArray *thumbs;
@property (copy, nonatomic, readonly) NSArray *nickNames;

@end

@implementation ChatListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsCompact];
    
    self.navigationItem.title = @"XMFraker";
    
    self.dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    
    [self.view updateConstraintsIfNeeded];
    
    [self loadDatas];
}


- (void)updateViewConstraints{
    [super updateViewConstraints];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top).with.offset(64);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    [cell.headImageView setImageWithUrlString:self.dataArray[indexPath.row][@"thumb"]];
    [cell.titleLabel setText:self.dataArray[indexPath.row][@"nickName"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XMNChatController *chatC;
    if (indexPath.row == self.dataArray.count - 1) {
        chatC =[[XMNChatController alloc] initWithChatType:XMNMessageChatGroup];
    }else{
        chatC = [[XMNChatController alloc] init];
    }
    chatC.chatterName = self.dataArray[indexPath.row][@"nickName"];
    chatC.chatterThumb = self.dataArray[indexPath.row][@"thumb"];
    chatC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatC animated:YES];
    chatC.hidesBottomBarWhenPushed = NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

#pragma mark - Private Methods

- (void)loadDatas{
    self.dataArray = [NSMutableArray array];
    [self.thumbs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.dataArray addObject:@{@"nickName":self.nickNames[idx],@"thumb":obj}];
    }];
    [self.tableView reloadData];
}


#pragma mark - Getters

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"ChatListCell"];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 50;
    }
    return _tableView;
}

- (UIView *)networkStateView{
    if (!_networkStateView) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        _networkStateView.backgroundColor = [UIColor orangeColor];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"messageSendFail"]];
        [_networkStateView addSubview:iconImageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"世界上最遥远的距离就是没网.检查设置";
        [_networkStateView addSubview:label];
        
        UIImageView *arrwoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_center_arrow_right"]];
        [_networkStateView addSubview:arrwoImageView];
        
        [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_networkStateView.mas_left).with.offset(4);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconImageView.mas_right).with.offset(4);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
        [arrwoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_networkStateView.mas_right).with.offset(-8);
            make.centerY.equalTo(_networkStateView.mas_centerY);
        }];
        
    }
    return _networkStateView;
}

- (NSArray *)nickNames{
    return @[@"小新",@"小白",@"疯狂的2",@"爱国者1",@"椰子",@"Archon",@"爱好者群 -- 305700441"];
}

- (NSArray *)thumbs{
    return @[@"http://d.hiphotos.baidu.com/image/h%3D300/sign=5ea0f2a2a186c91717035439f93c70c6/a50f4bfbfbedab64c8255b9af136afc379311e10.jpg",@"http://d.hiphotos.baidu.com/image/h%3D300/sign=640e87a87b1ed21b66c928e59d6fddae/b21bb051f8198618d5e0f9de4ced2e738ad4e6c1.jpg",@"http://h.hiphotos.baidu.com/image/h%3D300/sign=9dfc986b4c90f6031bb09a470913b370/472309f79052982265702d99d1ca7bcb0a46d42c.jpg",@"http://img1.touxiang.cn/uploads/20131114/14-065806_736.jpg",@"http://img1.touxiang.cn/uploads/20131114/14-065802_226.jpg",@"http://img1.touxiang.cn/uploads/20131114/14-065800_721.jpg",@"http://img1.touxiang.cn/uploads/20131114/14-065810_396.jpg"];
}


@end

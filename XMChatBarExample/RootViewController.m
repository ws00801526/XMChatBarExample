//
//  RootViewController.m
//  XMChatBarExample
//
//  Created by shscce on 15/9/1.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "RootViewController.h"

#import "ChatViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"开始聊天" forState:UIControlStateNormal];
    button.titleLabel.textColor = [UIColor blackColor];
    button.backgroundColor = [UIColor redColor];
    [button sizeToFit];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonAction{
    ChatViewController *chatC =[[ChatViewController alloc] init];
    chatC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatC animated:YES];
    chatC.hidesBottomBarWhenPushed = NO;
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

//
//  ViewController.m
//  XMNChatFrameworkExample
//
//  Created by XMFraker on 16/4/25.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "ViewController.h"

#import <XMNChat/XMNChat.h>

#import "XMNChatTestVM.h"

#import <WebKit/WebKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushChat:(UIButton *)sender {
    
    XMNChatController *chatC = [[XMNChatController alloc] initWithChatMode:XMNChatSingle];
    
    XMNChatTestVM *testVM = [[XMNChatTestVM alloc] initWithChatMode:XMNChatSingle];
    chatC.chatVM = testVM;
    
    [self.navigationController pushViewController:chatC animated:YES];
}

@end

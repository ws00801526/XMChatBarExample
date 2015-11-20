//
//  XMNChatViewModel.m
//  XMNChatExample
//
//  Created by shscce on 15/11/18.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import "XMNChatViewModel.h"

#import "XMNChatTextMessageCell.h"
#import "XMNChatImageMessageCell.h"
#import "XMNChatVoiceMessageCell.h"
#import "XMNChatSystemMessageCell.h"
#import "XMNChatLocationMessageCell.h"

#import "XMNAVAudioPlayer.h"

#import "UITableView+FDTemplateLayoutCell.h"

@interface XMNChatViewModel ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) NSObject<XMNChatMessageCellDelegate> *parentVC;

@end

@implementation XMNChatViewModel

- (instancetype)initWithParentVC:(NSObject<XMNChatMessageCellDelegate> *)parentVC {
    if ([super init]) {
        _dataArray = [NSMutableArray array];
        _parentVC = parentVC;
    }
    return self;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = self.dataArray[indexPath.row];
    NSString *identifier = [XMNChatMessageCell cellIdentifierForMessageConfiguration:@{kXMNMessageConfigurationGroupKey:message[kXMNMessageConfigurationGroupKey],kXMNMessageConfigurationOwnerKey:message[kXMNMessageConfigurationOwnerKey],kXMNMessageConfigurationTypeKey:message[kXMNMessageConfigurationTypeKey]}];
    
    XMNChatMessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [messageCell configureCellWithData:message];
    messageCell.delegate = self.parentVC;
    
    return messageCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *message = self.dataArray[indexPath.row];
    NSString *identifier = [XMNChatMessageCell cellIdentifierForMessageConfiguration:@{kXMNMessageConfigurationGroupKey:message[kXMNMessageConfigurationGroupKey],kXMNMessageConfigurationOwnerKey:message[kXMNMessageConfigurationOwnerKey],kXMNMessageConfigurationTypeKey:message[kXMNMessageConfigurationTypeKey]}];
    return [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(XMNChatMessageCell *cell) {
        [cell configureCellWithData:message];
    }];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    //设置正确的voiceMessageCell播放状态
    NSDictionary *message = self.dataArray[indexPath.row];
    if ([message[kXMNMessageConfigurationTypeKey] integerValue] == XMNMessageTypeVoice) {
        if (indexPath.row == [[XMNAVAudioPlayer sharePlayer] index]) {
            [(XMNChatVoiceMessageCell *)cell setVoiceMessageState:[[XMNAVAudioPlayer sharePlayer] audioPlayerState]];
        }
    }
}


#pragma mark - Public Methods

- (void)appendMessage:(NSDictionary *)message {
    [self.dataArray addObject:message];
}

- (void)insertMessage:(NSDictionary *)message atIndex:(NSUInteger)index {
    [self.dataArray insertObject:message atIndex:index];
}

- (void)removeMessageAtIndex:(NSUInteger)index {
    if (index < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:index];
    }
}

- (NSDictionary *)messageAtIndex:(NSUInteger)index {
    if (index < self.dataArray.count) {
        return self.dataArray[index];
    }
    return nil;
}

#pragma mark - Getters

- (NSUInteger)messageCount {
    return self.dataArray.count;
}

@end

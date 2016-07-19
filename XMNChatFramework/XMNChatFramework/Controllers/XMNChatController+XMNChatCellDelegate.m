//
//  XMNChatController+XMNChatCellDelegate.m
//  XMNChatFramework
//
//  Created by XMFraker on 16/7/14.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatController+XMNChatCellDelegate.h"

#import "XMNPhotoBrowser.h"
#import "XMNChatController+XMNVoice.h"
#import "XMNChatController_Private.h"

#import "XMNChatOwnCell.h"
#import "XMNChatOtherCell.h"

@implementation XMNChatController (XMNChatCellDelegate)

- (void)messageCellDidTapAvatar:(XMNChatCell *)cell {
    
    XMNLog(@"tap  avatar:%@",cell);
}

- (void)messageCellDidTapContent:(XMNChatCell *)cell  {
    
    XMNLog(@"tap content:%@",cell);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)cell];
    // TODO: 需要区分开始点击头像 还是点击内容
    XMNChatBaseMessage *message =  self.chatVM.messages[indexPath.row];
    if (message.type == XMNMessageTypeImage) {
        
        [self browseImageMessageAtIndexPath:indexPath];
    }else if (message.type == XMNMessageTypeVoice) {
        
        [self playVoiceMessage:(XMNChatVoiceMessage *)message];
    }
}

- (void)messageCellDidDoubleTapContent:(XMNChatCell *)cell  {
    
    XMNLog(@"double tap :%@",cell);
}


#pragma mark - Methods

- (void)browseImageMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    XMNChatBaseMessage *message =  self.chatVM.messages[indexPath.row];
    NSArray<XMNChatImageMessage *> *filterMessages = (NSArray<XMNChatImageMessage *> *)[self.chatVM filterMessageWithType:XMNMessageTypeImage];
    NSMutableArray *photos = [NSMutableArray array];
    
    [filterMessages enumerateObjectsUsingBlock:^(XMNChatImageMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XMNPhotoModel *photo= [[XMNPhotoModel alloc] initWithImagePath:[obj imagePath]
                                                             thumbnail:obj.content];
        [photos addObject:photo];
    }];
    
    XMNPhotoBrowserController *browserC = [[XMNPhotoBrowserController alloc] initWithPhotos:photos];
    browserC.currentItemIndex = [filterMessages indexOfObject:(XMNChatImageMessage *)message];
    
    XMNChatCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    browserC.sourceView = (UIView *)cell.messageView;
    [self presentViewController:browserC animated:YES completion:nil];
}


@end

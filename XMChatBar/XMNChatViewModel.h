//
//  XMNChatViewModel.h
//  XMNChatExample
//
//  Created by shscce on 15/11/18.
//  Copyright © 2015年 xmfraker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XMNChatMessageCellDelegate;
@interface XMNChatViewModel : NSObject <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign, readonly) NSUInteger messageCount;

- (instancetype)initWithParentVC:(NSObject<XMNChatMessageCellDelegate> *)parentVC;

- (void)appendMessage:(NSDictionary *)message;

- (void)insertMessage:(NSDictionary *)message atIndex:(NSUInteger)index;

- (void)removeMessageAtIndex:(NSUInteger)index;

- (NSDictionary *)messageAtIndex:(NSUInteger)index;

@end

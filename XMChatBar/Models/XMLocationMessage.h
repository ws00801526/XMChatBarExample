//
//  XMLocationMessage.h
//  XMChatControllerExample
//
//  Created by shscce on 15/9/2.
//  Copyright (c) 2015年 xmfraker. All rights reserved.
//

#import "XMMessage.h"
#import <MapKit/MapKit.h>

@interface XMLocationMessage : XMMessage

@property (assign, nonatomic) CLLocationCoordinate2D coordinate /**< 位置的经纬度 */;
@property (copy, nonatomic) NSString *address /**< 位置地址 */;

@end

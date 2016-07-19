//
//  XMNChatTestVM.m
//  XMNChatFrameworkExample
//
//  Created by XMFraker on 16/5/30.
//  Copyright © 2016年 XMFraker. All rights reserved.
//

#import "XMNChatTestVM.h"
#import "XMNChatTestServer.h"

@implementation XMNChatTestVM



#pragma mark - Life Cycle

- (instancetype)initWithChatMode:(XMNChatMode)aChatMode {
    
    if (self = [super initWithChatMode:aChatMode]) {
        NSLog(@"this is test chatVM init");
        
        [self generateSystemMessage];
        [self generateTextMessages];
        [self generateImageMessages];
        
        self.chatServer = [[XMNChatTestServer alloc] init];
    }
    return self;
}


#pragma mark - Methods


- (void)generateSystemMessage {
    
    XMNChatSystemMessage *systemMessage = [[XMNChatSystemMessage alloc] initWithContent:@"2016年6月12日 12:21:12"
                                                                                  state:XMNMessageStateSuccess
                                                                                  owner:XMNMessageOwnerSystem];
    
    [self.messages addObject:systemMessage];
}

/**
 *  生成测试文字消息
 */
- (void)generateTextMessages {
    
    
    NSArray *words = @[@"爱=不放弃。 -- 书摘",
                       @"真理惟一可靠的标准就是永远自相符合。—— 欧文",
                       @"土地是以它的肥沃和收获而被估价的；才能也是土地，不过它生产的不是粮食，而是真理。如果只能滋生瞑想和幻想的话，即使再大的才能也只是砂地或盐池，那上面连小草也长不出来的。—— 别林斯基",
                       @"我需要三件东西：爱情友谊和图书。然而这三者之间何其相通！炽热的爱情可以充实图书的内容，图书又是人们最忠实的朋友。 —— 蒙田",
                       @"时间是一切财富中最宝贵的财富。 —— 德奥弗拉斯多",
                       @"世界上一成不变的东西，只有“任何事物都是在不断变化的”这条真理。 —— 斯里兰卡",
                       @"生活有度，人生添寿。 —— 书摘",
                       @"这世界要是没有爱情，它在我们心中还会有什么意义！这就如一盏没有亮光的走马灯。 —— 歌德",
                       @"我们不应该不惜任何代价地去保持友谊，从而使它受到玷污。如果为了那更伟大的爱，必须牺牲友谊，那也是没有办法的事；不过如果能够保持下去，那么，它就能真的达到完美的境界了。 —— 泰戈尔"];
    
    
    [words enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XMNChatTextMessage *textMessage = [[XMNChatTextMessage alloc] initWithContent:obj state:XMNMessageStateSuccess owner:idx%2==0 ? XMNMessageOwnerSelf : XMNMessageOwnerOther];
        [self.messages addObject:textMessage];
    }];
}

/**
 *  生成测试图片消息
 */
- (void)generateImageMessages {
    
    
    NSArray *links = @[
                       /*
                        You can add your image url here.
                        */
//                       @"http://img3.duitang.com/uploads/item/201505/02/20150502005315_2zBTe.thumb.700_0.jpeg",
                       // progressive jpeg
//                       @"https://s-media-cache-ak0.pinimg.com/1200x/2e/0c/c5/2e0cc5d86e7b7cd42af225c29f21c37f.jpg",
//                       
//                       // animated gif: http://cinemagraphs.com/
//                       @"http://i.imgur.com/uoBwCLj.gif",
//                       @"http://i.imgur.com/8KHKhxI.gif",
//                       @"http://i.imgur.com/WXJaqof.gif",
                       
                       // animated gif: https://dribbble.com/markpear
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1780193/dots18.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1809343/dots17.1.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1845612/dots22.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1820014/big-hero-6.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1819006/dots11.0.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/345826/screenshots/1799885/dots21.gif",
                       
                       // animaged gif: https://dribbble.com/jonadinges
//                       @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/2025999/batman-beyond-the-rain.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1855350/r_nin.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1963497/way-back-home.gif",
//                       @"https://d13yacurqjgara.cloudfront.net/users/288987/screenshots/1913272/depressed-slurp-cycle.gif",
                       
                       // jpg: https://dribbble.com/snootyfox
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2047158/beerhenge.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/2016158/avalanche.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1839353/pilsner.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1833469/porter.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1521183/farmers.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1391053/tents.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1399501/imperial_beer.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1488711/fishin.jpg",
//                       @"https://d13yacurqjgara.cloudfront.net/users/26059/screenshots/1466318/getaway.jpg",
                       
                       // animated webp and apng: http://littlesvr.ca/apng/gif_apng_webp.html
//                       @"http://littlesvr.ca/apng/images/BladeRunner.png",
//                       @"http://littlesvr.ca/apng/images/Contact.webp",
                       ];
    
    __weak typeof(*&self) wSelf = self;
    [links enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __strong typeof(*&wSelf) self = wSelf;
        XMNChatImageMessage *imageMessage = [[XMNChatImageMessage alloc] initWithContent:obj
                                                                                   state:XMNMessageStateSuccess
                                                                                   owner:idx%2==0 ? XMNMessageOwnerSelf : XMNMessageOwnerOther];
        [self.messages addObject:imageMessage];
    }];
//    [(XMNChatImageMessage *)[self.messages lastObject] setImageSize:CGSizeMake(500, 224)];
    
    /** 添加本地图片 测试消息 */
    XMNChatImageMessage *imageMessage = [[XMNChatImageMessage alloc] initWithContent:[UIImage imageNamed:@"test01"] state:XMNMessageStateSuccess owner:XMNMessageOwnerOther];
    imageMessage.state = XMNMessageStateSending;
    [self.messages addObject:imageMessage];
    
    /** 添加测试语音消息 */
    XMNChatVoiceMessage *voiceMessage = [[XMNChatVoiceMessage alloc] initWithContent:@"https://raw.githubusercontent.com/ws00801526/XMNAudio/master/XMNAudioExample/XMNAudioExample/letitgo_v.mp3" state:XMNMessageStateSuccess owner:XMNMessageOwnerOther];
    voiceMessage.state = XMNMessageStateSending;
    [self.messages addObject:voiceMessage];
    
    /** 添加测试语音消息2 */
    XMNChatVoiceMessage *voiceMessage2 = [[XMNChatVoiceMessage alloc] initWithContent:@"https://raw.githubusercontent.com/ws00801526/XMNAudio/master/XMNAudioExample/XMNAudioExample/letitgo_v.mp3" state:XMNMessageStateSuccess owner:XMNMessageOwnerSelf];
    voiceMessage2.state = XMNMessageStateSending;
    [self.messages addObject:voiceMessage2];
    
}
@end

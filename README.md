##仿微信聊天输入框

-----
XMChatBar是一个仿微信的输入框,可以输入文字,表情,选择图片,地理位置发送


------

#### 重要提示
有几个兄弟在使用过程中碰到chatBar不显示,或者位置错乱的问题,是因为使用了IQKeyboardManager这个类库,这个会有一定冲突


####1. 截图

![](http://7xlt1j.com1.z0.glb.clouddn.com/XMChatBarScreenShot_3.gif)

![](http://7xlt1j.com1.z0.glb.clouddn.com/XMChatBarScreenShot_1.png)


![](http://7xlt1j.com1.z0.glb.clouddn.com/XMChatBarScreenShot_2.png)


####2. 使用说明

1. 下载XMNChatExample,拖动XMChatBar 目录到自己的工程 或者可以通过`pod XMChatBar`安装
2. 最主要的是看XMNChatController
3. 模拟XMNChatServerExample 写一个自己的 发送服务器管理manager,并且在XMNChatViewModel中修改chatServer为自己写的manager
4. 修改XMNChatController 构造自己合适的message结构 传入chatViewModel
5. 需要注意的
	* UIImageView+XMWebImage 是一个最简单的异步下载网络图片,没有缓存,推荐大家换成SD或者其他带缓存类库
	* XMNAVAudioPlayer 是一个带有简单本地文件缓存的音频播放


####3. 相关类说明,介绍

你可以实例化一个XMChatBar 添加到你想要的View上,参考demo中实例即可,pod工程github没有上传,你可以下载demo后 执行`pod install` 或者 `pod install --verbose --no-repo-update`安装即可

--------
[Controllers类名] | 作用
----- | -----
XMLocationController  | 选择地理位置的controller

[Helpers类名] | 作用
----- | -----
XMNAVAudioPlayer | 录音播放工具,可以播放录音,停止播放录音
XMFaceManager  | 表情管理,可以获取所有的表情名称,以及对应图片名

[Views类名]() | 作用
----- | -----
[XMChatBar] | 聊天输入框
[XMChatMoreView] | 更多view,用来显示选择图片,拍照等按钮
[XMChatFaceView] | 显示表情view,用来选择表情
[XMChatMoreItem] | moreView的itemView
[XMProgressHUD]  | 录音HUD


####4. 使用到的第三方类库

第三方库 | 说明
----- | -----
[PonyChatUI](https://github.com/PonyGroup/PonyChatUIV2) | 一个很好的聊天界面布局,作者还未完成,期待作者的更多功能
VoiceLib | 一款第三方录音类库,使用方便
[Masonry](https://github.com/SnapKit/Masonry) | 第三方的代码自动布局
[SwipeView](https://github.com/nicklockwood/SwipeView)  | nicklockwood大神的

####5. 感谢
感谢[UUChatTableView](https://github.com/ZhipingYang/UUChatTableView),[PonyChatUI](https://github.com/PonyGroup/PonyChatUIV2)  这是一个学习过程中写的,如果有什么问题,可以[问我](https://github.com/ws00801526/XMChatBarExample/issues),或者发送我的邮箱3057600441@qq.com
本示例中用到的图片来自QQ,微信,请尊重版权


####6. 更新


#####V1.3.0 -> 强烈推荐更新至1.3.0  非常抱歉之前版本有不少bug

1. 重写了XMNChatMessageCell
2. 使用了ViewModel管理数据,简化了CHatViewController
3. 重写了XMVAudioPlayer,修复了之前版本有语音Cell 导致的问题  -- 增加了简单的本地文件缓存,可以将网络MP3缓存至本地


#####V1.2.2
1. 修复一个头像拉伸的bug
2. 增加了一个ChatListController ,demo测试,可以让大家参考下
3. ChatViewController 分成了XMChatTypeSingle,XMChatTypeGroup两种,默认XMChatTypeSingle

#####V1.2.1
增加pod使用方法
pod XMChatBar

#####V1.1
1. 去除了PonyChatUI的依赖,因为该类库依赖于AsyncDisplayKit,本人不太熟悉,所以重新参照PonyChatUI重新写了个ChatViewController
2. 加入了pods 工程,因为不少小伙伴下载后缺少pods工程无法打开,这次特地一起上传了上来
3. 使用方法请参考,ChatViewController,也可以直接使用,没有继承下拉加载更多消息


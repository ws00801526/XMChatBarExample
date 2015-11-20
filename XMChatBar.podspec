Pod::Spec.new do |s|
  s.name         = "XMChatBar"
  s.version      = "1.3.0"
  s.summary      = "模仿微信聊天输入框"
  s.description  = "模仿微信,QQ聊天输入框,共同学习,如果您发现什么bug或者有什么问题,可以联系我"
  s.homepage     = "https://github.com/ws00801526/XMChatBarExample"
  s.license      = "MIT"
  s.author       = { "XMFraker" => "3057600441@qq.com" }  
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ws00801526/XMChatBarExample.git", :tag => s.version }
  s.source_files = "XMChatBar/**/*.{h,m}"
  s.ios.frameworks   = "UIKit", "MapKit", "Foundation"
  s.requires_arc = true
  s.ios.vendored_library = 'XMChatBar/Vendors/VoiceLib/libmp3lame.a'
  s.resources = ["XMChatBar/chatBar.xcassets", "XMChatBar/face.plist"]
  s.dependency "Masonry"
end

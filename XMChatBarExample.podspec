Pod::Spec.new do |s|

  s.name         = "XMChatBarExample"
  s.version      = "1.2.0"
  s.summary      = "模仿微信聊天输入框"
  s.description  = "模仿微信,QQ聊天输入框,共同学习,如果您发现什么bug或者有什么问题,可以联系我"
  s.homepage     = "https://github.com/ws00801526/XMChatBarExample"
  s.license      = "MIT"
  s.author             = { "XMFraker" => "3057600441@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ws00801526/XMChatBarExample.git", :tag => "1.2.0" }
  s.source_files  = "XMChatBar/**/*.{h,m}"
  s.frameworks = "UIKit", "MapKit"
  s.requires_arc = true
  s.dependency "Masonry"

end

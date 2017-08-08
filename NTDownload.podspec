
Pod::Spec.new do |s|
  s.name         = "NTDownload"
  s.version      = "0.0.3"
  s.summary      = "iOS 下载 断点下载 后台断点下载 退出App 离线断点下载 使用 Swift 3.1 "

  s.homepage     = "https://github.com/ntian2/NTDownload"

  s.license      = "MIT"

  s.author             = { "ntian2" => "n1179953947@gmail.com" }
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/ntian2/NTDownload.git", :tag => s.version }

  s.source_files  = "NTDownload", "NTDownload/download/NTDownload/*.swift"
end

# NTDownload

<p align="left">
<a href="https://img.shields.io/cocoapods/v/NTDownload.svg”><img src="https://img.shields.io/cocoapods/v/NTDownload.svg"></a>
<a href="https://img.shields.io/cocoapods/v/NTDownload.svg"><img src="https://img.shields.io/github/license/ntian2/NTDownload.svg?style=flat"></a>
<a href="http://cocoadocs.org/docsets/NTDownload”><img src="https://img.shields.io/cocoapods/p/NTDownload.svg?style=flat"></a>
</p>

## 特性* 基于 URLSessionDownloadTask & Swift 3.1* 断点续传* 退出时保存进度
## 要求
* iOS 8+
## 安装
### cocoapods
```ruby
pod 'NTDownload'
```
## GIF效果图
![图片效果演示(https://github.com/ntian2/NTDownload/raw/master/NTDownload.gif)
## 使用方法
```Swift
// 控制器里设置代理 NTDownloadManager
NTDownloadManager.shared.downloadManagerDelegate = self
// 指定下载 URLString
NTDownloadManager.shared.newTask(urlString: urlString, fileImage: nil)
// 遵守 NTDownloadManager
// 下载完成 在这里改变 UI
func finishedDownload(task: NTDownloadTask) 
```
Cell上获取实时下载进度 遵守 NTDownloadTaskDelegate
```Swift
// 下载进度
func downloadTaskUpdateProgress(task: NTDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
// 开始下载 在这里改变 UI
func downloadTaskDownloading(task: NTDownloadTask)
// 暂停下载 在这里改变 UI
func downloadTaskStopDownload(task: NTDownloadTask)
```
# License
NTDownload is available under the MIT license. See the LICENSE file for more info.
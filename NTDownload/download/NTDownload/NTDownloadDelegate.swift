//
//  NTDownloadDelegate.swift
//
//  Created by ntian on 2017/7/8.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

@objc public protocol NTDownloadManagerDelegate: NSObjectProtocol {
    /// 下载完成
    @objc optional func finishedDownload(task: NTDownloadTask)
    ///
    @objc optional func addedDownload(task: NTDownloadTask)
}

@objc public protocol NTDownloadTaskDelegate: NSObjectProtocol {
    
    /// 下载进度
    @objc optional func downloadTaskUpdateProgress(task: NTDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    /// 开始下载
    @objc optional func downloadTaskDownloading(task: NTDownloadTask)
    /// 暂停下载
    @objc optional func downloadTaskStopDownload(task: NTDownloadTask)
}

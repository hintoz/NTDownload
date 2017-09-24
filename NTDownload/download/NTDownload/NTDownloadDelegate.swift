//
//  NTDownloadDelegate.swift
//
//  Created by ntian on 2017/7/8.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

@objc public protocol NTDownloadManagerDelegate: NSObjectProtocol {
    /// 下载完成
    @objc optional func downloadRequestFinished(downloadTask: NTDownloadTask)

    @objc optional func addedDownloadRequest(downloadTask: NTDownloadTask)

    /// 下载进度
    @objc optional func downloadRequestUpdateProgress(downloadTask: NTDownloadTask)
    /// 开始下载
    @objc optional func downloadRequestDidStarted(downloadTask: NTDownloadTask)
    /// 暂停下载
    @objc optional func downloadRequestDidPaused(downloadTask: NTDownloadTask)
}

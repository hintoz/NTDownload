//
//  NTDownloadTask.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

public enum NTDownloadState: Int {
    case NTDownloading = 0 // 正在下载
    case NTStopDownload = 2 // 暂停下载
    case NTFinishedDownload = 3 // 完成下载
}
open class NTDownloadTask: NSObject {
    
    /// 下载地址
    open var url: URL
    /// 任务标识符
    open var taskIdentifier: Int = 0
    /// 是否完成
    open var isFinished: Bool = false
    /// 文件的附带图片地址
    open var fileImage: String?
    /// 文件已下载大小
    open var fileReceivedSize: Float = 0.0
    /// 文件已下载大小的后缀 KB MB GB
    open var fileReceivedUnit: String = ""
    /// 文件总大小
    open var fileTotalSize: Float = 0.0
    /// 文件总大小的后缀 KB MB GB
    open var fileTotalUnit: String = ""
    /// 文件名字
    open var fileName: String
    /// 文件下载状态
    open var downloadState: NTDownloadState?
    /// 文件已下载数据
    open var resumeData: Data?
    open weak var delegate: NTDownloadTaskDelegate?
    
    init(url: URL, taskIdentifier: Int, fileImage: String?, downloadState: NTDownloadState) {
        self.url = url
        self.fileName = (url.absoluteString as NSString).lastPathComponent
        self.taskIdentifier = taskIdentifier
        self.fileImage = fileImage
        self.downloadState = downloadState
    }
}

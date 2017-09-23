//
//  NTDownloadTask.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

public typealias size = (size: Float, unit: String)?

public enum NTDownloadStatus: Int {
    case NTDownloading = 0 // Downloading
    case NTStopDownload = 2 // StopDownload
    case NTFinishedDownload = 3 // FinishedDownload
}
open class NTDownloadTask: NSObject {
    /// 下载地址
    open var fileURL: URL
    /// 文件名字
    open var fileName: String
    /// 文件的附带图片地址
    open var fileImage: String?
    /// 任务标识符
    open var taskIdentifier: Int
    /// 文件下载状态
    open var status: NTDownloadStatus?
    /// 文件下载大小
    open var downloadedFileSize: size
    /// 文件总大小
    open var fileSize: size

    /// 文件已下载数据
    open var resumeData: Data?
    open var task: URLSessionDownloadTask?
    open weak var delegate: NTDownloadTaskDelegate?
    
    init(fileURL: URL, fileName: String, taskIdentifier: Int, fileImage: String? = nil, status: NTDownloadStatus) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.taskIdentifier = taskIdentifier
        self.fileImage = fileImage
        self.status = status
    }
}

//
//  NTDownloadTask.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import Foundation

public typealias size = (size: Float, unit: String)?

public enum NTDownloadStatus: Int {
    case NTDownloading // Downloading
    case NTPauseDownload // PauseDownload
//    case NTStopDownload // StopDownload
    case NTFinishedDownload // FinishedDownload
    case NTUnknown // Unknown
    var status: NTDownloadStatus {
        switch self.rawValue {
        case 0:
            return .NTDownloading
        case 1, 2:
            return .NTPauseDownload
        case 3:
            return .NTFinishedDownload
        default:
            return .NTUnknown
        }
    }
  
}
open class NTDownloadTask: NSObject {
    /// 下载地址
    open var fileURL: URL
    /// 文件名字
    open var fileName: String
    /// 文件的附带图片地址
    open var fileImage: String?
    /// 文件下载状态
    open var status: NTDownloadStatus?
    /// 文件下载大小
    open var downloadedFileSize: size
    /// 文件总大小
    open var fileSize: size

    open var task: URLSessionDownloadTask?
    open weak var delegate: NTDownloadTaskDelegate?
    
    init(fileURL: URL, fileName: String, fileImage: String? = nil) {
        self.fileURL = fileURL
        self.fileName = fileName
        self.fileImage = fileImage
//        self.status = status
    }
}

//
//  NTDownloadManager.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

class NTDownloadManager: URLSessionDownloadTask {
    
    /// 单例
    static let shared = NTDownloadManager()
    var configuration = URLSessionConfiguration.default
    /// 任务列表
    lazy var taskList = [NTDownloadTask]()
    /// 下载管理器代理
    weak var downloadManagerDelegate: NTDownloadManagerDelegate?
    fileprivate var session: URLSession?
    fileprivate lazy var downloadTaskList = [URLSessionDownloadTask]()
    /// Plist存储路径
    fileprivate let plistPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/NTDownload.plist"
    /// 文件存储路径
    fileprivate let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    override init() {
        super.init()
        
        configuration = URLSessionConfiguration.background(withIdentifier: "NTDownload")
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        self.loadTaskList()
        debugPrint(plistPath)
    }
    /// 未完成列表
    var unFinishedList: [NTDownloadTask] {
        return taskList.filter({ (task) -> Bool in
            return task.isFinished == false
        })
    }
    /// 完成列表
    var finishedList: [NTDownloadTask] {
        return taskList.filter({ (task) -> Bool in
            return task.isFinished == true
        })
    }
    /// 添加下载文件任务
    func newTask(urlString: String, fileImage: String?) {
        guard let url = URL(string: urlString) else {
            return
        }
        if url.scheme != "http" && url.scheme != "https" {
            return
        }
        for task in taskList {
            if task.url == url {
                return
            }
        }
        guard let downloadTask = self.session?.downloadTask(with: url) else {
            return
        }
        downloadTask.resume()
        self.downloadTaskList.append(downloadTask)
        let task = NTDownloadTask(url: url, taskIdentifier: downloadTask.taskIdentifier, fileImage: fileImage, downloadState: NTDownloadState(rawValue: downloadTask.state.rawValue)!)
        self.taskList.append(task)
        self.saveTaskList()
    }
    /// 暂停下载文件
    func pauseTask(fileInfo: NTDownloadTask) {
        if fileInfo.isFinished || fileInfo.downloadState != .NTDownloading {
            return
        }
        for downloadTask in downloadTaskList {
            if fileInfo.taskIdentifier == downloadTask.taskIdentifier {
                downloadTask.cancel(byProducingResumeData: { (resumeData) in
                    fileInfo.resumeData = resumeData
                    fileInfo.downloadState = NTDownloadState(rawValue: downloadTask.state.rawValue)
                    fileInfo.delegate?.downloadTaskStopDownload?(task: fileInfo)
                    self.saveTaskList()
                })
            }
        }
    }
    /// 恢复下载文件
    func resumeTask(fileInfo: NTDownloadTask) {
        if fileInfo.isFinished || fileInfo.downloadState != .NTStopDownload {
            return
        }
        for i in 0..<downloadTaskList.count {
            if downloadTaskList[i].taskIdentifier == fileInfo.taskIdentifier {
                if fileInfo.resumeData == nil {
                    downloadTaskList[i] = (session?.downloadTask(with: fileInfo.url))!
                } else {
                    downloadTaskList[i] = (session?.downloadTask(withResumeData: fileInfo.resumeData!))!
                }
                fileInfo.taskIdentifier = downloadTaskList[i].taskIdentifier
                downloadTaskList[i].resume()
                fileInfo.downloadState = NTDownloadState(rawValue: downloadTaskList[i].state.rawValue)
                fileInfo.delegate?.downloadTaskDownloading?(task: fileInfo)
                fileInfo.resumeData = nil
            }
        }
    }
    /// 开始所有下载任务
    func resumeAllTask() {
        for task in unFinishedList {
            resumeTask(fileInfo: task)
        }
    }
    /// 暂停所有下载任务
    func pauseAllTask() {
        for task in finishedList {
            pauseTask(fileInfo: task)
        }
    }
    /// 返回已下载完成文件路径 若未下载完成 则返回 nil
    func taskPath(fileInfo: NTDownloadTask) -> String? {
        if !fileInfo.isFinished {
            return nil
        }
        return "\(documentPath)/\(fileInfo.fileName)"
    }
    /// 删除下载文件
    func removeTask(fileInfo: NTDownloadTask) {
        for i in 0..<taskList.count {
            if (fileInfo.url == taskList[i].url) {
                taskList.remove(at: i)
                if fileInfo.isFinished {
                    let path = "\(documentPath)/\(fileInfo.fileName)"
                    try? FileManager.default.removeItem(atPath: path)
                }
                saveTaskList()
                break
            }
        }
    }
    /// 删除所有下载文件
    func removeAllTask() {
        for task in taskList {
            if task.isFinished {
                let path = "\(documentPath)/\(task.fileName)"
                try? FileManager.default.removeItem(atPath: path)
            }
        }
        try? FileManager.default.removeItem(atPath: plistPath)
    }
}
// MARK: - 私有方法
extension NTDownloadManager {
    fileprivate func saveTaskList() {
        let jsonArray = NSMutableArray()
        for task in taskList {
            let jsonItem = NSMutableDictionary()
            jsonItem["url"] = task.url.absoluteString
            jsonItem["isFinished"] = task.isFinished
            jsonItem["fileImage"] = task.fileImage
            jsonItem["fileTotalSize"] = task.fileTotalSize
            jsonItem["fileTotalUnit"] = task.fileTotalUnit
            jsonItem["fileReceivedSize"] = task.fileReceivedSize
            jsonItem["fileReceivedUnit"] = task.fileReceivedUnit
            if !task.isFinished {
                jsonItem["resumeData"] = task.resumeData
            }
            jsonArray.add(jsonItem)
        }
        jsonArray.write(toFile: plistPath, atomically: true)
    }
    fileprivate func loadTaskList() {
        guard let jsonArray = NSArray(contentsOfFile: plistPath) else {
            return
        }
        for jsonItem in jsonArray {
            guard let item = jsonItem as? NSDictionary, let urlString = item["url"] as? String, let isFinished = item["isFinished"] as? Bool, let fileTotalSize = item["fileTotalSize"] as? Float, let fileTotalUnit = item["fileTotalUnit"] as? String, let fileReceivedSize = item["fileReceivedSize"] as? Float, let fileReceivedUnit = item["fileReceivedUnit"] as? String else {
                return
            }
            let resumeData = item["resumeData"] as? Data
            let url = URL(string: urlString)
            let fileImage = item["fileImage"] as? String
            let task = NTDownloadTask(url: url!, taskIdentifier: 0, fileImage: fileImage, downloadState: NTDownloadState.NTStopDownload)
            task.isFinished = isFinished
            task.fileTotalSize = fileTotalSize
            task.fileTotalUnit = fileTotalUnit
            task.fileReceivedSize = fileReceivedSize
            task.fileReceivedUnit = fileReceivedUnit
            task.resumeData = resumeData
            self.taskList.append(task)
            if task.isFinished {
                task.downloadState = NTDownloadState.NTFinishedDownload
            } else {
                guard let downloadTask = session?.downloadTask(with: task.url) else {
                    continue
                }
                task.taskIdentifier = downloadTask.taskIdentifier
                downloadTask.cancel()
                self.downloadTaskList.append(downloadTask)
                task.delegate?.downloadTaskStopDownload?(task: task)
                self.saveTaskList()
            }
        }
    }
}
// MARK: - URLSessionDownloadDelegate
extension NTDownloadManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("task id: \(task.taskIdentifier)")
        let error = error as NSError?
        if (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonUserForceQuitApplication || (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
            for downloadTask in unFinishedList {
                if downloadTask.url == task.originalRequest?.url || downloadTask.url == task.currentRequest?.url {
                    let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                    downloadTask.resumeData = resumeData
                    resumeTask(fileInfo: downloadTask)
                }
            }
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for task in taskList {
            if task.taskIdentifier == downloadTask.taskIdentifier {
                task.isFinished = true
                task.downloadState = .NTFinishedDownload
                task.resumeData = nil
                let destUrl = documentUrl.appendingPathComponent(task.fileName)
                try? FileManager.default.moveItem(at: location, to: destUrl)
                downloadManagerDelegate?.finishedDownload(task: task)
            }
        }
        self.saveTaskList()
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        for task in unFinishedList {
            if task.taskIdentifier == downloadTask.taskIdentifier {
                task.fileTotalSize = NTCommonHelper.calculateFileSize(totalBytesExpectedToWrite)
                task.fileTotalUnit = NTCommonHelper.calculateUnit(totalBytesExpectedToWrite)
                task.fileReceivedSize = NTCommonHelper.calculateFileSize(totalBytesWritten)
                task.fileReceivedUnit = NTCommonHelper.calculateUnit(totalBytesWritten)
                task.delegate?.downloadTaskUpdateProgress?(task: task, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            }
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
}

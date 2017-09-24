//
//  NTDownloadManager.swift
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

open class NTDownloadManager: URLSessionDownloadTask {
    
    /// 单例
    open static let shared = NTDownloadManager()
    open var configuration = URLSessionConfiguration.background(withIdentifier: "NTDownload")
    /// 下载管理器代理
    open weak var downloadManagerDelegate: NTDownloadManagerDelegate?
    /// 任务列表
    private lazy var taskList = [NTDownloadTask]()
    private var session: URLSession!
    /// Plist存储路径
    private let plistPath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/NTDownload.plist"
    /// 文件存储路径
    private let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    //
    private let taskDescriptionFileURL = 0
    private let taskDescriptionFileName = 1
//    private let taskDescriptionFileImage = 2
    
    override init() {
        super.init()
        
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        self.loadTaskList()
        debugPrint(plistPath)
//        initDownloadTasks()
    }
    /// 未完成列表
    open var unFinishedList: [NTDownloadTask] {
        return taskList.filter({ (task) -> Bool in
            return task.status != .NTFinishedDownload
        })
    }
    /// 完成列表
    open var finishedList: [NTDownloadTask] {
        return taskList.filter({ (task) -> Bool in
            return task.status == .NTFinishedDownload
        })
    }
    /// 添加下载文件任务
    public func addDownloadTask(urlString: String, fileName: String? = nil, fileImage: String? = nil) {
        guard let url = URL(string: urlString) else {
            return
        }
        if url.scheme != "http" && url.scheme != "https" {
            return
        }
        for task in taskList {
            if task.fileURL == url {
                return
            }
        }
        let request = URLRequest(url: url)
        let downloadTask = session.downloadTask(with: request)
        downloadTask.resume()
        let status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
        let fileName = fileName ?? (url.absoluteString as NSString).lastPathComponent
        let task = NTDownloadTask(fileURL: url, fileName: fileName,  fileImage: fileImage)
        task.status = status
        var taskDescription = [urlString, fileName]
        if let fileImage = fileImage {
            taskDescription = [urlString, fileName, fileImage]
        }
        downloadTask.taskDescription = taskDescription.joined(separator: ",")
        task.task = downloadTask
        self.taskList.append(task)
        downloadManagerDelegate?.addedDownload?(task: task)
        print(taskList[0])
        self.saveTaskList()
    }
    /// 暂停下载文件
    public func pauseTask(fileInfo: NTDownloadTask) {
        if fileInfo.status == .NTFinishedDownload || fileInfo.status != .NTDownloading {
            return
        }
        let downloadTask = fileInfo.task!
        downloadTask.suspend()
        fileInfo.status = .NTPauseDownload
        fileInfo.delegate?.downloadTaskStopDownload?(task: fileInfo)
        print(taskList[0])
    }
    /// 恢复下载文件
    public func resumeTask(fileInfo: NTDownloadTask) {
        if fileInfo.status == .NTFinishedDownload || fileInfo.status != .NTPauseDownload {
            return
        }
        let downloadTask = fileInfo.task!
        downloadTask.resume()
        fileInfo.status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
        fileInfo.delegate?.downloadTaskDownloading?(task: fileInfo)
    }
    /// 开始所有下载任务
    public func resumeAllTask() {
        for task in unFinishedList {
            resumeTask(fileInfo: task)
        }
    }
    /// 暂停所有下载任务
    public func pauseAllTask() {
        for task in unFinishedList {
            pauseTask(fileInfo: task)
        }
    }
    /// 返回已下载完成文件路径 若未下载完成 则返回 nil
    public func taskPath(fileInfo: NTDownloadTask) -> String? {
        if fileInfo.status != .NTFinishedDownload {
            return nil
        }
        return "\(documentPath)/\(fileInfo.fileName)"
    }
    /// 删除下载文件
    public func removeTask(fileInfo: NTDownloadTask) {
        for i in 0..<taskList.count {
            if (fileInfo.fileURL == taskList[i].fileURL) {
                if fileInfo.status == .NTFinishedDownload {
                    let path = "\(documentPath)/\(fileInfo.fileName)"
                    try? FileManager.default.removeItem(atPath: path)
                } else {
                    taskList[i].task?.cancel()
                }
                taskList.remove(at: i)
                break
            }
        }
    }
    /// 删除所有下载文件
    public func removeAllTask() {
        for task in taskList {
            if task.status == .NTFinishedDownload {
                let path = "\(documentPath)/\(task.fileName)"
                try? FileManager.default.removeItem(atPath: path)
            }
        }
        try? FileManager.default.removeItem(atPath: plistPath)
    }
    
    public func clearTMP() {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@/%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
// MARK: - 私有方法
private extension NTDownloadManager {
    func initDownloadTasks() {
        session.getTasksWithCompletionHandler { (_, _, downloadTasks) in
            var fileURL: String
            var fileName: String
            var fileImage: String?
            for downloadTask in downloadTasks {
                if let taskDescriptions = downloadTask.taskDescription?.components(separatedBy: ",") {
                    fileURL = taskDescriptions[self.taskDescriptionFileURL]
                    fileName = taskDescriptions[self.taskDescriptionFileName]
                    fileImage = taskDescriptions.last
                } else {
                    let tasks = self.taskList.filter { $0.fileURL == downloadTask.currentRequest?.url }
                    guard let task = tasks.first else {
                        return
                    }
                    fileURL = task.fileURL.absoluteString
                    fileName = task.fileName
                    fileImage = task.fileImage
                    var taskDescription = [fileURL, fileName, "DonotAdd"]
                    if let fileImage = fileImage {
                        taskDescription = [fileURL, fileName, fileImage]
                    }
                    downloadTask.taskDescription = taskDescription.joined(separator: ",")
                }
                let url = URL(string: fileURL)!
                let task = NTDownloadTask(fileURL: url, fileName: fileName, fileImage: fileImage)
                task.status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
                task.task = downloadTask
                if task.status == .NTDownloading || task.status == .NTPauseDownload {
                    self.taskList.append(task)
                }
            }
        }
    }
    func saveTaskList() {
        let jsonArray = NSMutableArray()
        for task in taskList {
            let jsonItem = NSMutableDictionary()
            jsonItem["fileURL"] = task.fileURL.absoluteString
            jsonItem["fileName"] = task.fileName
            jsonItem["fileImage"] = task.fileImage
            if task.status == .NTFinishedDownload {
                jsonItem["statusCode"] = NTDownloadStatus.NTFinishedDownload.rawValue
            }
            jsonArray.add(jsonItem)
        }
        jsonArray.write(toFile: plistPath, atomically: true)
    }
    func loadTaskList() {
        guard let jsonArray = NSArray(contentsOfFile: plistPath) else {
            return
        }
        for jsonItem in jsonArray {
            guard let item = jsonItem as? NSDictionary, let fileName = item["fileName"] as? String, let urlString = item["fileURL"] as? String else {
                return
            }
            let fileURL = URL(string: urlString)!
            let fileImage = item["fileImage"] as? String
            let statusCode = item["statusCode"] as? Int
            let task = NTDownloadTask(fileURL: fileURL, fileName: fileName, fileImage: fileImage)
            if let statusCode = statusCode {
                let status = NTDownloadStatus(rawValue: statusCode)
                task.status = status
            } else {
                task.status = .NTPauseDownload
            }
            self.taskList.append(task)
        }
    }
}
// MARK: - URLSessionDownloadDelegate
extension NTDownloadManager: URLSessionDownloadDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("task id: \(task.taskIdentifier)")
        let error = error as NSError?
        if (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonUserForceQuitApplication || (error?.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? Int) == NSURLErrorCancelledReasonBackgroundUpdatesDisabled {
            var downloadTask = task as! URLSessionDownloadTask
            let task = unFinishedList.filter { $0.fileURL == downloadTask.currentRequest?.url }.first
            let fileURL = task?.fileURL
            let resumeData = error?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            if resumeData == nil {
                downloadTask = session.downloadTask(with: fileURL!)
            } else {
                downloadTask = session.downloadTask(withResumeData: resumeData!)
            }
            task?.status = NTDownloadStatus(rawValue: downloadTask.state.rawValue)!.status
            task?.task = downloadTask
            print(task)
        }
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for task in unFinishedList {
            if downloadTask.isEqual(task.task) {
                task.status = .NTFinishedDownload
                let destUrl = documentUrl.appendingPathComponent(task.fileName)
                do {
                    try FileManager.default.moveItem(at: location, to: destUrl)
                } catch {
                    print(error)
                }
            }
        }
        // FIXME: 保存下载完成的项目
    }
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        for task in unFinishedList {
            if downloadTask.isEqual(task.task) {
                DispatchQueue.main.async {
                    task.fileSize = (NTCommonHelper.calculateFileSize(totalBytesExpectedToWrite), NTCommonHelper.calculateUnit(totalBytesExpectedToWrite))
                    task.downloadedFileSize = (NTCommonHelper.calculateFileSize(totalBytesWritten),NTCommonHelper.calculateUnit(totalBytesWritten))
                    task.delegate?.downloadTaskUpdateProgress?(task: task, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
                }
            }
        }
    }
}

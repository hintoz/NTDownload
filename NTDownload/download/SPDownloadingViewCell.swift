//
//  SPDownloadingViewCell.swift
//  download
//
//  Created by ntian on 2017/5/15.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

class SPDownloadingViewCell: UITableViewCell {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var fileName: UILabel!
    var fileInfo: NTDownloadTask? {
        didSet {
            fileName.text = fileInfo?.fileName
            fileInfo?.delegate = self
            if fileInfo?.status?.rawValue == 0 {
                controlBtn.titleLabel?.text = "暂停"
            } else if fileInfo?.status?.rawValue == 2 {
                controlBtn.titleLabel?.text = "继续"
            }
        }
    }
    
    @IBAction func startDownload() {
        if fileInfo?.status?.rawValue == 0 {
            NTDownloadManager.shared.pauseTask(fileInfo: fileInfo!)
            controlBtn.titleLabel?.text = "暂停"
        } else if fileInfo?.status?.rawValue == 2 {
            NTDownloadManager.shared.resumeTask(fileInfo: fileInfo!)
            controlBtn.titleLabel?.text = "继续"
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if fileInfo?.status?.rawValue == 0 {
            controlBtn.titleLabel?.text = "暂停"
        } else if fileInfo?.status?.rawValue == 2 {
            controlBtn.titleLabel?.text = "继续"
        }
    }
}
// MARK: - NTDownloadDelegate
extension SPDownloadingViewCell: NTDownloadTaskDelegate {
    func downloadTaskUpdateProgress(task: NTDownloadTask, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.progressView.progress = progress
        let progressText = String(format: "%.2f%@ / %.2f%@", (task.downloadedFileSize?.size)!, (task.downloadedFileSize?.unit)!, (task.fileSize?.size)!, (task.fileSize?.unit)!)
        progressLabel.text = progressText
    }
    func downloadTaskDownloading(task: NTDownloadTask) {
        controlBtn.titleLabel?.text = "暂停"
    }
    func downloadTaskStopDownload(task: NTDownloadTask) {
        controlBtn.titleLabel?.text = "继续"
    }
}

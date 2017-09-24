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
            if fileInfo?.status == .NTDownloading {
                controlBtn.titleLabel?.text = "暂停"
            } else if fileInfo?.status == .NTPauseDownload {
                controlBtn.titleLabel?.text = "继续"
            }
        }
    }
    
    @IBAction func startDownload() {
        if fileInfo?.status == .NTDownloading {
            NTDownloadManager.shared.pauseTask(fileInfo: fileInfo!)
            controlBtn.titleLabel?.text = "暂停"
        } else if fileInfo?.status == .NTPauseDownload {
            NTDownloadManager.shared.resumeTask(fileInfo: fileInfo!)
            controlBtn.titleLabel?.text = "继续"
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if fileInfo?.status == .NTDownloading {
            controlBtn.titleLabel?.text = "暂停"
        } else if fileInfo?.status == .NTPauseDownload {
            controlBtn.titleLabel?.text = "继续"
        }
    }
}

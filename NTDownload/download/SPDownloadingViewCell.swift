//
//  SPDownloadingViewCell.swift
//  download
//
//  Created by ntian on 2017/5/15.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit
protocol demoCellDelegate {
    func didClickControlBtn(downloadTask: NTDownloadTask)
}
class SPDownloadingViewCell: UITableViewCell {

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var controlBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var fileName: UILabel!
    var delegate: demoCellDelegate?
    var fileInfo: NTDownloadTask? {
        didSet {
            fileName.text = fileInfo?.fileName
            progressView.progress = (fileInfo?.progress)!
            let status = fileInfo?.status
            if status == .NTDownloading {
                controlBtn.titleLabel?.text = "Pause"
            } else if status == .NTPauseDownload {
                controlBtn.titleLabel?.text = "Start"
            }
        }
    }
    @IBAction func startDownload() {
        delegate?.didClickControlBtn(downloadTask: fileInfo!)
    }
}

//
//  ViewController.swift
//  download
//
//  Created by ntian on 2017/5/1.
//  Copyright © 2017年 ntian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var downedTableView = UITableView()
    var downingTableView = UITableView()
    var progress: Float = 0.0
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func control() {
        if segmentedControl.selectedSegmentIndex == 0 {
            downedTableView.isHidden = false
            downingTableView.isHidden = true
        } else {
            downedTableView.isHidden = true
            downingTableView.isHidden = false
        }
        initdata()
    }
    @IBAction func addBtn() {
        let alert = UIAlertController(title: "URL", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let okAction = UIAlertAction(title: "下载", style: .default) { (action) in
            let textFiled = alert.textFields?[0].text
            NTDownloadManager.shared.newTask(urlString: textFiled!, fileImage: nil)
            self.initdata()
        }
        let action = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    var downed = [NTDownloadTask]()
    var downing = [NTDownloadTask]()
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        let rect = CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64)
        NTDownloadManager.shared.downloadManagerDelegate = self
        downedTableView = UITableView(frame: rect, style: .plain)
        downingTableView = UITableView(frame: rect, style: .plain)
        view.addSubview(downedTableView)
        view.addSubview(downingTableView)
        downedTableView.tag = 0
        downedTableView.isHidden = false
        downedTableView.dataSource = self
        downedTableView.delegate = self
        downedTableView.register(UINib(nibName: "SPDownloadedViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        downedTableView.rowHeight = 50
        downingTableView.tag = 1
        downingTableView.dataSource = self
        downingTableView.delegate = self
        downingTableView.isHidden = true
        downingTableView.register(UINib(nibName: "SPDownloadingViewCell", bundle: nil), forCellReuseIdentifier: "cellId2")
        downingTableView.rowHeight = 50
        
        initdata()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initdata()
    }
    func initdata() {

        self.downed = NTDownloadManager.shared.finishedList
        self.downing = NTDownloadManager.shared.unFinishedList
        downedTableView.reloadData()
        downingTableView.reloadData()
    }


}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return downed.count
        } else {
            return downing.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SPDownloadedViewCell
            
            cell.fileName.text = downed[indexPath.row].fileName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId2", for: indexPath) as! SPDownloadingViewCell
            cell.fileInfo = downing[indexPath.row]
            return cell
        }
    }
}

// MARK: - NTDownloadManagerDelegate
extension ViewController: NTDownloadManagerDelegate {
    
    func finishedDownload(task: NTDownloadTask) {
        print("完成\(task.fileName)")
        initdata()
    }
}

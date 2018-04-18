//
//  ViewController.swift
//  OCHBannerView
//
//  Created by hchen on 2018/4/18.
//  Copyright © 2018年 QZW. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableViewHeader()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableViewHeader() {
        
        let data = [OCHBannerViewData(url: "image01", link: "https://www.baidu.com"),
                    OCHBannerViewData(url: "image02", link: "https://m.vmall.com/index"),
                    OCHBannerViewData(url: "image03", link: "https://www.microsoftstore.com.cn/cart#"),
                    OCHBannerViewData(url: "image04", link: "https://www.apple.com"),
                    OCHBannerViewData(url: "image05", link: "https://www.yahoo.com")];
        
        let bannerView = OCHBannerView.init(width: UIScreen.main.bounds.size.width, height: 200, dataSource: data) { (link) in
            print("link:\(link)")
        }
        
        _tableView.tableHeaderView = bannerView;
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "OCHBannerViewCellID")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "OCHBannerViewCellID")
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.selectionStyle = .none
        return cell!
    }
    
}

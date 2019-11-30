//
//  ViewController.swift
//  SwiftRefreshExample
//
//  Created by 王欣 on 2019/6/10.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit
import SwiftRefresh
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var  value = 3
    
    var open:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false        
        view.addSubview(tableView)
        
        tableView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        let header = RefreshHeader.initHeaderWith {
            [unowned self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()  + 4, execute: {
                self.value += 3
                self.tableView.reloadData()
                self.tableView.header?.endRefresh()
            })
        }
        tableView.header = header
        header.beginRefresh()
        let footer = RefreshFooter.initFooterWith(refresh: {
            [unowned self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()  + 2, execute: {
                self.value += 3
                self.tableView.reloadData()
                self.tableView.footer?.endRefresh()
            })
        })
        tableView.footer = footer
        
    }

    
    lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: self.view.bounds)
        tab.delegate = self
        tab.dataSource = self
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tab
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.value
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let control  = SecondViewController()
        navigationController?.pushViewController(control, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    
    
    
}


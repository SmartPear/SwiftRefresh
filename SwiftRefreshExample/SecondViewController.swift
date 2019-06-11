//
//  SecondViewController.swift
//  SwiftRefreshExample
//
//  Created by 王欣 on 2019/6/11.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var  value = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        view.addSubview(tableView)
        
        tableView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        let header = RefreshHeader.initHeaderWith {
            [weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()  + 2, execute: {
                if let weakself = self{
                    weakself.value  = 10
                    weakself.tableView.reloadData()
                    weakself.tableView.header?.endRefresh()
                    weakself.tableView.footer?.isHidden = false
                }
                
            })
            
        }
        
        header.beginRefresh()
        tableView.header = header
        
        
        
        let footer = RefreshFooter.initFooterWith(refresh: {
            [unowned self] in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()  + 2, execute: {
                self.value += 3
                self.tableView.reloadData()
                self.tableView.footer?.endRefresh()
            })
        })
        
        tableView.footer = footer
        footer.isHidden = true
        // Do any additional setup after loading the view.
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

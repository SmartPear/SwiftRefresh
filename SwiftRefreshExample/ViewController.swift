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
    var  value = 0
    @IBOutlet weak var tableView: UITableView!
    
    var open:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let header = RefreshHeader.initHeaderWith {
            [unowned self] in 
            self.value += 3
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.tableView.header?.endRefresh()
            }
        }
        header.beginRefresh()
        tableView.header = header
        tableView.backgroundColor = UIColor.white

    }
    

    
    @IBAction func refreshAction(_ sender: Any) {
        tableView.header?.beginRefresh()
    }
    
    
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


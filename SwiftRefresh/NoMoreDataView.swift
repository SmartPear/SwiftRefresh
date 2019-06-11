//
//  NoMoreDataView.swift
//  Animation
//
//  Created by 王欣 on 2019/6/10.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

class NoMoreDataView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(textLab)
        let centerx = NSLayoutConstraint.init(item: textLab, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 1);
        let centery = NSLayoutConstraint.init(item: textLab, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 1)
        let width = NSLayoutConstraint.init(item: textLab, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 1)
        let height = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 1)
        self.addConstraints([centerx,centery,width,height])
    }
    
    func setNoData(with text:String) {
        textLab.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textLab: UILabel = {
        let lab = UILabel.init()
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = UIColor.black
        lab.numberOfLines = 0
        lab.translatesAutoresizingMaskIntoConstraints = false
        return lab
    }()
    
}

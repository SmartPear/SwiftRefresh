//
//  HeaderAnimation.swift
//  Animation
//
//  Created by 王欣 on 2019/6/7.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit
class HeaderAnimation: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    let distance:CGFloat = 28
    let duration = 1.8
    let bollWidth:CGFloat = 13
    private var isAnimation = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        backgroundColor = UIColor.clear
        addSubview(baseView)
        baseView.translatesAutoresizingMaskIntoConstraints = false
        let centerx = NSLayoutConstraint.init(item: baseView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centery = NSLayoutConstraint.init(item: baseView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let width   = NSLayoutConstraint.init(item: baseView, attribute: .width,   relatedBy: .equal, toItem: nil,  attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let height  = NSLayoutConstraint.init(item: baseView, attribute: .height, relatedBy: .equal,  toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        height.priority = UILayoutPriority.init(900)
        width.priority = UILayoutPriority.init(900)
        addConstraints([centerx,centery,width,height])
        baseView.addSubview(animationLayer1)
        baseView.addSubview(animationLayer2)
        baseView.addSubview(animationLayer3)
        updateLayerPostion(with: 0)
        
    }
    
    
    func startAnimation(_ animation:Bool) {
        
        isAnimation = animation
        if isAnimation{
            self.setupAnimationOne()
            self.setupAnimationTwo()
            self.setupAnimationThree()
        }else{
            self.animationLayer1.layer.removeAnimation(forKey: "animationLayer1")
            self.animationLayer2.layer.removeAnimation(forKey: "animationLayer2")
            self.animationLayer3.layer.removeAnimation(forKey: "animationLayer3")
        }
    }
    
    
    func updateLayerPostion(with progress:CGFloat) {
        
        let newValue = min(1, progress)
        let centerX = baseView.bounds.size.width/2
        let centerY = baseView.bounds.size.height/2
        let point   = CGPoint.init(x: centerX, y: centerY)
        let point1  = CGPoint.init(x: centerX - distance * newValue, y: centerY)
        let point2  = CGPoint.init(x: centerX + distance * newValue, y: centerY)
        self.animationLayer2.center = point
        self.animationLayer1.center = point1
        self.animationLayer3.center = point2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isAnimation{
            startAnimation(isAnimation)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupAnimationOne(){
        
        let path = CGMutablePath.init()
        let centerx = baseView.bounds.size.width/2
        let centery = baseView.bounds.size.height/2
        let point1 = CGPoint.init(x: centerx - distance, y: centery)
        let point2 = CGPoint.init(x: centerx, y: centery)
        let point3 = CGPoint.init(x: centerx + distance, y: centery)
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point2)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point2)
        path.addLine(to: point1)
        animationLayer1.layer.position = point1
        
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.beginTime = 0
        animation.isRemovedOnCompletion = true
        animationLayer1.layer.add(animation, forKey: "animationLayer1")
        
    }
    
    func setupAnimationTwo(){
        
        let path = CGMutablePath.init()
        let centerx = baseView.bounds.size.width/2
        let centery = baseView.bounds.size.height/2
        let point3 = CGPoint.init(x: centerx - distance, y: centery )
        let point1 = CGPoint.init(x: centerx + distance, y: centery)
        let point4 = CGPoint.init(x: centerx, y: centery )
        path.move(to: point4)
        path.addLine(to: point4)
        path.addLine(to: point1)
        path.addLine(to: point4)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addLine(to: point4)
        animationLayer2.center = point4
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = true
        animationLayer2.layer.add(animation, forKey: "animationLayer2")
    }
    
    func setupAnimationThree(){
        let path = CGMutablePath.init()
        let centerx = baseView.bounds.size.width/2
        let centery = baseView.bounds.size.height/2
        let point3 = CGPoint.init(x: centerx - distance, y: centery )
        let point2 = CGPoint.init(x: centerx, y: centery )
        let point1 = CGPoint.init(x: centerx + distance, y: centery)
        
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point2)
        path.addLine(to: point2)
        path.addLine(to: point2)
        path.addLine(to: point1)
        animationLayer3.layer.position = point1
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = true
        animationLayer3.layer.add(animation, forKey: "animationLayer3")
    }
    
    lazy var animationLayer1: UIView = {
        let layer = UIView.init()
        layer.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).withAlphaComponent(0.95)
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.layer.masksToBounds = true
        layer.layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    
    lazy var animationLayer2: UIView = {
        let layer = UIView.init()
        layer.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).withAlphaComponent(0.95)
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.layer.masksToBounds = true
        layer.layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    
    lazy var animationLayer3: UIView = {
        let layer = UIView.init()
        layer.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).withAlphaComponent(0.95)
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.layer.masksToBounds = true
        layer.layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    
    lazy var baseView: UIView = {
        let baseView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 40))
        baseView.backgroundColor = UIColor.clear
        return baseView
    }()
    
    
    
}

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
    let distance:CGFloat = 30
    let duration = 1.8
    let bollWidth:CGFloat = 14
    private var isAnimation = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        layer.addSublayer(animationLayer1)
        layer.addSublayer(animationLayer2)
        layer.addSublayer(animationLayer3)
        self.updateLayerPostion(with: 0)
    }
    
    func updateWith(_ progress:CGFloat) {
        self.updateLayerPostion(with: progress)
    }
    
    func startAnimation(_ animation:Bool) {

        isAnimation = animation
        if isAnimation{
            self.setupAnimationOne()
            self.setupAnimationTwo()
            self.setupAnimationThree()
        }else{
            animationLayer1.removeAnimation(forKey: "animationLayer1")
            animationLayer2.removeAnimation(forKey: "animationLayer2")
            animationLayer3.removeAnimation(forKey: "animationLayer3")
            self.updateLayerPostion(with: 0)
        }
    }
    
    
    func updateLayerPostion(with progress:CGFloat) {
        let newValue = min(1, progress)
        let height = self.bounds.size.height/2
        let centerX = self.center.x
        let centerY = self.center.y
        let gapping = (height - bollWidth) * (1 - progress)
        let newCenterY = centerY +  gapping
        let point = CGPoint.init(x: centerX, y: newCenterY)
        let point1 = CGPoint.init(x: centerX - distance * newValue, y: newCenterY)
        let point2 = CGPoint.init(x: centerX + distance * newValue, y: newCenterY)
        self.animationLayer2.position = point
        self.animationLayer1.position = point1
        self.animationLayer3.position = point2
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isAnimation{
           startAnimation(isAnimation)
        }else{
            updateLayerPostion(with: 0)
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupAnimationOne(){
        
        let path = CGMutablePath.init()
        let centerx = self.center.x
        let centery = self.center.y
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
        
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        let frameAnimation = CAKeyframeAnimation.init(keyPath: "transform.translation.z")
        frameAnimation.values = [1,2,2,1,1,0,1]
        let group = CAAnimationGroup.init()
        group.animations = [frameAnimation,animation]
        group.duration = duration
        group.repeatCount = HUGE
        group.beginTime = 0
        group.isRemovedOnCompletion = false
        animationLayer1.add(group, forKey: "animationLayer1")
        
    }
    
    func setupAnimationTwo(){
        
        let path = CGMutablePath.init()
        let centerx = self.center.x
        let centery = self.center.y
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
        
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        let frameAnimation = CAKeyframeAnimation.init(keyPath: "transform.translation.z")
        frameAnimation.values = [2,1,1,0,1,2,1]
        let group = CAAnimationGroup.init()
        group.animations = [frameAnimation,animation]
        group.duration = duration
        group.repeatCount = HUGE
        animationLayer2.add(group, forKey: "animationLayer2")
    }
    
    func setupAnimationThree(){
        
        let path = CGMutablePath.init()
        let centerx = self.center.x
        let centery = self.center.y
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
        
        animationLayer3.position = point2
        
        let animation = CAKeyframeAnimation.init(keyPath: "position")
        animation.path = path
        let frameAnimation = CAKeyframeAnimation.init(keyPath: "transform.translation.z")
        frameAnimation.values = [1,0,1,2,2,1,1]
        let group = CAAnimationGroup.init()
        group.animations = [frameAnimation,animation]
        group.duration = duration
        group.repeatCount = HUGE
        animationLayer3.add(group, forKey: "animationLayer3")
    }
    
    
    
    
    lazy var animationLayer1: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    lazy var animationLayer2: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1).cgColor
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    lazy var animationLayer3: CAShapeLayer = {
        let layer = CAShapeLayer.init()
        layer.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor
        layer.frame = CGRect.init(x: 0, y: 0, width: bollWidth, height: bollWidth)
        layer.masksToBounds = true
        layer.cornerRadius = CGFloat(bollWidth/2)
        return layer
    }()
    
    
    
    
    
}

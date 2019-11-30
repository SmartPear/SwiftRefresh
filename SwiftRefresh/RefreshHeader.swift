//
//  RefreshHeader.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit
public class RefreshHeader: RefreshComponent {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    @objc public class func initHeaderWith(refresh:@escaping (()->Void)) -> RefreshHeader{
        let header = RefreshHeader.init(frame: CGRect.init(x: 0, y: -1, width: UIScreen.main.bounds.size.width, height: 1))
        header.refreshClosure = refresh
        return header
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare()  {
        self.updateFrameWithProgress(0)
        self.animationView.frame = self.bounds
        self.addSubview(animationView)
        self.autoresizesSubviews = true
        animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    func updateFrameWithProgress(_ progress:CGFloat) {
        if let superview = superview{
            var height = freshBeginHeight * progress
            if height == 0{
                height = 0.5
            }
            self.frame = CGRect.init(x: 0, y: -height, width: superview.bounds.size.width, height: height)
            Log("更新frame \(self.frame)",String.init(format: "%p", self))
            self.animationView.updateLayerPostion(with:progress)
        }
    }
    
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        Log("offset 监听\(scrollview!.contentOffset)",self.state,String.init(format: "%p", self))
        if self.isHidden == true {return}
        
        if self.state == .refreshing||self.state == .noMoreData||self.state == .end{///如果正在刷新,返回
            return
        }
        if self.scrollview == nil {return}
        self.originContentOfSet = scrollview!.re_inset.top
        let originOfset  = self.originContentOfSet
        let currentOfset = -scrollview!.contentOffset.y
        let offset = currentOfset - originOfset
        if offset < 0{
            return
        }
        let progress = min(1, offset/freshBeginHeight)
        if scrollview!.isDragging||self.state != .willRefresh||self.state == .end{
            if progress >= CriticalProgress{
                self.state = .willRefresh
            }else if progress > 0 ,progress < CriticalProgress{
                self.state = .pulling
            }else{
                self.state = .idle
            }
            if self.state == .end {
                return
            }
            updateFrameWithProgress(progress)
        }
    }
    
    override func startRefresh(){
        if self.scrollview == nil {
            self.state = .idle
            return
        }
        safeThread {
            let newValue = self.originContentOfSet + freshBeginHeight
            var offset   = self.scrollview!.contentOffset
            offset = CGPoint.init(x: offset.x, y: -newValue)
            self.animationView.startAnimation(true)
            Log("开始刷新 \(newValue)",String.init(format: "%p", self))
            UIView.animate(withDuration: refreshAnimationTime, animations: {
                self.scrollview!.re_insetTop = newValue
                self.scrollview!.setContentOffset(offset, animated: true)
                self.updateFrameWithProgress(1)
            }) { (_) in
                self.executeRefreshingCallback()
            }
        }
    }
    
    
    
    override func refreshComplete(_ noMore:Bool) {
        if self.scrollview == nil {
            self.state = .idle
            return
        }
        safeThread {
            Log("刷新结束 \(self.originContentOfSet)",String.init(format: "%p", self))
            UIView.animate(withDuration: refreshAnimationTime, delay: 0, options: [.curveLinear], animations: {
                self.scrollview!.re_insetTop = self.originContentOfSet
            }) { (_) in
                self.animationView.startAnimation(false)
                self.state = .idle
            }
        }
    }
}


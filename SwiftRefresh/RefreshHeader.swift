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
        let header = RefreshHeader.init()
        header.refreshClosure = refresh
        return header
        
    }
    
    override func prepare()  {
        self.updateFrameWithProgress(0)
        self.animationView.frame = self.bounds
        self.addSubview(animationView)
        self.autoresizesSubviews = true
        animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        if self.state == .willRefresh{
            self.state = .refreshing
        }
        
    }
    
    func updateFrameWithProgress(_ progress:CGFloat) {
        if let superview = superview{
            let height = freshBeginHeight * progress
            self.frame = CGRect.init(x: 0, y: -height, width: superview.bounds.size.width, height: height)
            self.animationView.updateLayerPostion(with:progress)
        }
    }
    
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        if self.isHidden == true {return}
        if self.state == .refreshing||self.state == .noMoreData||self.state == .end{///如果正在刷新,返回
            return
        }
        let originOfset  = self.originContentOfSet.y
        let currentOfset = scrollview!.contentOffset.y
        let offset = originOfset - currentOfset
        if offset < 0{
            return
        }
        let progress = min(1, offset/freshBeginHeight)
        if progress >= CriticalProgress{
            self.state = .willRefresh
        }else if progress <= 0.2{
            self.state = .idle
        }
        self.dragProgress = progress
        updateFrameWithProgress(progress)
    }
    
    
    @objc public func endRefresh() {
        if self.state == .refreshing{
            self.state = .end
        }
    }
    
    @objc public func beginRefresh() {
        if let _ = self.scrollview{
            self.state = .refreshing
        }else{
            self.state = .willRefresh
        }
    }
    
    override func gesStateChanged(_ state:UIGestureRecognizer.State) {
        if state == .ended{
            if self.state == .willRefresh{
                self.state = .refreshing
            }
        }
    }
    
    override func startRefresh(){
        super.startRefresh()
        if let scroll = self.scrollview{
            DispatchQueue.main.async {
                let newValue = scroll.re_insetTop + freshBeginHeight
                let newOfset = -newValue
                var offset = scroll.contentOffset
                offset = CGPoint.init(x: offset.x, y: newOfset)
                self.animationView.startAnimation(true)
                UIView.animate(withDuration: refreshAnimationTime, animations: {
                    scroll.re_insetTop = newValue
                    scroll.setContentOffset(offset, animated: true)
                    self.updateFrameWithProgress(1)
                }) { (_) in
                    self.executeRefreshingCallback()
                }
            }
        }
    }
    
    
    
    override func refreshComplete(_ noMore:Bool) {
        if let _  = self.scrollview{
            DispatchQueue.main.async {
                self.animationView.startAnimation(false)
                UIView.animate(withDuration: refreshAnimationTime, delay: 0, options: [.layoutSubviews,.curveLinear], animations: {
                    self.scrollview!.re_insetTop = self.scrollview!.re_insetTop - freshBeginHeight
                    self.updateFrameWithProgress(0)
                }) { (_) in
                    self.state = .idle
                }
            }
        }else{
            self.state = .idle
        }
    }
}


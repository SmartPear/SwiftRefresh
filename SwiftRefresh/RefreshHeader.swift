//
//  RefreshHeader.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit
public class RefreshHeader: RefreshComponent {
    
    
    @objc public class func initHeaderWith(refresh:@escaping (()->Void)) -> RefreshHeader{
        let header = RefreshHeader.init(frame: .zero)
        header.refreshClosure = refresh
        return header
    }
    
    public override func didMoveToSuperview() {
         super.didMoveToSuperview()
         if let scrollView = superview as? UIScrollView{
             self.scrollview = scrollView
             self.presenter.updateScrollView(scrollView)
             self.originContentOfSet = scrollView.re_inset.top
             topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
             heightConstraint =  NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5)
             NSLayoutConstraint.activate([
                 topConstraint!,heightConstraint!,
                 NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
                 NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
             ])
             prepare()
         }
     }
    
    override func prepare()  {
        addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: self.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            animationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        self.updateFrameWithProgress(0)
    }
    
    func updateFrameWithProgress(_ progress:CGFloat) {
        var height = freshBeginHeight * progress
        if height == 0{
            height = 0.5
        }
        self.updateOffset(height)
        self.animationView.updateLayerPostion(with:progress)
    }
    
    func updateOffset(_ value:CGFloat)  {
        topConstraint?.constant = -value
        heightConstraint?.constant = value
    }
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        guard let scrollview = scrollview else {
            return
        }
        Log("offset 监听\(scrollview.contentOffset)",self.state,String.init(format: "%p", self))
        if self.isHidden == true {return}
        
        if self.state == .refreshing||self.state == .noMoreData||self.state == .end{///如果正在刷新,返回
            return
        }
        let originOfset  = self.originContentOfSet
        self.originContentOfSet = scrollview.re_inset.top
        let currentOfset = -scrollview.contentOffset.y
        
        let offset = currentOfset - originOfset
        if offset < 0{
            return
        }
        if self.state == .idle || self.state == .pulling {
            updateOffset(currentOfset)
        }
        let progress = min(1, offset/freshBeginHeight)
        if scrollview.isDragging||self.state != .willRefresh||self.state == .end{
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
        
        if let footerState = scrollview?.footer?.state,footerState == .refreshing{
            return
        }
        
        guard let scrollView = self.scrollview else {
            self.state = .idle
            return
        }
        safeThread {
            let newValue = self.originContentOfSet + freshBeginHeight
            var offset   = scrollView.contentOffset
            offset = CGPoint.init(x: offset.x, y: -newValue)
            self.animationView.startAnimation(true)
            UIView.animate(withDuration: refreshAnimationTime, animations: {
                scrollView.re_insetTop = newValue
                scrollView.setContentOffset(offset, animated: true)
                self.updateFrameWithProgress(1)
            }) { (_) in
                self.executeRefreshingCallback()
            }
        }
    }
    
    
    
    override func refreshComplete(_ noMore:Bool) {
        guard let scrollView = self.scrollview else {
            self.state = .idle
            return
        }
        safeThread {
            UIView.animate(withDuration: refreshAnimationTime, delay: 0, options: [.curveLinear], animations: {
                scrollView.re_insetTop = self.originContentOfSet
            }) { (_) in
                self.animationView.startAnimation(false)
                self.state = .idle
            }
        }
    }
}


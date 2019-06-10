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
    public class func initHeaderWith(refresh:@escaping (()->Void)) -> RefreshHeader{
        let header = RefreshHeader.init()
        header.refreshClosure = refresh
        return header
        
    }
    
    override func prepare()  {
        if let superView = self.scrollview{
            self.frame = CGRect.init(x: 0, y: -freshBeginHeight, width: superView.bounds.size.width, height: freshBeginHeight)
            self.addSubview(animationView)
            animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        }
    }
    
    
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        if self.state == .refreshing||self.state == .noMoreData{///如果正在刷新,返回
            return
        }
        let originOfset  = self.originContentOfSet.y
        
        let currentOfset = scrollview!.contentOffset.y
        if currentOfset > originOfset{
            return
        }
        let  offset = originOfset - currentOfset
        let progress     = min(1, offset/freshBeginHeight)
        if progress >= CriticalProgress{
            self.state = .willRefresh
        }else if progress <= 0.2{
            self.state = .idle
        }
        self.dragProgress = progress
        self.animationViewUpdate(with:progress)
    }
    
    ///
    func animationViewUpdate(with progress:CGFloat) {
        self.animationView.updateWith(progress)
    }
    
    public func endRefresh() {
        self.state = .end
    }
    
    public func beginRefresh() {
        self.state = .refreshing
    }
    
    override func startRefresh(){
        super.startRefresh()
        let newValue = self.scrollview!.re_insetTop + freshBeginHeight
        let newOfset = -newValue
        var offset = self.scrollview!.contentOffset
        offset = CGPoint.init(x: offset.x, y: newOfset)
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollview!.re_insetTop = newValue
            self.scrollview!.setContentOffset(offset, animated: true)
            self.animationView.startAnimation(true)
        }) { (_) in
            self.executeRefreshingCallback()
        }
    }
    
    
    
    override func refreshComplete(_ noMore:Bool) {
        super.refreshComplete(noMore)
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollview!.re_insetTop = self.scrollview!.re_insetTop - freshBeginHeight
        }) { (_) in
            self.state = .idle
            self.animationView.startAnimation(false)
        }
    }
}

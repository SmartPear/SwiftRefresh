//
//  RefreshFooter.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

public class RefreshFooter: RefreshComponent {
    
    public class func initFooterWith(refresh:@escaping (()->Void)) -> RefreshFooter{
        let footer = RefreshFooter.init()
        footer.refreshClosure = refresh
        return footer
    }
    deinit {
        print("tableview 销毁")
    }
    
    override func prepare()  {
        if let superView = self.scrollview{
            self.frame = CGRect.init(x: 0, y: scrollview!.contentSize.height, width: superView.bounds.size.width, height: freshBeginHeight)
            self.addSubview(animationView)
            self.addSubview(self.noMoredataView)
            animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            self.animationView.frame = self.bounds
            if self.state == .willRefresh{
                self.state = .refreshing
            }
        }
    }
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        if self.isHidden == true  {return}
        if self.state == .refreshing || self.state == .noMoreData || self.state == .end || self.state == .noMoreData{///如果正在刷新,返回
            return
        }
        var value:CGFloat = 0.0
        if scrollview!.contentSize.height < scrollview!.bounds.size.height {
            value = scrollview!.contentOffset.y + scrollview!.re_insetTop
        }else{
            value = scrollview!.contentOffset.y - scrollview!.contentSize.height + scrollview!.bounds.size.height  - scrollview!.re_insetBottom
        }
        if value < 0 {
            return
        }
        
        let progress   = min(1, value/freshBeginHeight)
        if progress >= CriticalProgress{
            self.state = .willRefresh
            
        }else if progress <= 0.2{
            self.state = .idle
        }
        self.dragProgress = progress
        self.animationViewUpdate(with:progress)
    }
    
    override func scrollViewContentSizeDidChange(_ size: CGSize) {
        self.frame.origin.y = size.height
    }
    
    ///
    func animationViewUpdate(with progress:CGFloat) {
        self.animationView.updateLayerPostion(with: progress)
    }
    
    override func startRefresh(){
        self.animationView.startAnimation(true)
        UIView.animate(withDuration: 0.25, animations: {
            let bottom = self.scrollview!.re_insetBottom + freshBeginHeight
            self.scrollview!.re_insetBottom = bottom
            var offset = self.scrollview!.contentOffset
            var newValue = (self.scrollview!.contentSize.height - self.scrollview!.bounds.size.height + bottom)
            if  newValue < 0{
                newValue = -self.scrollview!.re_insetTop
            }
            offset.y = newValue
            self.scrollview!.setContentOffset(offset, animated: true)
            self.animationViewUpdate(with: 1)
        }) { (_) in
            self.executeRefreshingCallback()
        }
    }
    
    public func resetNoMoredata() {
        self.state = .idle
    }
    
    public func beginRefresh() {
        if let _ = self.scrollview{
            self.state = .refreshing
        }else{
            self.state = .willRefresh
        }
    }
    
    public func noMoreData() {
        self.state = .noMoreData
    }
    
    public  func endRefresh() {
        if self.state == .willRefresh || self.state == .refreshing{
            self.state = .end
        }
    }
    
    public func endFreshWithnoMoreData() {
        self.refreshComplete(true)
    }
    
    override func gesStateChanged(_ state:UIGestureRecognizer.State) {
        if state == .ended{
            if self.dragProgress == 1.0{
                self.state = .refreshing
            }
        }
    }
    
    override func refreshComplete(_ noMore:Bool) {
        if let _ = self.scrollview{
            self.animationView.startAnimation(false)
            UIView.animate(withDuration: 0.25, animations: {
                self.scrollview!.re_insetBottom = self.scrollview!.re_insetBottom - freshBeginHeight
                self.animationViewUpdate(with: 0)
            }) { (_) in
                if noMore == true{
                    self.state = .noMoreData
                }else{
                    self.state = .idle
                }
            }
        }else{
            self.state = .idle
        }
    }
    
    
}

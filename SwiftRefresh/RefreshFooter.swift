//
//  RefreshFooter.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit

public class RefreshFooter: RefreshComponent {
    
    @objc public class func initFooterWith(refresh:@escaping (()->Void)) -> RefreshFooter{
        let footer = RefreshFooter.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: freshBeginHeight))
        footer.refreshClosure = refresh
        return footer
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare()  {
        if let superView = self.scrollview{
            self.frame = CGRect.init(x: 0, y: scrollview!.contentSize.height, width: superView.bounds.size.width, height: freshBeginHeight)
            self.addSubview(animationView)
            self.addSubview(self.noMoredataView)
            animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            self.animationView.frame = self.bounds
        }
    }
    
    
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        if self.isHidden == true  {return}
        if self.scrollview == nil {return}
        if self.state == .refreshing || self.state == .noMoreData || self.state == .end || self.state == .noMoreData{///如果正在刷新,返回
            return
        }
        
        if scrollview!.isDragging == true || self.state != .willRefresh{
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
            }else if progress < CriticalProgress && progress > 0{
                self.state = .pulling
            }else{
                self.state = .idle
            }
            self.animationView.updateLayerPostion(with: progress)
        }
        
    }
    
    override func scrollViewContentSizeDidChange(_ size: CGSize) {
        self.frame.origin.y = size.height
    }
    
    override func startRefresh(){
        if self.scrollview == nil {return}
        if self.isHidden == false{
            self.animationView.startAnimation(true)
            UIView.animate(withDuration: refreshAnimationTime, animations: {
                let bottom = self.scrollview!.re_insetBottom + freshBeginHeight
                self.scrollview!.re_insetBottom = bottom
                var offset = self.scrollview!.contentOffset
                var newValue = (self.scrollview!.contentSize.height - self.scrollview!.bounds.size.height + bottom)
                if newValue < 0{
                    if  newValue < -self.scrollview!.re_insetTop{
                        newValue = -self.scrollview!.re_insetTop
                    }
                }

                Log(newValue)
                offset.y = newValue
                self.scrollview!.setContentOffset(offset, animated: true)
                self.animationView.updateLayerPostion(with: 1)
            }) { (_) in
                self.executeRefreshingCallback()
            }
        }else{
            self.state = .idle
        }
        
    }
    
    @objc public func resetNoMoredata() {
        self.state = .idle
    }
    
    @objc public func noMoreData() {
        self.state = .noMoreData
    }
    
    
    @objc public func endFreshWithnoMoreData() {
        self.refreshComplete(true)
    }
    
    
    override func refreshComplete(_ noMore:Bool) {
        if self.scrollview == nil {return}
        
        UIView.animate(withDuration: refreshAnimationTime, animations: {
            self.scrollview!.re_insetBottom = self.scrollview!.re_insetBottom - freshBeginHeight
        }) { (_) in
            self.animationView.startAnimation(false)
            self.animationView.updateLayerPostion(with: 0)
            if noMore == true{
                self.state = .noMoreData
            }else{
                self.state = .idle
            }
        }
    }
}

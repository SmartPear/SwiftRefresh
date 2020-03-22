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
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let scrollView = superview as? UIScrollView{
            self.scrollview = scrollView
            self.presenter.updateScrollView(scrollView)
            self.originContentOfSet = scrollView.re_inset.top
            var originY = scrollView.bounds.height > scrollView.contentSize.height ? scrollView.bounds.height:scrollView.contentSize.height
                    originY -= scrollView.re_insetTop
            topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: originY)
            heightConstraint =  NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 190)
            NSLayoutConstraint.activate([
                topConstraint!,heightConstraint!,
                NSLayoutConstraint.init(item: self, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: 1, constant: 0),
            ])
            prepare()
        }
    }
    
    override func prepare()  {
        backgroundColor = UIColor.red
        self.addSubview(animationView)
        self.addSubview(self.noMoredataView)
        animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.animationView.frame = self.bounds
    }
    
    func updateOffset(_ value:CGFloat)  {
        
        //        topConstraint?.constant = -value
        heightConstraint?.constant = value
        
    }
    
    func updateFrameWithProgress(_ progress:CGFloat) {
        //        var height = freshBeginHeight * progress
        //        if height == 0{
        //            height = 0.5
        //        }
        //        self.updateOffset(height)
        //        self.animationView.updateLayerPostion(with:progress)
    }
    
    override func scrollViewContentOffsetDidChange(_ change: CGPoint) {
        if self.isHidden == true  {return}
        guard let scrollview = scrollview else{return}
        if self.state == .refreshing || self.state == .noMoreData || self.state == .end || self.state == .noMoreData{///如果正在刷新,返回
            return
        }
        
        if scrollview.isDragging == true || self.state != .willRefresh{
            var value:CGFloat = 0.0
            if scrollview.contentSize.height < scrollview.bounds.size.height {
                value = scrollview.contentOffset.y + scrollview.re_insetTop
            }else{
                value = scrollview.contentOffset.y - scrollview.contentSize.height + scrollview.bounds.size.height  - scrollview.re_insetBottom
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
            updateFrameWithProgress(progress)
        }
        
    }
    
    override func scrollViewContentSizeDidChange(_ size: CGSize) {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        var originY = scrollView.bounds.height > scrollView.contentSize.height ? scrollView.bounds.height:scrollView.contentSize.height
        originY -= scrollView.re_insetTop
        topConstraint = NSLayoutConstraint.init(item: self, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: originY)
    }
    
    override func startRefresh(){
        guard let scrollview = scrollview else{
            return
        }
        if let footerState = scrollview.footer?.state,footerState == .refreshing{
            return
        }
        if self.isHidden == false{
            self.animationView.startAnimation(true)
            UIView.animate(withDuration: refreshAnimationTime, animations: {
                let bottom = scrollview.re_insetBottom + freshBeginHeight
                self.scrollview!.re_insetBottom = bottom
                var offset = scrollview.contentOffset
                var newValue = (scrollview.contentSize.height - self.scrollview!.bounds.size.height + bottom)
                if newValue < 0{
                    if  newValue < -scrollview.re_insetTop{
                        newValue = -scrollview.re_insetTop
                    }
                }
                
                offset.y = newValue
                scrollview.setContentOffset(offset, animated: true)
                self.updateFrameWithProgress(1)
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
            self.updateFrameWithProgress(1)
            if noMore == true{
                self.state = .noMoreData
            }else{
                self.state = .idle
            }
        }
    }
}

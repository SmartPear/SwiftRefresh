//
//  RefreshComponent.swift
//  Animation
//
//  Created by 王欣 on 2019/6/6.
//  Copyright © 2019 王欣. All rights reserved.
//

import UIKit



public class RefreshComponent: UIView {
    var refreshClosure:(()->Void)?
    private var _state:RefreshState = .idle
    weak var scrollview:UIScrollView?
    weak var pan:UIPanGestureRecognizer?
    var originContentOfSet = CGPoint.zero
    var containNoMoreView:Bool = false
    var dragProgress:CGFloat = 0.0
    var hasShake = false
    var initSrollViewOfset = false
    var contentSize:CGSize = .zero
    var isMoreData = false
    
    
    var state:RefreshState {
        get{
            return _state
        }
        set{
            if _state == newValue{
                return
            }
            _state = newValue
            switch newValue {
            case .idle:
                self.dragProgress = 0
                hasShake = false
                if self.containNoMoreView == true{
                    self.noMoredataView.isHidden = true
                    self.animationView.isHidden = false
                    isMoreData = false
                }
            case .refreshing:
                self.hasShake = true
                startRefresh()
            case .willRefresh:
                if hasShake == false{
                    hasShake = true
                    addShake()
                }
                break
            case .end:
                self.dragProgress = 0
                self.hasShake = false
                refreshComplete(false)
            case .noMoreData:
                self.dragProgress = 0
                refreshComplete(true)
            }
        }
    }
    
    func startRefresh()  {
        
    }
    
    func refreshComplete(_ noMore:Bool) {
        
    }
    
    func executeRefreshingCallback() {
        if let closure = self.refreshClosure{
            closure()
        }
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        removeObservers()
        if let scrollView = newSuperview as? UIScrollView{
            self.scrollview = scrollView
            prepare()
            addObservers()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: freshBeginHeight))
        self.autoresizingMask = .flexibleWidth
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepare()  {
        
    }
    
    
    func addObservers() {
        if let scroll = self.scrollview {
            scroll.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
            scroll.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
            self.pan = scroll.panGestureRecognizer
            self.pan?.addObserver(self, forKeyPath: "state", options: .new, context: nil)
        }
    }
    
    func removeObservers(){
        if let scroll = self.scrollview{
            scroll.removeObserver(self, forKeyPath: "contentOffset")
            scroll.removeObserver(self, forKeyPath: "contentSize")
        }
        if let pan = self.pan{
            pan.removeObserver(self, forKeyPath: "state")
            self.pan = nil
        }
    }
    
    ///
    func scrollViewContentOffsetDidChange(_ change:CGPoint) {
        //        print("offset改变")
    }
    
    func scrollViewContentSizeDidChange(_ size:CGSize) {
        //        print("size改变")
    }
    
    func gesStateChanged(_ state:UIGestureRecognizer.State) {
        if state == .ended{
            if self.dragProgress == 1.0{
                self.state = .refreshing
            }
        }
    }
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentOffset",self.state != .refreshing{
            if let  change = change{
                if let value = change[NSKeyValueChangeKey.newKey] as? CGPoint{
                    if initSrollViewOfset == false{
                        self.originContentOfSet = scrollview!.contentOffset
                        return
                    }
                    scrollViewContentOffsetDidChange(value)
                }
            }
        }
        
        if keyPath == "contentSize"{
            if let  change = change{
                if let value = change[NSKeyValueChangeKey.newKey] as? CGSize{
                    scrollViewContentSizeDidChange(value)
                }
            }
        }
        
        if keyPath == "state"{
            
            if let  change = change{
                initSrollViewOfset = true
                if let value = change[NSKeyValueChangeKey.newKey] as? Int{
                    if let state = UIGestureRecognizer.State.init(rawValue: value){
                        gesStateChanged(state)
                    }
                }
            }
        }
    }
    
    
    ///添加震动
    func addShake()  {
        if #available(iOS 10.0, *) {
            let feedback = UIImpactFeedbackGenerator.init(style: .light)
            feedback.prepare()
            feedback.impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    lazy var animationView: HeaderAnimation = {
        let view = HeaderAnimation.init(frame: self.bounds)
        return view
    }()
    
    lazy var noMoredataView: NoMoreDataView = {
        let view = NoMoreDataView.init(frame: self.bounds)
        view.setNoData(with: noMoreDataText)
        view.isHidden = true
        return view
    }()
    
}
